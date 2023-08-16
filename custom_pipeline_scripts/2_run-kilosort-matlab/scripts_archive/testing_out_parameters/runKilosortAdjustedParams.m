%% adapted from /custom_matlab_scripts/runKilosortMain.m
clear all; close all;

%% add paths for Kilosort, other packages
KS_install_path = '/data5/Kedar/neural_spike_sorting/kilosort_installation/';
KS_data_path = '/data5/Kedar/neural_spike_sorting/kilosort_data/params_testing/';

addpath(genpath([KS_install_path 'Kilosort-2.5'])) % path to kilosort folder
addpath([KS_install_path 'npy-matlab']) % for converting to Phy

%% select animal/date/time
% small datasets: Pancho-220528-152957, Pancho-230117-154447
% animal = 'Pancho'; %CHANGE
% date = '230125'; %CHANGE
% time = '161523'; %CHANGE

config_file_path = [KS_install_path 'Kilosort-2.5/custom_matlab_scripts/kilosortConfig.m']; %CHANGE
chanmap_file_path = [KS_data_path 'chanMap64.mat']; %CHANGE

%% run kilosort algorithm using MANY params on one store/batch
%
store = 'RSn2'; %CHANGE
paramsbatch = 1; %CHANGE
databatch = 1;
nChannels = 64;

% Params to vary
session_folders = {'Pancho-230117-154447/'}; %'Pancho-220528-152957/' % e.g. 'Pancho-230125-161523/'
% AUCsplits = [0.90]; %0.85
ThresholdsA = {10 6 5.75 5.5 5.25 5 4};
ThresholdsB = {4 1};
spkThs = {-3 -6};
% lams = [10];

for f=1:length(session_folders)
    session_folder_path = [KS_data_path session_folders{f}];
    
    for i=1:length(ThresholdsA)
        for j=1:length(ThresholdsB)
            Th = [ThresholdsA{i} ThresholdsB{j}];
            
            for k=1:length(spkThs)
                spkTh = spkThs{k};
                
                cd(session_folder_path);
                clear ops;
                % i=0;j=0;k=0;
                batchHeader = [store '_batch' num2str(databatch) '_params' num2str(paramsbatch) '/']; % file header of each batch's folder/.bin
                batch_data_path = [session_folder_path batchHeader];
                results_save_path = [batch_data_path 'Th' num2str(Th(1)) '-' num2str(Th(2)) '_spkTh' num2str(spkTh)];
                mkdir(results_save_path);

                run(fullfile(config_file_path)) % NOTE: loads default ops values

                % set params
                %ops.AUCsplit = AUCsplits(i);
                ops.Th = Th;
                ops.spkTh = spkTh;
                %ops.lam = lams(k);
                ops.trange    = [0 Inf]; % time range to sort
                ops.NchanTOT  = nChannels; % total number of channels in your recording

                ops.fproc   = fullfile(batch_data_path, 'temp_wh.dat'); % proc file on a fast SSD
                ops.chanMap = fullfile(chanmap_file_path);

                % this block runs all the steps of the algorithm
                fprintf('Looking for data inside %s \n', batch_data_path)

                % main parameter changes from Kilosort2 to v2.5
                ops.sig        = 20;  % spatial smoothness constant for registration
                ops.fshigh     = 300; % high-pass more aggresively
                ops.nblocks    = 5; % blocks for registration. 0 turns it off, 1 does rigid registration. Replaces "datashift" option.

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
                % NOTE: since temp_wh.dat already exists, don't need to remake

                %disp(ops);
                %assert(false, "test that ops works");
                
                % on first run, have to make temp_wh.dat file
                if i==1 && j==1 && k==1
                    rez = preprocessDataSub(ops);
                else
                    rez = preprocessDataSubAdjustedParams(ops); % skips temp_wh.dat step
                end

                % NEW STEP TO DO DATA REGISTRATION
                % rez = datashift2(rez, 1); % last input is for shifting data
                rez.iorig = 1:rez.temp.Nbatch;

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
                rez = set_cutoff(rez); % NOTE: this is where it crashes sometimes...
                % eliminate widely spread waveforms (likely noise)
                rez.good = get_good_units(rez);

                fprintf('found %d good units \n', sum(rez.good>0))

                % write to Phy
                fprintf('Saving results to Phy  \n')
                rezToPhy(rez, results_save_path);

                %% if you want to save the results to a Matlab file...

                % discard features in final rez file (too slow to save)
                rez.cProj = [];
                rez.cProjPC = [];

                % final time sorting of spikes, for apps that use st3 directly
                [~, isort]   = sortrows(rez.st3);
                rez.st3      = rez.st3(isort, :);

                % Ensure all GPU arrays are transferred to CPU side before saving to .mat
                rez_fields = fieldnames(rez);
                for ii = 1:numel(rez_fields)
                    field_name = rez_fields{ii};
                    if(isa(rez.(field_name), 'gpuArray'))
                        rez.(field_name) = gather(rez.(field_name));
                    end
                end

                % save final results as rez2
                fprintf('Saving final results in rez2  \n')
                fname = fullfile(results_save_path, 'rez2.mat');
                save(fname, 'rez', '-v7.3');
            end
        end
    end
end