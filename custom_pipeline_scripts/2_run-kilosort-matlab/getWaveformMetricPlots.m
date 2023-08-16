clear all; close all;

%% LT 4/2/23
% see https://github.com/cortex-lab/spikes/blob/master/exampleScript.m

%% load data from kilosort

% kilosort directory
myKsDir = '/data5/Kedar/neural_spike_sorting/kilosort_data/Pancho-230125-161523/RSn2_batch1';
cd(myKsDir)

% Loading data from kilosort/phy easily
% - sp.st are spike times in seconds
% - sp.clu are cluster identities
% - spikes from clusters labeled "noise" have already been omitted
sp = loadKSdir(myKsDir);

if false
    myEventTimes = load('C:\...\data\someEventTimes.mat'); % a vector of times in seconds of some event to align to
end

%% plot/analyze raw waveforms

% get cluster info that is saved from phy
% - ch contains channels
% - cluster_id contains cluster_ids
% - group contains {'good','mua','noise'} -- clusters manually labeled by me
PLOT_WF = true; % toggle plots on/off
ISI_MS = 0.002;
tdfread('cluster_info.tsv','\t')
group = cellstr(group); % convert from chararray to cellarray

% to store results, for plotting
metric_results_arr = []; % final computed score per cluster
isi_violations_arr = []; % final isi % of violations per cluster
% to store which clusters were actually used
inds_collected = [];

