clear; close all hidden; clc;
%% Add paths
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\lib\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\EEGLib\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\lib\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\lib\durable\')

%% Load files - nanoparticles
[tDataC, filesC] = loadMonk('c');
[tDataCS, filesCS] = loadMonk('c_saline');
[tDataH, filesH] = loadMonk('h');
[tDataHS, filesHS] = loadMonk('h_saline');

tDataC = setUltrasoundTrial(tDataC);
tDataCS = setUltrasoundTrial(tDataCS);
tDataH = setUltrasoundTrial(tDataH);
tDataHS = setUltrasoundTrial(tDataHS);

tDataDD = [tDataC,tDataCS,tDataH,tDataHS];

monkDD(1:length(tDataC)+length(tDataCS)) = 'c';
monkDD((end+1):length(tDataDD)) = 'h';
drug(1:length(tDataC)) = 'p';
drug((end+1):(end+length(tDataCS))) = 's';
drug((end+1):(end+length(tDataH))) = 'p';
drug((end+1):(end+length(tDataHS))) = 's';

processedFilesDD = [filesC,filesCS,filesH,filesHS];

%% Process behavior over time
% Set time window and range
tWindow = 3*60;
dt = 0.5*60;
tBefore = 300;
tAfter = 20*300;
tm = -tBefore:dt:tAfter;
baseline = 0;
% tm = 0:dt:40*60;
% tm = tWindow;

% Process drug delivery data
y = nan(length(tDataDD),length(tm));
m = y;
allCh = y;
epp = y;
err = y;
p0 = nan(size(tDataDD));
m0 = p0;
chVectors = nan(5,length(tm),length(tDataDD));
dVectors = chVectors;
for ii = 1:length(tDataDD)
    disp(['Processing Behavior: ', num2str(ii), ' of ', num2str(length(tDataDD))])
    if isnan(tDataDD(ii).sonicatedTrials)
        continue
    end
    % Process behavior over time
    baseline = tDataDD(ii).timing(tDataDD(ii).sonicatedTrials-1).startTime-...
        tDataDD(ii).timing(tDataDD(ii).sonicatedTrials).startTime;
    [p0(ii),~,m0(ii)] = behaviorOverTime2(tDataDD(ii),baseline,300);
    [epp(ii,:),y(ii,:),m(ii,:),allCh(ii,:),chVectors(:,:,ii),dVectors(:,:,ii),err(ii,:)]...
        = behaviorOverTime2(tDataDD(ii),tm,tWindow,p0(ii));
end
%%
sessions = sortSessionsDD(tDataDD,monkDD,drug,0);

% sIdxS = getSessionIdx(sessions,'Ispta',5,'<','drug','s','=','monk','h','=');
% sIdxP = getSessionIdx(sessions,'Ispta',5,'<','drug','p','=','monk','h','=');
sIdxS = getSessionIdx(sessions,'Ispta',5,'<','drug','s','=');
sIdxP = getSessionIdx(sessions,'Ispta',5,'<','drug','p','=');

[idxLeftS,idxRightS] = getLeftRightIdx(sessions,sIdxS);
[idxLeftP,idxRightP] = getLeftRightIdx(sessions,sIdxP);

% var2plot = 100*m./repmat(100*m0',[1,length(tm)]);
var2plot = 100*y;

h = figure;
h = plotDurableResults(tm,var2plot,idxLeftP,idxRightP,[],h,[0,20]);
figure(h)
title('Propofol')

h = figure;
h = plotDurableResults(tm,var2plot,idxLeftS,idxRightS,[],h,[0,20]);
figure(h)
title('Saline')

% ANOVA
lgn = [];
time = [];
drugAnova = [];
grp = {lgn,drugAnova,time};

tms = 60*(10:3:20);
tmIdx = zeros(size(tms));
for ii = 1:length(tms)
    tmIdx(ii) = find(tms(ii)==tm);
end

% Left LGN, Propofol
[anovaVar,grp] = myAnovaVars([],grp,var2plot(idxLeftP,tmIdx),...
    {-1*ones(length(idxLeftP),length(tmIdx)),1*ones(length(idxLeftP),length(tmIdx)),...
    repmat(tms,[length(idxLeftP),1])});
% Right LGN, Propofol
[anovaVar,grp] = myAnovaVars(anovaVar,grp,var2plot(idxRightP,tmIdx),...
    {1*ones(length(idxRightP),length(tmIdx)),1*ones(length(idxRightP),length(tmIdx)),...
    repmat(tms,[length(idxRightP),1])});

% Left LGN, Saline
[anovaVar,grp] = myAnovaVars(anovaVar,grp,var2plot(idxLeftS,tmIdx),...
    {-1*ones(length(idxLeftS),length(tmIdx)),0*ones(length(idxLeftS),length(tmIdx)),...
    repmat(tms,[length(idxLeftS),1])});
% Right LGN, Saline
[anovaVar,grp] = myAnovaVars(anovaVar,grp,var2plot(idxRightS,tmIdx),...
    {1*ones(length(idxRightS),length(tmIdx)),0*ones(length(idxRightS),length(tmIdx)),...
    repmat(tms,[length(idxRightS),1])});

[p,tbl] = anovan(anovaVar,grp,'varnames',{'LGN','Drug','Time'},'model','interaction');
for t = 2 : size(tbl, 1) - 2
    fprintf('%s \t F(%d,%d) = %.2f, p = %.2g\n', tbl{t, 1}, tbl{t, 3}, tbl{size(tbl, 1) - 1, 3}, tbl{t, 6}, tbl{t, 7});
end