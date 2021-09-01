%%
% clear all; close all; clc;
clear all; clc;
expPath = 'F:\EulerEEG\';
fNameBase = 'Euler_210412';

[t,eeg,dig,alg] = concatIntan(expPath,fNameBase);

%% Find Task Indices
[taskIdx,trNum] = findTaskIdx(t,dig(2,:));
trNum = trNum-1;

%% Filter diode signal
if 0
    disp('Filtering Diode Signal...')
    tic
    [alg,delay] = processPhotoDiodeData(alg);
    toc
    disp(['Filtering complete. Delay = ', num2str(t(delay)*1e3), 'ms'])
end
%% Specify Filter and Compute Delay
lp = 40;
hp = 5;
wp = [2 hp lp 50];
mags = [0,1,0];
devs = [0.2 0.01 0.2];
[n,wn,beta,fType] = kaiserord(wp,mags,devs,20e3);
n = n+rem(n,2);
myFilt = fir1(n,wn,fType,kaiser(n+1,beta),'scale');
delay = mean(grpdelay(myFilt,size(eeg,2),20e3));

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
% save([expPath,fNameBase,'_filtered'],'eeg','eegFiltCorrected','t','dig','alg');

%% Process task data
fName = '/Users/Taylor/Documents/Data/Task/Euler20210412.mat';
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
eegLength = round(300e-3*Fs);

% Set up variables
Fs = 20e3;
leftOnT = zeros(size(taskIdx));
rightOnT = zeros(size(taskIdx));
firstTargOn = zeros(size(taskIdx));
eegRight = zeros(length(taskIdx),eegLength);
eegLeft = zeros(length(taskIdx),eegLength);
eegRightFp = eegRight;
eegLeftFp = eegLeft;
eegRightUs = eegRight;
eegLeftUs = eegLeft;
diodeDelay = zeros(size(trialD.trial_data));
diodeOnIdx = zeros(size(trialD.trial_data,1),2);
usOnIdx = zeros(size(trialD.trial_data));

% Determine how to synchronize signals
SYNC_TO_CODE = 0;

% Loop through trials
for ii = 1:length(trialD.trial_data)
    idx = find(trialD.trial_data{ii}.trial_id == trNum);
    if isempty(idx)
        continue
    end
    

    thresh = 100e-3;
    if idx<length(taskIdx)
        trIdx = taskIdx(idx):taskIdx(idx+1);
    else
        trIdx = taskIdx(idx):size(alg,2);
    end
    timing = syncIntanSignals(t(trIdx),dig(1,trIdx),alg(:,trIdx));
    if isempty(timing.targetDelay)
        diodeDelay(ii) = nan;
    else
        diodeDelay(ii) = timing.targetDelay;
    end

    if isempty(timing.diodeOnIdx)
        diodeOnIdx(ii,:) = nan;
    else
        diodeOnIdx(ii,:) = timing.diodeOnIdx;
    end

    if isempty(timing.usOnIdx)
        usOnIdx(ii) = nan;
    else
        usOnIdx(ii) = timing.usOnIdx;
    end

    % Pull out synced EEG data
    % FP On
    fpIdx = taskIdx(idx):taskIdx(idx)+eegLength-1;
    if fpIdx(end)>length(t)
        continue
    end
    eegRightFp(ii,:) = eegFiltCorrected(rightEegIdx,fpIdx);
    eegLeftFp(ii,:) = eegFiltCorrected(leftEegIdx,fpIdx);

    if max(eegRightFp(ii,:)) > 100
        eegRightFp(ii,:) = nan;
    end
    if max(eegLeftFp(ii,:)) > 100
        eegLeftFp(ii,:) = nan;
    end

    timing = processTiming(trialD.trial_data{ii});
    fTargetTime = timing.eventTimes(3)-timing.eventTimes(1);
    if isnan(fTargetTime)
        eegRight(ii,:) = nan;
        eegLeft(ii,:) = nan;
        continue
    end

    fTargetIdx = round(fTargetTime*Fs+taskIdx(idx)):round(fTargetTime*Fs+taskIdx(idx)+eegLength-1);
    
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
    
%     if tData.lgn(ii)
%         keyboard
%     end

