%% adapted from /Kilosort-2.5/main_kilosort.m
% runs Kilosort algorithm for one entire day %
% NOTE: made this a function so it's easier to run from CLI
%
function exitcode = runKilosortMain(animal, ddate, batchesPerStore, channelsPerBatch)

    % Turn off figure visibility
    set(0,'DefaultFigureVisible','off')
    
    %% add paths for Kilosort, other packages
    KS_install_path = '/home/kgg/Desktop/kilosort-2.5/';
    NPYM_install_path = '/home/kgg/Desktop/npy-matlab/';
    KS_data_path = '/home/kgg/Desktop/kilosort_data/';
    
    addpath(genpath([KS_install_path])) % path to kilosort folder
    addpath(genpath([NPYM_install_path])) % for converting to Phy

    %% select animal/date/time
    day_folder_path = [KS_data_path animal '/' ddate '/'];
    config_file_path = [KS_install_path '/custom_pipeline_scripts/2_run-kilosort-matlab/kilosortConfig.m']; %CHANGE

    %% run kilosort algorithm for all stores,batches
    %
    stores = {'RSn2', 'RSn3'}; %HARDCODED 
    batches = [1:batchesPerStore];

    assert(channelsPerBatch * batchesPerStore == 256);
    if channelsPerBatch==128
        chanmap_file_path = [KS_install_path '/custom_pipeline_scripts/2_run-kilosort-matlab/chanMap128.mat']; %CHANGE
    elseif channelsPerBatch==64
        chanmap_file_path = [KS_install_path '/custom_pipeline_scripts/2_run-kilosort-matlab/chanMap64.mat']; %CHANGE
    elseif channelsPerBatch==32
        chanmap_file_path = [KS_install_path '/custom_pipeline_scripts/2_run-kilosort-matlab/chanMap32.mat']; %CHANGE
    else
        assert(false, 'make this chanmap')
    end

    mkdir(day_folder_path);
    cd(day_folder_path);

    store_batches = {};
    ct = 1;
    for i=1:length(stores)
        for j=1:length(batches)
            store = stores{i};
            batch = num2str(batches(j));
            store_batches{ct} = {store, batch};
            ct = ct+1;
        end
    end
    
    % for i =1:length(store_batches)
    %     disp(store_batches{i})
    % end
    % assert(false);
    for i=1:length(store_batches)
        store = store_batches{i}{1};
        batch = store_batches{i}{2};

        % HACK, to just do one batch
        % % disp(strcmp(store, 'RSn2'))
        % % disp(strcmp(batch, '1'))
        % if ~strcmp(store, 'RSn3') | ~strcmp(batch, '4')
        %     continue
        % end

    % for i=1:length(stores)
    %     store = stores{i};

    %     for j=1:length(batches)
    %         batch = num2str(batches(j));

        batchHeader = [store '_batch' batch]; % file header of each batch's folder/.bin
        batch_data_path = [day_folder_path batchHeader];

        ops = struct;
        ops.trange    = [0 Inf]; % time range to sort
        ops.NchanTOT  = channelsPerBatch; % total number of channels in your recording

        % ops = kilosortConfigFn(ops);
        run(fullfile(config_file_path))
        ops.fproc   = fullfile(batch_data_path, 'temp_wh.dat'); % proc file on a fast SSD
        ops.chanMap = fullfile(chanmap_file_path);

        % this block runs all the steps of the algorithm
        fprintf('Looking for data inside %s \n', batch_data_path)

        % main parameter changes from Kilosort2 to v2.5
        ops.sig        = 20;  % spatial smoothness constant for registration
        ops.fshigh     = 300; % high-pass more aggresively
        ops.nblocks    = 0; % blocks for registration. 0 turns it off, 1 does rigid registration. Replaces "datashift" option.

        % is there a channel map file in this folder?fuse: mountpoint is not empty

        % NOTE: commenting out bc of line 18, to fix crashing issue
        %
        % fs = dir(fullfile(rootZ, '*chanMap.mat'));
        % if ~isempty(fs)
        %     ops.chanMap = fullfile(rootZ, fs(1).name);
        % end

        % find the binary file
        fs          = dir(fullfile(batch_data_path, '*.bin'));
        ops.fbinary = fullfile(batch_data_path, fs(1).name);

        % preprocess data to create temp_wh.dat
        rez = preprocessDataSub(ops);

        %%% Sanity checks (becuase rez.ops is modified hidden within above code)
        assert(channelsPerBatch == rez.ops.NchanTOT)

        %%% SAVE REZ.OPS (this is the final version)
        ops = rez.ops;
        save([batch_data_path filesep 'ops.mat'], 'ops');
        disp('Final ops:')
        disp(ops);

        % NEW STEP TO DO DATA REGISTRATION
        rez = datashift2(rez, 1); % last input is for shifting data
        % rez.iorig = 1:rez.temp.Nbatch;batch_data_path

        % ORDER OF BATCHES IS NOW RANDOM, controlled by random number generator
        iseed = 1;

        % main tracking and template matching algorithm
        rez = learnAndSolve8b(rez, iseed);

        % OPTIONAL: remove double-counted spikes - solves issue in which individual spikes are assigned to multiple templates.
        % See issue 29: https://github.com/MouseLand/Kilosort/issues/29
        %rez = remove_ks2_duplicate_spikes(rez);

        % final merges
        rez = find_merges(rez, 1);

        % final splits by SVD
        rez = splitAllClusters(rez, 1);

        % decide on cutoff
        rez = set_cutoff(rez);
        % eliminate widely spread waveforms (likely noise)
        rez.good = get_good_units(rez);

        fprintf('found %d good units \n', sum(rez.good>0))

        % write to Phy
        fprintf('Saving results to Phy  \n')
        rezToPhy(rez, batch_data_path);

        %% if you want to save the results to a Matlab file...

        % discard features in final rez file (too slow to save)
        rez.cProj = [];
        rez.cProjPC = [];

        % final time sorting of spikes, for apps that use st3 directly
        [~, isort]   = sortrows(rez.st3);
        rez.st3      = rez.st3(isort, :);

        % Ensure all GPU arrays are transferred to CPU side before saving to .mat
        rez_fields = fieldnames(rez);
        for k = 1:numel(rez_fields)
            field_name = rez_fields{k};
            if(isa(rez.(field_name), 'gpuArray'))
                rez.(field_name) = gather(rez.(field_name));
            end
        end

        % save final results as rez2
        fprintf('Saving final results in rez2  \n')
        fname = fullfile(batch_data_path, 'rez2.mat');
        save(fname, 'rez', '-v7.3');
        
        % delete .bin file to conserve space
        %delete([batch_data_path batch_header '.bin'])
        
        % move temp_wh.dat file to /data5 to conserve space
        %data5_backup_path = ['/data5/Kedar/neural_spike_sorting/kilosort_data/' animal '/' ddate '/' batchHeader];
        %mkdir(data5_backup_path)

        %movefile([batch_data_path '/' batchHeader '_export.txt'], data5_backup_path)
        
        if true
            delete([batch_data_path '/' batchHeader '.bin'])
            %movefile([batch_data_path '/temp_wh.dat'], data5_backup_path)
        else
            % LT 5/29/23, just in case need to rerun.
            %movefile([batch_data_path '/' batchHeader '.bin'], data5_backup_path)
        end
        
        % save some memory
        clearvars rez;
        
    end
% end  
    exitcode="success";
    fid = fopen(fullfile(day_folder_path, 'KS_done.txt'), 'w');
    fclose(fid);

    dateNum = str2num(ddate)
    kspostprocess_extract(animal, dateNum)
    kspostprocess_metrics_and_label(animal, dateNum)
    
    % finally, delete temp_wh.dat if successfully extracted
    SAVEDIR_FINAL_SERVER = ['/mnt/Freiwald/kgupta/neural_data/postprocess/final_clusters/' animal '/' dateNum];
    if isfile([SAVEDIR_FINAL_SERVER '/DONE_kspostprocess_metrics_and_label.mat'])
    for i=1:length(store_batches)
        store = store_batches{i}{1};
        batch = store_batches{i}{2};
        batchHeader = [store '_batch' batch]; % file header of each batch's folder/.bin
        batch_data_path = [day_folder_path batchHeader];
        delete([batch_data_path '/temp_wh.dat'])
    end

    % after this, run manually: kspostprocess_CURATE (makes guis with kspp_manual_curate_merge, and then updates dataset with kspp_finalize_after_manual)
end