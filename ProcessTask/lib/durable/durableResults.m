clear; close all; clc;
%% Add paths
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\lib\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\EEGLib\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\lib\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\lib\durable\')
%% Load files
[tDataB, filesB] = loadMonk('b');
[tDataE, filesE] = loadMonk('e');

%% Combine subjects
tData = [tDataB,tDataE];
processedFiles = [filesB,filesE];
monk(1:length(tDataB)) = 'b';
monk(length(tDataB)+1:length(tData)) = 'e';

%% This code temporarily replaces the above while I am still sorting out loadDataDurable
% old = load('tmpSideSonicated.mat');
% load data10October2022.mat;
% for ii = 1:length(processedFiles)
%     curSession = processedFiles{ii};
%     for jj = 1:length(old.processedFiles)
%         if strcmp(old.processedFiles{jj}(end-length(curSession)+1:end),curSession)
%             tData(ii).sonication.focalLocation = old.tData(jj).sonicationProperties.FocalLocation;
%             tData(ii).sonication.nFoci = old.tData(jj).sonicationProperties.nFocalSpots;
%             tData(ii).sonication.dev = old.tData(jj).sonicationProperties.focalDev;
%         end
%     end
% end
%% Process behavior over time
% Set time window and range
tWindow = 5*60;
dt = 0.5*60;
tBefore = 2*tWindow;
tAfter = 10*tWindow;
tm = -tBefore:dt:tAfter;
baseline = 0;
% tm = 0:dt:40*60;
% tm = tWindow;

