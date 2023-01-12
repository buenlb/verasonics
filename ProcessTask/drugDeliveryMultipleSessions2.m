clear; close all; clc;
%% Load files with particles
[tDataC, filesC] = loadMonk('c');
[tDataH, filesH] = loadMonk('h');

%% Combine subjects
tData = [tDataC,tDataH];
processedFiles = [filesC,filesH];
monk(1:length(tDataC)) = 'c';
monk(length(tDataC)+1:length(tData)) = 'h';

%% Load files with saline
[tDataC, filesC] = loadMonk('c_saline');
[tDataH, filesH] = loadMonk('h_saline');

%% Combine subjects
tDataS = [tDataC,tDataH];
processedFilesS = [filesC,filesH];
monkS(1:length(tDataC)) = 'c';
monkS(length(tDataC)+1:length(tData)) = 'h';

%% Process 'good' data Particles
% Set time window and range
tWindow = 5*60;
dt = 0.5*60;
tBefore = 2*tWindow;
tAfter = 6*tWindow;
tm = -tBefore:dt:tAfter;
baseline = 0;
% tm = 0:dt:40*60;
% tm = tWindow;

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
    tData(ii) = setSonicationTime(tData(ii));
    p0(ii) = behaviorOverTime2(tData(ii),baseline,tWindow);
    [epp(ii,:),y(ii,:),m(ii,:),allCh(ii,:),chVectors(:,:,ii),dVectors(:,:,ii),err(ii,:)]...
        = behaviorOverTime2(tData(ii),tm,tWindow,p0(ii));
end

yS = nan(length(tData),length(tm));
mS = yS;
allChS = yS;
eppS = yS;
errS = yS;
p0S = nan(size(tDataS));
chVectorsS = nan(5,length(tm),length(tDataS));
dVectorsS = chVectorsS;
for ii = 1:length(tDataS)
    disp(['Processing Behavior: ', num2str(ii), ' of ', num2str(length(tDataS))])
    % Process behavior over time
    tDataS(ii) = setSonicationTime(tDataS(ii));
    p0S(ii) = behaviorOverTime2(tDataS(ii),baseline,tWindow);
    [eppS(ii,:),yS(ii,:),mS(ii,:),allChS(ii,:),chVectorsS(:,:,ii),dVectorsS(:,:,ii),err(ii,:)]...
        = behaviorOverTime2(tDataS(ii),tm,tWindow,p0S(ii));
end

%%
[~,~,~,~,~,monkS,idxPts,ss,I_all,Ispta_all] = plot_ispta(tData,monk,0);
[~,~,~,~,~,monkSS,idxPtsS,ssS,I_allS,Ispta_allS] = plot_ispta(tData,monk,0);

var2plot = m;

ptIdx = 2;
idxLeft = [];
idxRight = [];
idxCtl = [];
for ii = 1:length(ptIdx)
%     if monkS(ptIdx(ii))=='h'
%         continue
%     end
    idxLeft = cat(2,idxLeft,idxPts{ptIdx(ii)}(ss{ptIdx(ii)}==-1));
    idxRight = cat(2,idxRight,idxPts{ptIdx(ii)}(ss{ptIdx(ii)}==1));
    idxCtl = cat(2,idxCtl,idxPts{ptIdx(ii)}(ss{ptIdx(ii)}==0));
end

% idxLeft = idxLeft(1:5);
% idxRight= idxRight(1:5);

yMeanLeft = mean(var2plot(idxLeft,:),1,'omitnan');
yMeanRight = mean(var2plot(idxRight,:),1,'omitnan');
yStdLeft = std(var2plot(idxLeft,:),[],1,'omitnan');
yStdRight= std(var2plot(idxRight,:),[],1,'omitnan');

h = figure;
ax = gca;
shadedErrorBar(tm/60,yMeanLeft,yStdLeft,'lineprops',{'Color',ax.ColorOrder(1,:),'linewidth',2})
shadedErrorBar(tm/60,yMeanRight,yStdRight,'lineprops',{'Color',ax.ColorOrder(2,:),'linewidth',2})
legend('Left','Right')
xlabel('Time (minutes)')
axis([0,20,0,1])
makeFigureBig(h);