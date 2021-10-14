function [eegLeft,eegRight,tA,tData] = processEeg2(expPath,taskPath,date,syncTo)
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\lib')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask')

BANDPASS = 0;

fNameBase = ['boltzmannTask_',date.year(end-1:end),date.month,date.day];

[t,eeg,dig,alg] = concatIntan(expPath,fNameBase);
keyboard
%% Find Task Indices
[taskIdx,trNum] = findTaskIdx(t,dig(2,:));
trNum = trNum-1;

%% Remove extraneous data before filtering
newIdx = taskIdx(1):taskIdx(end)+5*20e3;
if newIdx(end) > length(t)
    newIdx = newIdx(newIdx<=length(t));
end
t = t(newIdx);
eeg = eeg(:,newIdx);
dig = dig(:,newIdx);
alg = alg(:,newIdx);

taskIdx = taskIdx-taskIdx(1)+1;

%% Specify Filter and Compute Delay
if BANDPASS
    lp = 40;
    hp = 5;
    wp = [2 hp lp 50];
    mags = [0,1,0];
    devs = [0.2 0.01 0.2];
    [n,wn,beta,fType] = kaiserord(wp,mags,devs,20e3);
    n = n+rem(n,2);
    myFilt = fir1(n,wn,fType,kaiser(n+1,beta),'scale');
    delay = mean(grpdelay(myFilt,size(eeg,2),20e3));

    %% Filter
    eegFilt = zeros(size(eeg));
    eegFiltCorrected = zeros(size(eeg,1),size(eeg,2)-delay);
    for ii = 1:size(eeg,1)
        tic
        disp(['  Filtering Channel ', num2str(ii)])
        eegFilt(ii,:) = filter(myFilt,1,eeg(ii,:));
        eegFiltCorrected(ii,:) = eegFilt(ii,delay+1:end);
        toc
    end
    clear eegFilt;
    t = t(1:end-delay);
    dig = dig(:,1:end-delay);
    alg = alg(:,1:end-delay);
else
    lp = 50;
    hp = 5;
    wp = [lp 75];
    mags = [1,0];
    devs = [0.05 0.1];
    [n,wn,beta,fType] = kaiserord(wp,mags,devs,20e3);
    n = n+rem(n,2);
    myFilt = fir1(n,wn,fType,kaiser(n+1,beta),'scale');
    
    eegFiltCorrected = zeros(size(eeg));
    for ii = 1:size(eeg,1)
        tic
        disp(['  Filtering Channel ', num2str(ii)])
        eegFiltCorrected(ii,:) = filtfilt(myFilt,1,eeg(ii,:));
        toc
    end
end
% save([expPath,fNameBase,'_filtered'],'eeg','eegFiltCorrected','t','dig','alg');

%% Process task data
fName = [taskPath,'Boltzmann',date.year,date.month,date.day,'.mat'];
trialD = load(fName);
if ~isfield(trialD.trial_data{end},'us')
    trialD.trial_data = trialD.trial_data(1:end-1);
end
tData = processTaskData(fName);

%% Process EEG Data
% Sort out pin indices
rightEegIdx = 1;
leftEegIdx = 2;

% Length of eeg signal to keep (seconds*sampling frequency)
Fs = 20e3;
eegLength = round(1200e-3*Fs);

% Set up variables
eegRight = zeros(length(trialD.trial_data),eegLength);
eegLeft = zeros(length(trialD.trial_data),eegLength);

% Loop through trials
for ii = 1:length(trialD.trial_data)
    idx = find(trialD.trial_data{ii}.trial_id == trNum);
    if isempty(idx)
        continue
    end
    
    switch syncTo
        case 'FP'
            % Pull out synced EEG data
            % FP On
            fpIdx = taskIdx(idx):taskIdx(idx)+eegLength-1;
            if fpIdx(end)>length(t)
                continue
            end
            eegRight(ii,:) = eegFiltCorrected(rightEegIdx,fpIdx);
            eegLeft(ii,:) = eegFiltCorrected(leftEegIdx,fpIdx);

            if max(eegRight(ii,:)) > 100
                eegRight(ii,:) = nan;
            end
            if max(eegLeft(ii,:)) > 100
                eegLeft(ii,:) = nan;
            end
        case 'FT'
            timing = processTiming(trialD.trial_data{ii});
            
            fTargetTime = timing.eventTimes(3)-timing.eventTimes(1);
            if isnan(fTargetTime)
                eegRight(ii,:) = nan;
                eegLeft(ii,:) = nan;
                continue
            end

            % Find the time in which to record the EEG. Go back 50 ms since
            % the time stamps won't be instantaneous.
            fTargetIdx = round(fTargetTime*Fs+taskIdx(idx)-200e-3*Fs):round(fTargetTime*Fs+taskIdx(idx)+eegLength-1-200e-3*Fs);

            if fTargetIdx(end)>length(t)
                continue
            end

            eegRight(ii,:) = eegFiltCorrected(rightEegIdx,fTargetIdx);
            eegLeft(ii,:) = eegFiltCorrected(leftEegIdx,fTargetIdx);

            if max(eegRight(ii,:)) > 100
                eegRight(ii,:) = nan;
            end
            if max(eegLeft(ii,:)) > 100
                eegLeft(ii,:) = nan;
            end
        otherwise
            error([syncTo, ' not yet implemented']);
    end
end
% Time vector
tA = t(1:eegLength);
tA = tA-tA(1);