%% Error Checking
% Error check for sonications that occured on erroneous triggers
[tData,keepIdxNc] = processNonConformingSessions('noncomformingSessions',tData,processedFiles);
disp([num2str(sum(~keepIdxNc)), ' session(s) removed for erroneous sonication.'])
keepIdxNs = true(size(tData));
keepIdxBl = true(size(tData));
keepIdxNan = true(size(tData));
keepIdxLog = true(size(tData));
for ii = 1:length(tData)
% Display progress
    disp(['Finding Errors: ', num2str(ii), ' of ', num2str(length(tData))])

    % Error check for a session without a sonication
    if isnan(tData(ii).sonicatedTrials)
        % disp(['Throwing session out because it appears to lack a sonication: ', processedFiles{ii},'!'])
        keepIdxNs(ii) = false;
        continue
    end

    % Error check for early sessions in which we sonicated multiple times.
    % This throws out all trials after later sonications
    tData(ii) = removeExcessSonications(tData(ii));

    % Acquire baseline point of equal probability
    p0 = behaviorOverTime2(tData(ii),baseline,tWindow);

    % Error check for an unreasonable baseline (a sigmoid with an equal
    % probabability point outside of the available delays
    if abs(p0)>100
        %disp(['Throwing session out because of unreasonable baseline: ', processedFiles{ii},'!'])
        keepIdxBl(ii) = false;
        continue
    end

    % Error check for an nan baseline
    if isnan(p0)
        %disp(['Throwing session out because of nan baseline: ', processedFiles{ii},'!'])
        keepIdxNan(ii) = false;
        continue
    end

    % Error check by verifying that the record of the sonication in tData
    % matches the Verasonics log
%     keepIdxLog(ii) = verifyWithLog(tData(ii),processedFiles{ii});
    keepIdxLog = true(size(keepIdxLog));
end
disp('ELIMINATED SESSIONS')
keepIdx = keepIdxNc & keepIdxNs & keepIdxBl & keepIdxNan & keepIdxLog;
% keepIdx = keepIdxNs;
disp(['  ', num2str(sum(~keepIdx)), ' total sessions eliminated.'])
disp(['    ', num2str(sum(~keepIdxNc)), ' eliminated by non-conforming files check'])
disp(['    ', num2str(sum(~keepIdxNs)), ' eliminated because they lacked a sonication'])
disp(['    ', num2str(sum(~keepIdxBl)), ' eliminated because the baseline was outside of the expected range'])
disp(['    ', num2str(sum(~keepIdxNan)), ' eliminated because the baseline was NaN (not enough trials)'])
disp(['    ', num2str(sum(~keepIdxLog)), ' eliminated because verification with the Verasonics log failed'])

tdOld = tData;
tData = tData(keepIdx);
pfOld = processedFiles;
processedFiles = processedFiles(keepIdx);
monkOld = monk;
monk = monk(keepIdx);

%% Process 'good' data
y = nan(length(tData),length(tm));
m = y;
allCh = y;
epp = y;
err = y;
p0 = nan(size(tData));
chVectors = nan(5,length(tm),length(tData));
dVectors = chVectors;
for ii = 1:length(tData)
    disp(['Processing Behavior: ', num2str(ii), ' of ', num2str(length(tData))])
    % Process behavior over time
    p0(ii) = behaviorOverTime2(tData(ii),baseline,tWindow);
%     idx =  1:tData(ii).sonicatedTrials;
%     idx = idx(logical(tData(ii).correctDelay(idx)));
%     if length(idx)<200
%         disp('!!!Skipped')
%         continue
%     end
%     [~,slope,bias,downshift,scale] = plotSigmoid(tData(ii),idx);
%     p0(ii) = equalProbabilityPoint(slope,bias,downshift,scale);
    [epp(ii,:),y(ii,:),m(ii,:),allCh(ii,:),chVectors(:,:,ii),dVectors(:,:,ii),err(ii,:)]...
        = behaviorOverTime2(tData(ii),tm,tWindow,p0(ii));
end

%% Process parameters
% close all hidden
[I,Ispta,v,dc,prf,monkS,idxPts,ss,I_all,Ispta_all] = plot_ispta(tData,monk,4);

pulseDur = 1./prf.*dc;

spotlight = false(size(tData));
for ii = 1:length(tData)
    if sum(tData(ii).sonication(1).nFoci)>1
        spotlight(ii) = true;
    end
end

sessions = sortSessions(tData,monk,0);
monkS = [sessions.monk];

sIdx = getSessionIdx(sessions,'duration',300000);
[idxLeft,idxRight,idxCtl] = getLeftRightIdx(sessions,sIdx);

% idxLeft = idxLeft(2:end);

for ii = 1:length(p0)
    eppNormalized(ii,:) = epp(ii,:)-p0(ii);
end

% clear idxCtl
% Plot results
h = figure;
ax = gca;
y(abs(epp)>200) = nan;
epp(abs(epp)>200) = nan;
var2plot = 100*y;

% Remove sessions with strange us times
% badSessions = [25 82 94 44]; % These sessions have outlier sonication times
% badSessions = [idxLeft(36),idxRight([6,39])]; % These sessions are outliers in the five minutes before
% var2plot(badSessions,:) = nan;

% Remove time points with a poor sigmoid fit
% zIdx = find(tm==0);
% var2plot(err(:,zIdx)>mean(err(:,zIdx))+3*std(err(:,zIdx)),:) = nan;
% var2plot(err>mean(err(:),'omitnan')+3*std(err(:),[],'omitnan')) = nan;

% Require included sessions to contain data at 0, and 5 minutes.
% requiredTimes = [0,300];
% tmIdx = nan(size(requiredTimes));
% for ii = 1:length(requiredTimes)
%     tmIdx(ii) = find(tm==requiredTimes(ii));
% end
% validIdx = sum(~isnan(var2plot(:,tmIdx)),2)==length(requiredTimes);
% var2plot(~validIdx,:) = nan;
% disp([num2str(length(intersect(find(~validIdx),[idxLeft,idxRight]))), ' sessions removed for missing key time points'])

% Require at least 4 sessions in each LGN in each monkey to plot the time
% point.
thresh = 0;
for ii = 1:length(tm)
    % Boltz
    if ismember('b',monkS(sIdx))
        if sum(~isnan(var2plot(idxLeft,ii)) & monk(idxLeft)'=='b')< thresh
            var2plot(idxLeft,ii) = nan;
        end
        if sum(~isnan(var2plot(idxRight,ii)) & monk(idxRight)'=='b')< thresh
            var2plot(idxRight,ii) = nan;
        end
    end

    % Euler
    if ismember('e',monkS(sIdx))
        if sum(~isnan(var2plot(idxLeft,ii)) & monk(idxLeft)'=='e')< thresh
            var2plot(idxLeft,ii) = nan;
        end
        if sum(~isnan(var2plot(idxRight,ii)) & monk(idxRight)'=='e')< thresh
            var2plot(idxRight,ii) = nan;
        end
    end
end
validIdx = find(sum(~isnan(var2plot([idxLeft,idxRight],:)),1));

yLeft = mean(var2plot(idxLeft,:),1,'omitnan');
yLeftSem = semOmitNan(var2plot(idxLeft,:),1);
yRight = mean(var2plot(idxRight,:),1,'omitnan');
yRightSem = semOmitNan(var2plot(idxRight,:),1);
shadedErrorBar(tm/60,yLeft,yLeftSem,'lineprops',{'Color',ax.ColorOrder(1,:),'linewidth',2})
hold on;
shadedErrorBar(tm/60,yRight,yRightSem,'lineprops',{'Color',ax.ColorOrder(2,:),'linewidth',2})
if exist('idxCtl','var')
    yCtl = mean(var2plot(idxCtl,:),1,'omitnan');
    yCtlSem = semOmitNan(var2plot(idxCtl,:),1);
    shadedErrorBar(tm/60,yCtl,yCtlSem,'lineprops',{'Color',ax.ColorOrder(3,:),'linewidth',2})
end
% axis([-10,25,40,60])

plot([-120,120],[1,1]*66.67,'k:')
plot([-120,120],[1,1]*33.33,'k:')
plot([-120,120],[1,1]*50,'k')
plot([-120,120],[1,1]*50,'--','Color',[0.5,0.5,0.5])

ax.XLim = [-5,70];
ax.YLim = [20,80];
sonicationPoly = polyshape([0,0,sessions(sIdx(1)).duration/(60e3),sessions(sIdx(1)).duration/(60e3)],...
    [min(ax.YLim),max(ax.YLim),max(ax.YLim),min(ax.YLim)]);
plot(sonicationPoly)
% plot([-120,120],[1,1]*50,'k-')
% plot([-120,120],[1,1]*75,'k-.')
% plot([-120,120],[1,1]*25,'k-.')
if ~exist('idxCtl','var')
    legend('Left LGN','Right LGN','Location','northwest')
else
    legend('Left LGN','Right LGN','Control','Location','northwest')
end
makeFigureBig(h);

durableAnova(var2plot,tWindow,tm,idxLeft,idxRight);
%% Session average sigmoids in time
[slopeLeft,biasLeft,shiftLeft,scaleLeft,delays,chOutLeft]...
    = getDurableSigmoids(dVectors(:,validIdx,idxLeft),chVectors(:,validIdx,idxLeft));
[slopeRight,biasRight,shiftRight,scaleRight,delaysR,chOutRight]...
    = getDurableSigmoids(dVectors(:,validIdx,idxRight),chVectors(:,validIdx,idxRight));

if sum(delaysR==delays)~=length(delays)
    error('Something is off with the delays')
end

x = linspace(min(delays),max(delays),1e3);
h = figure;
for ii = 1:length(slopeLeft)
    clf
    ax = gca;
    hold on
    plot(delays,chOutLeft(:,ii),'.',delays,chOutRight(:,ii),'.','MarkerSize',38)
    yHat = sigmoid_ext(x,slopeLeft(ii),biasLeft(ii),shiftLeft(ii),scaleLeft(ii));
    ax.ColorOrderIndex = 1;
    plot(x,yHat,'linewidth',2);
    yHat = sigmoid_ext(x,slopeRight(ii),biasRight(ii),shiftRight(ii),scaleRight(ii));
    plot(x,yHat,'linewidth',2)
    title(['Time: ', num2str(tm(validIdx(ii))/60), 'minutes.']);
    legend('Left','Right','location','northwest')
    waitforbuttonpress
end

%% Bar plot
IsptaDivision = [0.5,1,1.5,2,2.5];
tmIdx = find(tm==-tWindow);
h = figure;
hold on
ax = gca;
xl = zeros(length(IsptaDivision)+1,1);
xr = xl;
pBars = xr;
intervals = cell(size(xl));
yLeft = nan(size(xl));
yRight = yLeft;
yLeftStd = yLeft;
yRightStd = yLeft;
lText = intervals;
for ii = 1:length(IsptaDivision)+1
    if ii == 1
        ptIdx = find(Ispta<IsptaDivision(1) & monkS=='b');
        lText{ii} = ['Ispta<',num2str(IsptaDivision(1))];
    elseif ii==length(IsptaDivision)+1
        ptIdx = find(Ispta>IsptaDivision(end) & monkS=='b');
        lText{ii} = ['Ispta>',num2str(IsptaDivision(end))];
    else
        ptIdx = find(Ispta<IsptaDivision(ii) & Ispta>IsptaDivision(ii-1));% & monkS=='e');
        lText{ii} = [num2str(IsptaDivision(ii-1)),'<Ispta<',num2str(IsptaDivision(ii))];
    end
    idxLeft = [];
    idxRight = [];
    idxCtl = [];
    for jj = 1:length(ptIdx)
    %     if monkS(ptIdx(jj))=='e'
    %         continue
    %     end
        idxLeft = cat(2,idxLeft,idxPts{ptIdx(jj)}(ss{ptIdx(jj)}==-1));
        idxRight = cat(2,idxRight,idxPts{ptIdx(jj)}(ss{ptIdx(jj)}==1));
        idxCtl = cat(2,idxCtl,idxPts{ptIdx(jj)}(ss{ptIdx(jj)}==0));
    end
    yLeft(ii) = mean(y(idxLeft,tmIdx),'omitnan');
    yRight(ii) = mean(y(idxRight,tmIdx),'omitnan');
    yLeftStd(ii) = semOmitNan(y(idxLeft,tmIdx),1);
    yRightStd(ii) = semOmitNan(y(idxRight,tmIdx),1);

    intervals{ii} = ((ii-1)*3+1):((ii-1)*3+2);
    xl(ii) = intervals{ii}(1);
    xr(ii) = intervals{ii}(2);
    [~,pBars(ii)] = ttest2(y(idxLeft,tmIdx),y(idxRight,tmIdx));
end

b(1) = bar(xl,100*yLeft,'BaseValue',50,'BarWidth',0.25);
b(2) = bar(xr,100*yRight,'BaseValue',50,'BarWidth',0.25);
eb = errorbar(xl,100*yLeft,100*yLeftStd);
set(eb,'linestyle','none','Color',[0,0,0])
eb = errorbar(xr,100*yRight,100*yRightStd);
set(eb,'linestyle','none','Color',[0,0,0])
sigstar(intervals,pBars);
legend(b,'Left LGN','Right LGN','location','southeast')
ax.XTick = mean([xl,xr],2);
ax.XTickLabel = lText;
ylabel('Leftward Choices at Epp (%)')
ax.XTickLabelRotation = 90;
title(['Choices @ t=',num2str(tm(tmIdx)/60),' minutes'])
makeFigureBig(h)
% h.Position = [2 42 958 954];
