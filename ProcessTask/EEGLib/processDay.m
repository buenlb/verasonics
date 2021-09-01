%%
clear all; close all; clc;
expPath = 'C:\Users\Taylor\Documents\Data\Task\EEG\';
fNameBase = 'Euler_210215';

[t,eeg,dig,alg] = concatIntan(expPath,fNameBase);

%% Find Task Indices
taskIdx = findTaskIdxOld(t,dig);

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
save([expPath,fNameBase,'_filtered'],'eeg','eegFiltCorrected','t','dig','alg');

%% 
fName = '/Users/Taylor/Documents/Data/Task/Euler20210215.mat';
trialD = load(fName);
[sigmoids,taskData] = analyzeTaskData(fName);
thresh = 100e-3;
for ii = 1:length(taskIdx)
    if ii < length(taskIdx)
        leftTarg = alg(2,taskIdx(ii):taskIdx(ii+1));
        rightTarg = alg(1,taskIdx(ii):taskIdx(ii+1));
    else
        leftTarg = alg(2,taskIdx(ii):end);
        rightTarg = alg(1,taskIdx(ii):end);
    end
    
    % Get rid of DC by subtracting out average of first 10 ms
    leftTarg = leftTarg-mean(leftTarg(1:10e-3*20e3));
    rightTarg = rightTarg-mean(rightTarg(1:10e-3*20e3));
    
    leftOn = find(leftTarg>thresh);
    rightOn = find(rightTarg>thresh);
    
    if isempty(leftOn)
        firstTarg(ii) = nan;
        computedDelay(ii) = nan;
    else
        leftOnIdx(ii) = taskIdx(ii)-1+leftOn(1);
        rightOnIdx(ii) = taskIdx(ii)-1+rightOn(1);
        leftOnTime = t(leftOnIdx(ii));
        rightOnTime = t(rightOnIdx(ii));
        if leftOnTime < rightOnTime
            firstTarg(ii) = -1;
        else
            firstTarg(ii) = 1;
        end
        computedDelay(ii) = rightOnTime-leftOnTime;
    end
    
    % Check with trial_data struct
    if strcmp(trialD.trial_data{ii}.result{1},'FIXBREAK') || ...
            strcmp(trialD.trial_data{ii}.result{1},'NOFIX')
        if ~isnan(firstTarg(ii))
            warning('Trial struct and EEG disagree!')
            keyboard
        end
    elseif trialD.trial_data{ii}.timingOffset < 0
        if firstTarg(ii) ~= 1
            warning('Trial struct and EEG disagree!')
            keyboard
        end
    elseif trialD.trial_data{ii}.timingOffset > 0
        if firstTarg(ii) ~= -1
            warning('Trial struct and EEG disagree!')
            keyboard
        end
    else
        firstTarg(ii) = 0;
    end
    delay(ii) = trialD.trial_data{ii}.timingOffset;
end

%% Some results
disp('Requested vs Actual Delays')
for ii = 1:length(trialD.trial_data{1}.target_timing_offset_vector)
    idx = find(delay==trialD.trial_data{1}.target_timing_offset_vector(ii));
    disp(['Requested: ', num2str(trialD.trial_data{1}.target_timing_offset_vector(ii)),...
        ', Actual: ', num2str(1e3*mean(computedDelay(idx),'omitnan')), '+/-', num2str(1e3*std(computedDelay(idx),[],'omitnan'))])
end

%% Process EEG Data
recordLength = ceil(500e-3*20e3);
leftEeg = zeros(2,sum(firstTarg==-1),recordLength);
rightEeg = zeros(2,sum(firstTarg==1),recordLength);
bothEeg = zeros(2,sum(firstTarg==0),recordLength);
rightDelay = zeros(1,sum(firstTarg==1));
leftDelay = zeros(1,sum(firstTarg==-1));
rightIdx = 1;
leftIdx = 1;
bothIdx = 1;
for ii = 1:length(firstTarg)
    if taskData.lgn(ii)
        if firstTarg(ii) > 0
            rightEeg(:,rightIdx,:) = eegFiltCorrected(:,rightOnIdx(ii):rightOnIdx(ii)+recordLength-1);
            rightDelay(rightIdx) = delay(ii);
            rightIdx = rightIdx+1;
        elseif firstTarg(ii) < 0
            leftEeg(:,leftIdx,:) = eegFiltCorrected(:,leftOnIdx(ii):leftOnIdx(ii)+recordLength-1);
            leftDelay(leftIdx) = delay(ii);
            leftIdx = leftIdx+1;
        elseif firstTarg(ii) == 0
            bothEeg(:,bothIdx,:) = eegFiltCorrected(:,leftOnIdx(ii):leftOnIdx(ii)+recordLength-1);
            bothIdx = bothIdx+1;       
        end
    end
end

%%
h = figure;
subplot(121)
plot((t(1:recordLength)-t(1))*1e3,squeeze(mean(leftEeg,2,'omitnan')),'linewidth',2)
xlabel('time (ms)')
ylabel('voltage (\muV)')
legend('Right Pin','Left Pin')
title('Left Target')
makeFigureBig(h);

subplot(122)
plot((t(1:recordLength)-t(1))*1e3,squeeze(mean(rightEeg,2,'omitnan')),'linewidth',2)
xlabel('time (ms)')
legend('Right Pin','Left Pin')
title('Right Target')
makeFigureBig(h);

