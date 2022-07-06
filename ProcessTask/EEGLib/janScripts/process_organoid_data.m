function [features, time, spikewaveformscell] = process_organoid_data(names)
% Loads in individual segments of Intan data and performs time-frequency and
% spike detection analysis on these data
%
%
%
% Usage example with a wildcart:
%   process_organoid_data({'organoids_2019-03-14_SR2018-03-15_organoid1_sharp*'})

shortUSstimuli = false; %using short ultrasound stimuli
% shortUSstimuli = true; %using short ultrasound stimuli
allchannelsstimulatedsimultaneously = true; %all channels are electrically stimulated at the same time with the same waveform, so need just one channel for timing
rereference = ''; %'' or 'CAR'
savespikewaveforms = false; %adds substantially (several fold) to the saved file

windowdur = 0.5; %s
% windowdur = 0.1; %s
% frequency_bands = { ...
%     [8, 12], ... %Hz; alpha; use 0.5 s window length
%     [13, 30], ... %Hz; beta; use 0.5 s window length
%     [30, 50], ... %Hz; gamma; use 0.2 s window length, possibly 0.1 s if need high temporal precision
%     [70, 110], ... %Hz; high gamma 1 (HG1); circumvents 60 Hz line noise and its 120 Hz harmonic
%     [130, 200]; ... %Hz; high gamma 2 (HG2); 180 Hz is not promient (even multiples of 60 Hz, like 120 Hz and 240 Hz appear to be more prominent)
%     };
%fine frequency bands for frequency plots
%frequencies = [1 : 1 : 19, 20 : 2 : 38, 40 : 4 : 76, 80 : 8 : 154, 160 : 16 : 320];
frequencies = [1 : 1 : 19, 20 : 2 : 38, 40 : 4 : 76, 80 : 8 : 320];
%frequencies = [2 : 2 : 320];
frequency_bands = cell(size(frequencies));
for f = 1 : numel(frequencies)
    frequency_bands{f} = [frequencies(f) - 1, frequencies(f) + 1];
end

spike_thrs = [4i, 5i]; %uV; imaginary values stand for the number of sigmas to be exceeded (e.g., 5i: abs(signal) > 5 sigma)
%spike_thrs = 0 : 1 : 50; %uV
%spike_thrs = 30; %uV

% notch_filter_frequencies = [60, 120, 180, 240, 300]; %filter out harmonics of 60 Hz
notch_filter_frequencies = []; %don't filter out harmonics of 60 Hz

if nargin < 1 %process all directories
    names = dir();
    dirics = find([names.isdir]);
    names = {names(dirics(3 : end)).name};
end

for n = 1 : numel(names)
    name = names{n};
    features = [];
    spikewaveforms = [];
    time = [];
    
    %test for subdirectories
    cd(names{n});
    d = dir;
    if numel(d) > 3 && d(end).isdir
        filenames = dir();
        filenames = filenames(4 : end); %excluding ., .., .DS_Store
    else %no subdirectories
        cd ..;
        if ~strcmp(name(end), '*')
            name(end + 1) = '*'; %add wildcard so that the below code is compatible
        end
        filenames = dir(name); %sorted by time, from oldest to newest, based on wildcart
    end
    K = numel(filenames);
    for k = 1 : K
        stimtrials = struct([]); %needs to be reset for every file since the index points to a specific file
        if numel(filenames(k).name) < 3 || isequal(filenames(k).name(end-2:end),'mat')
            continue; %skip mat files
        end
        fprintf('Loading file %s\n', filenames(k).name);
        try
            %one file per channel Intan format
            data = read_Intan_RHS2000_fileperchannel(filenames(k).name, notch_filter_frequencies, allchannelsstimulatedsimultaneously);
        catch
            %traditional Intan file format
            data = read_Intan_RHS2000_file_JK(filenames(k).name, notch_filter_frequencies); %run without a notch
        end
        
        if shortUSstimuli
            if isfield(data,'board_dig_in_data') && std(data.board_dig_in_data(end, :)) > 0.1
                fprintf('Identifying ultrasound stimuli\n');
                stimtrials = decodeUSstimuli(data.board_dig_in_data, data.frequency_parameters, 5); %5 US parameters
            end
        end
        
        [feats, t, swfs, spikewaveformscell, rms, windowL, overlap, stimtimes, estimtimes] = derive_features(data, frequency_bands, spike_thrs, windowdur, rereference);
        features = [features, feats];
        spikewaveforms = [spikewaveforms; swfs];
        time = [time, t];
    end
    
    if numel(d) > 3 && d(end).isdir
        cd ..;
    end
%    fileout = sprintf('%s%dms.mat', windowdur*1000, name);
    if strcmp(name(end), '*') %remove the wildcart
        name(end) = [];
    end
    fileout = sprintf('%s.mat', name);
    fprintf('%s\n', fileout);
    fs = data.frequency_parameters.amplifier_sample_rate;
    Z = [data.amplifier_channels.electrode_impedance_magnitude]; %impedances
    stds = data.stds;
        
    if savespikewaveforms
        save(fileout, 'Z', 'stds', 'features', 'time', 'frequency_bands', 'spike_thrs', 'spikewaveformscell', 'fs', 'rms', 'windowL', 'overlap', 'stimtrials', 'stimtimes', 'estimtimes');
    else
        save(fileout, 'Z', 'stds', 'features', 'time', 'frequency_bands', 'spike_thrs', 'fs', 'rms', 'windowL', 'overlap', 'stimtrials', 'stimtimes', 'estimtimes');
    end
end