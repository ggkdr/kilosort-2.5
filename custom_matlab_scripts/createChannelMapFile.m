%  create a channel map file
% 
Nchannels = 64;
connected = true(Nchannels, 1);
chanMap   = 1:Nchannels;
chanMap0ind = chanMap - 1;
xcoords   = 400*[1:Nchannels]; % spacing by 100, to make recognized as separate channels.. %ones(Nchannels,1);
ycoords   = 400*[1:Nchannels]'; % spacing by 100 to make recognized as separate channels
kcoords   = [1:Nchannels]; % grouping of channels (i.e. tetrode groups)

fs = 24414.0625; % sampling frequency
save('/data3/Kedar/neural_sink/spike_sorting/kilosort/RSn3_chanMap.mat', ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs')

%
% 
% Nchannels = 256;
% connected = true(Nchannels, 1);
% chanMap   = 1:Nchannels;
% chanMap0ind = chanMap - 1;
% 
% xcoords   = repmat([1 2 3 4]', 1, Nchannels/4);
% xcoords   = xcoords(:);
% ycoords   = repmat(1:Nchannels/4, 4, 1);
% ycoords   = ycoords(:);
% kcoords   = ones(Nchannels,1); % grouping of channels (i.e. tetrode groups)
% 
% fs = 24414.0625; % sampling frequency
% 
% save('/home/kgg/Desktop/spikesorting_kilosort/sample_data/220716_RSn2_1to32/RSn2_chanMap2.mat', ...
%     'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs')
%

% kcoords is used to forcefully restrict templates to channels in the same
% channel group. An option can be set in the master_file to allow a fraction 
% of all templates to span more channel groups, so that they can capture shared 
% noise across all channels. This option is

% ops.criterionNoiseChannels = 0.2; 

% if this number is less than 1, it will be treated as a fraction of the total number of clusters

% if this number is larger than 1, it will be treated as the "effective
% number" of channel groups at which to set the threshold. So if a template
% occupies more than this many channel groups, it will not be restricted to
% a single channel group. 