subplot(121)
plot((t(1:recordLength)-t(1))*1e3,squeeze(mean(leftEeg(1,:,:),2,'omitnan')),'linewidth',2)
hold on
plot((t(1:recordLength)-t(1))*1e3,squeeze(mean(rightEeg(2,:,:),2,'omitnan')),'linewidth',2)
xlabel('time (ms)')
ylabel('voltage (\muV)')
legend('Right Pin','Left Pin')
title('Contralateral')
makeFigureBig(h);

subplot(122)
plot((t(1:recordLength)-t(1))*1e3,squeeze(mean(rightEeg(1,:,:),2,'omitnan')),'linewidth',2)
hold on
plot((t(1:recordLength)-t(1))*1e3,squeeze(mean(leftEeg(2,:,:),2,'omitnan')),'linewidth',2)
xlabel('time (ms)')
legend('Right Pin','Left Pin')
title('Ipsilateral')
makeFigureBig(h);

axLimits = [0,500,-15,15];
h = figure;
subplot(321)
ax = gca;
shadedErrorBar((t(1:recordLength)-t(1))*1e3,squeeze(mean(leftEeg(1,leftDelay==60,:),2,'omitnan')),squeeze(std(leftEeg(1,leftDelay==60,:),[],2,'omitnan')),'lineprops',{'linewidth',2,'Color',ax.ColorOrder(1,:)})
hold on
shadedErrorBar((t(1:recordLength)-t(1))*1e3,squeeze(mean(rightEeg(2,rightDelay==-60,:),2,'omitnan')),squeeze(std(rightEeg(2,rightDelay==-60,:),[],2,'omitnan')),'lineprops',{'linewidth',2,'Color',ax.ColorOrder(2,:)})
plot([60,60],axLimits(3:4),'k--','linewidth',2)
xlabel('time (ms)')
ylabel('voltage (\muV)')
legend('Right Pin','Left Pin','2nd Target')
title('Contralateral, 60 ms Delay')
axis(axLimits);
makeFigureBig(h);

subplot(323)
shadedErrorBar((t(1:recordLength)-t(1))*1e3,squeeze(mean(leftEeg(1,leftDelay==30,:),2,'omitnan')),squeeze(std(leftEeg(1,leftDelay==30,:),[],2,'omitnan')),'lineprops',{'linewidth',2,'Color',ax.ColorOrder(1,:)})
hold on
shadedErrorBar((t(1:recordLength)-t(1))*1e3,squeeze(mean(rightEeg(2,rightDelay==-30,:),2,'omitnan')),squeeze(std(leftEeg(1,leftDelay==60,:),[],2,'omitnan')),'lineprops',{'linewidth',2,'Color',ax.ColorOrder(2,:)})
plot([30,30],axLimits(3:4),'k--','linewidth',2)
xlabel('time (ms)')
ylabel('voltage (\muV)')
title('Contralateral, 30 ms Delay')
axis(axLimits);
makeFigureBig(h);

subplot(325)
shadedErrorBar((t(1:recordLength)-t(1))*1e3,squeeze(mean(bothEeg(1,:,:),2,'omitnan')),squeeze(std(leftEeg(1,leftDelay==60,:),[],2,'omitnan')),'lineprops',{'linewidth',2,'Color',ax.ColorOrder(1,:)})
hold on
shadedErrorBar((t(1:recordLength)-t(1))*1e3,squeeze(mean(bothEeg(2,:,:),2,'omitnan')),squeeze(std(leftEeg(1,leftDelay==60,:),[],2,'omitnan')),'lineprops',{'linewidth',2,'Color',ax.ColorOrder(2,:)})
xlabel('time (ms)')
ylabel('voltage (\muV)')
title('Contralateral, 0 ms Delay')
axis(axLimits);
makeFigureBig(h);

subplot(322)
shadedErrorBar((t(1:recordLength)-t(1))*1e3,squeeze(mean(leftEeg(2,leftDelay==60,:),2,'omitnan')),squeeze(std(leftEeg(1,leftDelay==60,:),[],2,'omitnan')),'lineprops',{'linewidth',2,'Color',ax.ColorOrder(1,:)})
hold on
shadedErrorBar((t(1:recordLength)-t(1))*1e3,squeeze(mean(rightEeg(1,rightDelay==-60,:),2,'omitnan')),squeeze(std(leftEeg(1,leftDelay==60,:),[],2,'omitnan')),'lineprops',{'linewidth',2,'Color',ax.ColorOrder(2,:)})
plot([60,60],axLimits(3:4),'k--','linewidth',2)
xlabel('time (ms)')
ylabel('voltage (\muV)')
title('Ipsilateral, 60 ms Delay')
axis(axLimits);
makeFigureBig(h);

subplot(324)
shadedErrorBar((t(1:recordLength)-t(1))*1e3,squeeze(mean(leftEeg(2,leftDelay==30,:),2,'omitnan')),squeeze(std(leftEeg(1,leftDelay==60,:),[],2,'omitnan')),'lineprops',{'linewidth',2,'Color',ax.ColorOrder(1,:)})
hold on
shadedErrorBar((t(1:recordLength)-t(1))*1e3,squeeze(mean(rightEeg(1,rightDelay==-30,:),2,'omitnan')),squeeze(std(leftEeg(1,leftDelay==60,:),[],2,'omitnan')),'lineprops',{'linewidth',2,'Color',ax.ColorOrder(2,:)})
plot([30,30],axLimits(3:4),'k--','linewidth',2)
xlabel('time (ms)')
ylabel('voltage (\muV)')
title('Ipsilateral, 30 ms Delay')
axis(axLimits);
makeFigureBig(h);
