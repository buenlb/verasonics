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

function [eegOut] = fullEegAnalysis2(pth,baseName,tData,varargin)

eegOut = struct('features',[],'tFeatures',[],'frequencies',[],...
    'windowDur',[],'notches',[],'eegIn',[],'featuresByPins',[]);

%% Load Raw EEG Data
if pth(end)~='\'
    pth(end+1) = '\';
end
files = dir([pth,baseName,'*.rhs']);

if isempty(files)
    return
end

eegIn = struct('eeg',[],'dig',[],'t',[]);
notches = [60,120,180,240,320];
disp('  Loading Files...')
for ii = 1:length(files)
    data = read_Intan_RHS2000_file_JK([pth,files(ii).name],notches);
    
    eegIn.eeg = cat(2,eegIn.eeg,data.amplifier_data);
    eegIn.dig = cat(2,eegIn.dig,data.board_dig_in_data);
    eegIn.t = cat(2,eegIn.t,data.t);
end

%% Find trial times
disp('  Finding Trial Indices...')
if size(eegIn.dig,1)<2
    warning('Binary Coding for trial number on different channel than expected')
    bCodeIdx = 1;
else
    bCodeIdx = 2;
end
[taskIdx,trId] = findTaskIdx(eegIn.t,eegIn.dig(bCodeIdx,:));

%% Set US On to t=0. 
% If the function discovers anything other than a single sonication, return
% an empty EEG struct. Re-throw any other errors
disp('  Finding Sonication...')
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

windowdur = 0.5;

%% Find Features (Taylor)
disp('  Finding Features...')
tAligned = alignEegSpectra({eegIn.t},tData,{taskIdx},{trId});
spectra = eegSpectra(tAligned,{eegIn.eeg},windowdur,0.5,500);

featuresChannelsAveraged = squeeze(mean(spectra.all0to100,1,'omitnan')).';
tFeatures = spectra.windowTime;
frequencies = spectra.frequencies;

%% Downsample eegIn to include with eegOut
ds = 1e3;
eegIn.eeg = eegIn.eeg(:,1:ds:end);
eegIn.dig = eegIn.dig(:,1:ds:end);
eegIn.t = eegIn.t(1:ds:end)-eegIn.zeroT;
eegIn.taskIdx = taskIdx;
eegIn.trId = trId;

%% Return result
disp('  Returning...')
eegOut = struct('features',featuresChannelsAveraged,'tFeatures',tFeatures,...
    'frequencies',frequencies,'windowDur',windowdur,'notches',notches,...
    'eegIn',eegIn,'featuresByPins',spectra.all0to100);