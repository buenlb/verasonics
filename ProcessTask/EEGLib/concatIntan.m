function [t,eeg,dig,alg] = concatIntan(path,baseName)

%% Find total number of files
files = dir([path,baseName,'*.rhs']);
files = files(1:end-1);
if isempty(files)
    t = [];
    eeg = [];
    dig = [];
    alg = [];
    return
end
disp(['Loading ', num2str(length(files)), ' data files.'])



for ii = 1:length(files)
    disp(['  File ', num2str(ii), ': ', files(ii).name])
    % dig: 2xN vector of digital chanel recordings
    % eeg: 2xN vector of eeg data
    % t: sample times
    [tTmp,eegTmp,digTmp,algTmp] = loadIntanData(path,files(ii).name);
    if ii == 1
        t = tTmp;
        eeg = eegTmp;
        dig = digTmp;
        alg = algTmp;
    else
        t(:,end+1:end+size(tTmp,2)) = tTmp;
        eeg(:,end+1:end+size(tTmp,2)) = eegTmp;
        dig(:,end+1:end+size(tTmp,2)) = digTmp;
        alg(:,end+1:end+size(tTmp,2)) = algTmp;
    end
end
