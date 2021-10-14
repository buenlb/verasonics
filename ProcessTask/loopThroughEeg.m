clear; close all; clc;
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\lib')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\lib\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\EEGLib\')
% expPath = 'F:\EulerEEG\';
expPath = 'C:\Users\Taylor\Documents\Data\Task\Boltzmann\EEG\';
% date(1) = struct('year','2021','month','04','day','09');
% date(2) = struct('year','2021','month','04','day','12');
% date(3) = struct('year','2021','month','04','day','13');
% date(4) = struct('year','2021','month','05','day','04');
% date(5) = struct('year','2021','month','05','day','11');
% date(6) = struct('year','2021','month','05','day','13');
% date(7) = struct('year','2021','month','05','day','14');
% date(8) = struct('year','2021','month','05','day','17');
% date(9) = struct('year','2021','month','05','day','18');
% date(10) = struct('year','2021','month','05','day','20');
% date(11) = struct('year','2021','month','05','day','21');
% date(12) = struct('year','2021','month','05','day','24');
% date(13) = struct('year','2021','month','05','day','27');
% date(14) = struct('year','2021','month','05','day','31');
% date(15) = struct('year','2021','month','06','day','01');
% date(16) = struct('year','2021','month','06','day','02');
% date(17) = struct('year','2021','month','06','day','04');
% date(18) = struct('year','2021','month','06','day','10');
% date(19) = struct('year','2021','month','06','day','15');
% date(20) = struct('year','2021','month','06','day','21');
date(1) = struct('year','2021','month','10','day','08');
taskPath = 'C:/Users/Taylor/Documents/Data/Task/Boltzmann/';

eegLeftCell = cell(1,length(date));
eegRightCell = cell(1,length(date));
totalTrials = 0;
for ii = 1:length(date)
    [eegLeftCell{ii},eegRightCell{ii},tA,tData(ii)] = processEeg2(expPath,taskPath,date(ii),'FT');
    totalTrials = totalTrials+size(eegLeftCell{ii},1);
end
%%
eegLeft = zeros(totalTrials,size(eegLeftCell{1},2));
eegRight = zeros(totalTrials,size(eegLeftCell{1},2));
curTrials = 0;
for ii = 1:length(date)
    eegLeft(curTrials+1:curTrials+size(eegLeftCell{ii},1),:) = eegLeftCell{ii};
    eegRight(curTrials+1:curTrials+size(eegRightCell{ii},1),:) = eegRightCell{ii};
    curTrials = curTrials+size(eegLeftCell{ii},1);
end
    

%%
ch = [];
lgn = [];
delay = [];
result = [];
for ii = 1:length(date)
    ch = cat(1,tData(ii).ch(1:size(eegRightCell{ii},1)),ch);
    lgn = cat(1,tData(ii).lgn(1:size(eegRightCell{ii},1)),lgn);
    delay = cat(1,tData(ii).delay(1:size(eegRightCell{ii},1)),delay);
    result = cat(1,tData(ii).result(1:size(eegRightCell{ii},1)),result);
end
%%
[l,r] = sortTrialsBySonication(lgn);

% idx = find(delay == 0);
delayIdx = find(abs(delay)<40 & abs(delay)> 0);

trls = 1;
idx = [];
for ii = 1:length(trls)
    idx = cat(1,idx,l{trls(ii)});
end
% idx = idx-1;
idx = intersect(idx,delayIdx);

% idx2 = find(abs(delay)<40 & abs(delay) > 0);
idx2 = [];
for ii = 1:length(trls)
    idx2 = cat(1,idx2,r{trls(ii)});
end
% idx2 = idx2-1;
idx2 = intersect(idx2,delayIdx);

idx = ~isnan(ch) & delay < -50;
idx2 = idx;

idx = find(lgn<0);
idx2 = find(lgn>0);
%%
h = figure;
subplot(211)
ax = gca;
hold on
plotVep(1e3*tA,eegLeft(idx,:),1,ax,{'Color',ax.ColorOrder(1,:),'linewidth',2});
plotVep(1e3*tA,eegLeft(idx2,:),1,ax,{'Color',ax.ColorOrder(2,:),'linewidth',2});
% plotVep(tA,eegLeftFp(idxOther,:),1,ax,{'Color',ax.ColorOrder(3,:),'linewidth',2});
[h1,p1] = findSignificanceVEPs(eegLeft(idx,:),eegLeft(idx2,:),1,ax,tA);
legend('Left','Right')
ylabel('voltage (\muV)')
title('Left Pin')
axis([0,800,-20,20])
makeFigureBig(h);

subplot(212)
ax = gca;
plotVep(1e3*tA,eegRight(idx,:),1,ax,{'Color',ax.ColorOrder(1,:),'linewidth',2});
plotVep(1e3*tA,eegRight(idx2,:),1,ax,{'Color',ax.ColorOrder(2,:),'linewidth',2});
% plotVep(tA,eegRightFp(idxOther,:),1,ax,{'Color',ax.ColorOrder(3,:),'linewidth',2});
[h1,p1] = findSignificanceVEPs(eegRight(idx,:),eegRight(idx2,:),1,ax,tA);
xlabel('time (ms)')
title('Right Pin')
axis([0,800,-20,20])
makeFigureBig(h)
h.Position = [0.3306    0.1962    1.3184    0.4200]*1e3;