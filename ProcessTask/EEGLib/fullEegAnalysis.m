function eegOut = fullEegAnalysis(pth,baseName,tData)

%% Load Raw EEG Data
if pth(end)~='\'
    pth(end+1) = '\';
end
files = dir([pth,baseName,'*.rhs']);

eegIn = struct('eeg',[],'dig',[],'t',[]);
notches = [60,120,180];
for ii = 1:length(files)
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
[t,zIdx] = alignEegSpectra({eegIn.t},tData,{taskIdx},{trId});
t = t{1};
eegIn.zIdx = zIdx;
eegIn.zeroT = eegIn.t(zIdx);

%% Find Features (Jan)
% frequencies = [1 : 1 : 19, 20 : 2 : 38, 40 : 4 : 76, 80 : 8 : 320];
% spike_thrs = [4i, 5i]; %uV; imaginary values stand for the number of sigmas to be exceeded (e.g., 5i: abs(signal) > 5 sigma)
% %frequencies = [2 : 2 : 320];
% frequency_bands = cell(size(frequencies));
% for f = 1 : numel(frequencies)
%     frequency_bands{f} = [frequencies(f) - 1, frequencies(f) + 1];
% end
% 
% rereference = ''; %'' or 'CAR'
% windowdur = 0.1;
% 
% data.amplifier_data = eegIn.eeg;
% [features, tFeatures] = derive_features(data,frequency_bands,[],windowdur,rereference);
% tFeatures = tFeatures-eegIn.zeroT;
% 
% featuresChannelsAveraged = nan(size(features,1)/2,size(features,2),2);
% featuresChannelsAveraged(:,:,1) = features(1:length(frequencies),:);
% featuresChannelsAveraged(:,:,2) = features(length(frequencies)+1:end,:);
% featuresChannelsAveraged = mean(featuresChannelsAveraged,3,'omitnan');

%% Find Features (Taylor)
windowdur = 0.1;

tAligned = alignEegSpectra({tEeg},tData(ii),taskIdx(ii),trId(ii));
spectra = eegSpectra({tAligned},{eegIn.eeg},windowDur);

featuresChannelsAveraged = mean(spectra.all0to100,1,'omitnan');
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
eegOut = struct('features',featuresChannelsAveraged,'tFeatures',tFeatures,...
    'frequencies',frequencies,'windowDur',windowdur,'notches',notches,...
    'eegIn',eegIn);

