% Processes the eeg data found in [pth,basename*.rhs].
% 
% @INPUTS
%   pth: Path in which the EEG files are located
%   baseName: Basename of the EEG files. This is the base on to which Intan
%     appends the time and date of each file
%   tData: The struct containing resulrs from the session. This is used to
%     identify the trial in which the ultrasound is delivered so that the
%     eeg data can be re-aligned to have t=0 at the start of the ultrasound
%     sonication
% 
% @OUTPUTS
%   eegOut: Struct containing results. Fields listed below
%   @FIELDS:
%     features: Value for EEG rhythms measured in 100 ms windows (this can
%       be changed by setting the variable windowdur
%     tFeatures: the time at which each rhythm is measured (thus the length
%       of features and tFeatures are the same). This vector has been
%       aligned such that the onset of the ultrasound occurs at
%       tFeatures=0.
%     frequencies: The frequencies at which features is measured
%     windowdur: The duration of the time window in which features were
%       measured
%     notches: Frequency values that were filtered out by Jan's notch
%       filter in read_Intan_RHS2000_file_JK
%     eegIn: The raw time, EEG, and dig vectors from the intan, downsampled
%       by a factor of 1e3 to avoid running out of memory when
%       reconstructing multimple sessions.  

function [eegOutJan, eegOutTaylor, eegOutTaylorNT, eegOutTaylorFileIO] = fullEegAnalysis(pth,baseName,tData,COMPARISON)
if ~exist('COMPARISON','var')
    COMPARISON = 0;
end

eegOutJan = [];
eegOutTaylorNT = [];
eegOutTaylorFileIO = [];
eegOutTaylor = [];

%% Load Raw EEG Data
if pth(end)~='\'
    pth(end+1) = '\';
end
files = dir([pth,baseName,'*.rhs']);

if isempty(files)
    return
%     error(['No files found with inquiry: ', pth, baseName, '*.rhs']);
end

eegIn = struct('eeg',[],'dig',[],'t',[]);
notches = [60];
for ii = 1:length(files)
%     disp(['Loading File: ', num2str(ii), ' of ', num2str(length(files))])
    data = read_Intan_RHS2000_file_JK([pth,files(ii).name],notches);
    
    eegIn.eeg = cat(2,eegIn.eeg,data.amplifier_data);
    eegIn.dig = cat(2,eegIn.dig,data.board_dig_in_data);
    eegIn.t = cat(2,eegIn.t,data.t);
end

%% Find trial times
if size(eegIn.dig,1)<2
    warning('Binary Coding for trial number on different channel than expected')
    bCodeIdx = 1;
else
    bCodeIdx = 2;
end
[taskIdx,trId] = findTaskIdx(eegIn.t,eegIn.dig(bCodeIdx,:));

%% Set US On to t=0
try
    [~,zIdx] = alignEegSpectra({eegIn.t},tData,{taskIdx},{trId});
catch me
    if strcmp(me.identifier,'eeg:noSonication')
        return
    elseif strcmp(me.identifier,'eeg:multSonication')
        return
    else
        rethrow(me);
    end
end

eegIn.zIdx = zIdx;
eegIn.zeroT = eegIn.t(zIdx);

windowdur = 0.1;
%% Find Features (Jan)
if COMPARISON
    frequencies = [1 : 1 : 19, 20 : 2 : 38, 40 : 4 : 76, 80 : 8 : 320];
    % spike_thrs = [4i, 5i]; %uV; imaginary values stand for the number of sigmas to be exceeded (e.g., 5i: abs(signal) > 5 sigma)
    %frequencies = [2 : 2 : 320];
    frequency_bands = cell(size(frequencies));
    for f = 1 : numel(frequencies)
        frequency_bands{f} = [frequencies(f) - 1, frequencies(f) + 1];
    end
    
    rereference = ''; %'' or 'CAR'
    
    data.amplifier_data = eegIn.eeg;
    [features, tFeatures] = derive_features(data,frequency_bands,[],windowdur,rereference);
    tFeatures = tFeatures-eegIn.zeroT;
    
    featuresChannelsAveraged = nan(size(features,1)/2,size(features,2),2);
    featuresChannelsAveraged(:,:,1) = features(1:length(frequencies),:);
    featuresChannelsAveraged(:,:,2) = features(length(frequencies)+1:end,:);
    featuresChannelsAveraged = mean(featuresChannelsAveraged,3,'omitnan');
    
    eegOutJan = struct('features',featuresChannelsAveraged,'tFeatures',tFeatures,...
        'frequencies',frequencies,'windowDur',windowdur,'notches',notches);
end

%% Find Features (Taylor)
tAligned = alignEegSpectra({eegIn.t},tData,{taskIdx},{trId});
spectra = eegSpectra(tAligned,{eegIn.eeg},windowdur,0.5,100);

featuresChannelsAveraged = squeeze(mean(spectra.all0to100,1,'omitnan')).';
tFeatures = spectra.windowTime;
frequencies = spectra.frequencies;

%% Find Features (Taylor without thresholding)
if COMPARISON
    tAligned = alignEegSpectra({eegIn.t},tData,{taskIdx},{trId});
    spectra = eegSpectra(tAligned,{eegIn.eeg},windowdur,0.5);
    
    featuresChannelsAveragedNT = squeeze(mean(spectra.all0to100,1,'omitnan')).';
    tFeaturesNT = spectra.windowTime;
    frequenciesNT = spectra.frequencies;
end

%% Downsample eegIn to include with eegOut
ds = 1e3;
eegIn.eeg = eegIn.eeg(:,1:ds:end);
eegIn.dig = eegIn.dig(:,1:ds:end);
eegIn.t = eegIn.t(1:ds:end)-eegIn.zeroT;
eegIn.taskIdx = taskIdx;
eegIn.trId = trId;

eegOutTaylor.eegIn = eegIn;

%%
if COMPARISON
    eegOutTaylorNT = struct('features',featuresChannelsAveragedNT,'tFeatures',tFeaturesNT,...
        'frequencies',frequenciesNT,'windowDur',windowdur,'notches',notches);
end

%% Return result
eegOutTaylor = struct('features',featuresChannelsAveraged,'tFeatures',tFeatures,...
    'frequencies',frequencies,'windowDur',windowdur,'notches',notches,...
    'eegIn',eegIn,'featuresByPins',spectra.all0to100);

%% My File IO
if COMPARISON
    [~,~,~,~,tEeg,eeg,dig,~,trId,taskIdx] =...
                    loadEEGTaskData(pth,baseName,tData);
    
    tAligned = alignEegSpectra({tEeg},tData,{taskIdx},{trId});
    spectra = eegSpectra(tAligned,{eeg},windowdur,0.5,50);
    
    eegIn.eeg = eeg(:,1:ds:end);
    eegIn.dig = dig(:,1:ds:end);
    eegIn.t = tAligned(1:ds:end);
    eegIn.taskIdx = taskIdx;
    eegIn.trId = trId;
    
    featuresChannelsAveraged = squeeze(mean(spectra.all0to100,1,'omitnan')).';
    tFeatures = spectra.windowTime;
    frequencies = spectra.frequencies;
    
    eegOutTaylorFileIO = struct('features',featuresChannelsAveraged,'tFeatures',tFeatures,...
        'frequencies',frequencies,'windowDur',windowdur,'notches',notches,...
        'eegIn',eegIn);
end