end
%% Plot results
% Time vector
tA = t(1:eegLength);
tA = tA-tA(1);

h = figure;
ax = gca;
hold on
plotVep(tA,eegLeftFp,1,ax,{'Color',ax.ColorOrder(1,:),'linewidth',2})
plotVep(tA,eegRightFp,1,ax,{'Color',ax.ColorOrder(2,:),'linewidth',2})
legend('Left Pin','Right Pin')
xlabel('time (ms)')
ylabel('voltage (\muV)')
title('Response to Fixation Point')
makeFigureBig(h);
%%
[l,r] = sortTrialsBySonication(tData.lgn);

side = r;

idx = side{1};
idx = idx(idx<=length(taskIdx));
idx2 = side{2};
idx2 = idx2(idx2<=length(taskIdx));
% idx3 = side{3};
% idxOther = [];
% for ii = 4:length(side)
%     idxOther = cat(1,idxOther,l{ii},r{ii});
% end
% idxOther = idxOther(idxOther<=length(taskIdx));
% idxOther = idx3;

% h = figure;
% subplot(211)
% ax = gca;
% hold on
% plotVep(tA,eegLeftFp(idx,:),1,ax,{'Color',ax.ColorOrder(1,:),'linewidth',2});
% plotVep(tA,eegLeftFp(idx2,:),1,ax,{'Color',ax.ColorOrder(2,:),'linewidth',2});
% plotVep(tA,eegLeftFp(idxOther,:),1,ax,{'Color',ax.ColorOrder(3,:),'linewidth',2});
% legend('1 Trial After','2 Trials After','All Other Non-Sonication Trials')
% ylabel('voltage (\muV)')
% title('Left Pin')
% makeFigureBig(h);
% 
% subplot(212)
% ax = gca;
% plotVep(tA,eegRightFp(idx,:),1,ax,{'Color',ax.ColorOrder(1,:),'linewidth',2});
% plotVep(tA,eegRightFp(idx2,:),1,ax,{'Color',ax.ColorOrder(2,:),'linewidth',2});
% plotVep(tA,eegRightFp(idxOther,:),1,ax,{'Color',ax.ColorOrder(3,:),'linewidth',2});
% xlabel('time (ms)')
% title('Right Pin')
% makeFigureBig(h)
% h.Position = [0.3306    0.1962    1.3184    0.4200]*1e3;

% Average both pins
eegAvg1 = cat(1,eegLeftFp(idx,:),eegRightFp(idx,:));
eegAvg2 = cat(1,eegLeftFp(idx2,:),eegRightFp(idx2,:));
% eegAvgOther = cat(1,eegLeftFp(idxOther,:),eegRightFp(idxOther,:));

[h1,p1] = findSignificanceVEPs(eegAvg1,eegAvg2,1);

tmpH = zeros(size(h1));
tmpH([diff(h1);0]>0) = 1;
idxOn = find(tmpH);

tmpH = zeros(size(h1));
tmpH([diff(h1);0]<0) = 1;
idxOff = find(tmpH);

h = figure;
ax = gca;
[eeg1,sem1] = plotVep(1e3*tA,eegAvg1,1,ax,{'Color',ax.ColorOrder(1,:),'linewidth',2});
[eeg2,sem2] = plotVep(1e3*tA,eegAvg2,1,ax,{'Color',ax.ColorOrder(2,:),'linewidth',2});
% [eeg3,sem3] = plotVep(1e3*tA,eegAvgOther,1,ax,{'Color',ax.ColorOrder(3,:),'linewidth',2});
hold on
for ii = 1:length(idxOn)
    f = fill(1e3*[tA(idxOn(ii)),tA(idxOn(ii)),tA(idxOff(ii)),tA(idxOff(ii))],[ax.YLim,ax.YLim(2:-1:1)],'k');
    f.EdgeAlpha = 0.3;
    f.FaceAlpha = 0.3;
end
xlabel('time (ms)')
title('Both Pins')
% legend('Following Right Sonication','Following Left Sonication','At least 3 trials after a sonication')
legend('Following Right Sonication','Following Left Sonication')
makeFigureBig(h)