% calculate METRIC
for c=1:length(cluster_id)
    clustget = cluster_id(c);
    chan = ch(c)+1; % NOTE: ch is 0-indexed, matlab is 1-indexed...
    man_label = group{c}; % manual label, i.e. single/mua/noise
    
    gwfparams.dataDir = myKsDir;
    % KiloSort/Phy output folder
    gwfparams.fileName = 'temp_wh.dat';         % .dat file containing the raw 
    gwfparams.dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
    gwfparams.nCh = 64;                      % Number of channels that were streamed to disk in .dat file
    gwfparams.wfWin = [-15 30];              % Number of samples before and after spiketime to include in waveform
    nWf = 200;                               % number of waveforms to sample, if there are enough
    gwfparams.nWf = min(nWf, n_spikes(c));   % sample nWf waveforms, or if fewer exist, sample all
    gwfparams.spikeTimes = ceil(sp.st(sp.clu==clustget)*sp.sample_rate); % Vector of cluster spike times (in samples) same length as .spikeClusters
    gwfparams.spikeClusters = sp.clu(sp.clu==clustget);
        
    % if no spiketimes were saved, then make sure it was a noise channel...
    % (kilosort throws out noise data when saving)
    if isempty(gwfparams.spikeTimes)
        assert(strcmp(man_label, 'noise'));
        disp("skipping cluster_id: " + clustget + ", is noise");
        continue;
    end

    % get waveforms and flatten
    wf = getWaveForms(gwfparams);   
    wf_flat = squeeze(wf.waveForms(:,:, chan, :));
    
    wf_mean = mean(wf_flat, 1); % mean waveform
    ispositive = abs(max(wf_mean))>abs(min(wf_mean)); % whether pos or neg spike
    orig_peak_ind = 1-gwfparams.wfWin(1); % original peak index
    
    % get shifted wf
    wf_flat_shifted = get_shifted_wf(wf_flat, ispositive, orig_peak_ind);
          
    if PLOT_WF
        figure; hold on;
        plot(wf_flat_shifted');
    end

    % calculate mean_std_wf
    peak_trough_std = get_peak_trough_std(wf_flat_shifted);
    
    % and add to results
    metric_results_arr(end+1) = peak_trough_std;
    inds_collected(end+1) = clustget;
    
    % and overlay mean waveform, std waveform on previous plot (all
    % waveforms)
    wf_flat_shifted_mean = mean(wf_flat_shifted);
    wf_flat_shifted_std = std(wf_flat_shifted);
    
    if PLOT_WF
        plot(wf_flat_shifted_mean,'-k','linewidth',4);
        plot(wf_flat_shifted_std,'-r','linewidth',4);
        title("ch:" + chan + ",clust:" + clustget + ",label:" + man_label + ",val:" + peak_trough_std)
        line(xlim(),[0 0]) % 0 line
        
        % save figure
        fig_filename = "score" + peak_trough_std + "_clust" + clustget + "_ch" + chan + "_" + man_label + ".png";
        saveas(gcf, fig_filename)
    end
    
end

% calculate ISI VIOLATIONS
for c=1:length(cluster_id)
    clustget = cluster_id(c);
    chan = ch(c)+1; % NOTE: ch is 0-indexed, matlab is 1-indexed...
    man_label = group{c}; % manual label, i.e. single/mua/noise
    
    gwfparams.dataDir = myKsDir;
    % KiloSort/Phy output folder
    gwfparams.fileName = 'temp_wh.dat';         % .dat file containing the raw 
    gwfparams.dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
    gwfparams.nCh = 64;                      % Number of channels that were streamed to disk in .dat file
    gwfparams.wfWin = [-15 30];              % Number of samples before and after spiketime to include in waveform
    gwfparams.nWf = n_spikes(c);   % sample ALL waveforms, since using ISI violations
    gwfparams.spikeTimes = ceil(sp.st(sp.clu==clustget)*sp.sample_rate); % Vector of cluster spike times (in samples) same length as .spikeClusters
    gwfparams.spikeClusters = sp.clu(sp.clu==clustget);
        
    % if no spiketimes were saved, then make sure it was a noise channel...
    % (kilosort throws out noise data when saving)
    if isempty(gwfparams.spikeTimes)
        assert(strcmp(man_label, 'noise'));
        disp("skipping cluster_id: " + clustget + ", is noise");
        continue;
    end

    % calculate ISI % violations
    spike_times_sec = gwfparams.spikeTimes/sp.sample_rate;
    isi_violation_pct = get_isi_violations(spike_times_sec,ISI_MS); % 3ms
    
    % and add to results
    isi_violations_arr(end+1) = isi_violation_pct; % will be a % e.g. 0.03
    
    if isi_violation_pct >= 0.05
       disp("cluster " + clustget + "isi%" + isi_violation_pct);
    end
    
end

% finally, plot distribution of scores
figure;
histogram(metric_results_arr);
saveas(gcf, "scoredistributionhist.png")

% and metric vs. ISI
figure;
scatter(isi_violations_arr,metric_results_arr);
for i=1:length(inds_collected)
    text(isi_violations_arr(i),metric_results_arr(i),num2str(inds_collected(i)));
end
saveas(gcf, "metric_vs_isi.png");

%% get waveforms that are shifted so that the peaks align.
function [wf_shifted] = get_shifted_wf(wf_input, ispositive, orig_peak_ind)
    
    % if positive spike, temporarily invert
    if ispositive
        wf_input = -wf_input;
    end
    
    % sometimes spikes are misaligned, so get the correct spike peak time
    [~, inds_min_times] = min(wf_input, [], 2);
% Loading data from kilosort/phy easily

    % further subsampling, to pick out just the spike
    npre = 10;
    npost = 15;
    wf_shifted = [];
    
%     disp(inds_min_times);
    for i=1:size(wf_input,1)
        indthis = inds_min_times(i);
        
        % if spike is noise, just keep as is, otherwise will throw error
        if (indthis-npre <= 0) || (indthis+npost > size(wf_input,2)) % i.e. min value is near beginning or end, so probably noise
%             disp(indthis);200
            indthis = orig_peak_ind; % don't shift, keep as is
        end
        
        wfthis = wf_input(i, indthis-npre:indthis+npost);
        % 
        wf_shifted = [wf_shifted; wfthis];
    end
  
    % if positive spike, invert again to get original wf
    if ispositive
        wf_shifted = -wf_shifted;
    end
    
end

%% calculate (peak-trough)/mean_std_wf
% will use mean_wf for all calculations.
function [peak_trough_std] = get_peak_trough_std(wf)
    % first get mean waveform
    mean_wf = mean(wf);
    
    % now get peak-trough
    peak = max(mean_wf);
    trough = min(mean_wf);
    peak_trough = peak-trough;

    % next get std at each timepoint, then the mean of that
    std_wf = std(wf);
    mean_std_wf = mean(std_wf);

    % finally calculate the metric
    peak_trough_std = peak_trough / mean_std_wf;
end

%% calculate % of ISI violations relative to all spikes
%
% spiketimes is arr of spiketimes in SECONDS (not samples)
% threshold is time in SECONDS (i.e. 0.003 for 3 ms)
function [isi_violation_pct] = get_isi_violations(spiketimes,threshold) % waveforms, millisecond threshold
    isi = diff(spiketimes);
    assert(all(isi>=0), "spiketimes array is not chronological")
    violations = sum(isi <= threshold);
    num_isi = length(spiketimes)-1;
    isi_violation_pct = violations/num_isi; 
end

