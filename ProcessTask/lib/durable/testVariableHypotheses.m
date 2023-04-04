%% Hypothesis 1: Ultrasound parameters are the source of the variability
% Get all session data
sessions = sortSessions(tData,monk,0);

% Prune data. Currently this means selecting only 30 second sonications and
% only parameter sets with at least four per side.
idx = getSessionIdx(sessions,'duration',30000,'='); % only 30 seconds
idx = getSessionIdx(sessions,'duration',30000,'=','Ispta',1,'<'); % only 30 seconds; Ispta > 1
sessions2 = sessions(idx);

% 4 per side
keepIdx = true(size(sessions2));
for ii = 1:length(sessions2)
    if length(sessions2(ii).sessionsLeft) < 4 | length(sessions2(ii).sessionsRight) < 4
        keepIdx(ii) = false;
    end
end
sessions2 = sessions2(keepIdx);

% Select variable to use for comparison and get the data matching the
% selected sessions
[idxLeft,idxRight,idxCtl] = getLeftRightIdx(sessions2,1:length(sessions2));
contraVar = 100*y;
contraVar(idxLeft,:) = 100-contraVar(idxLeft,:); % Make it contralateral for comparison across side sonicated

% Run the comparison
[bins,brs,se,nSessions,p] = parameterComparison(sessions2,tm,contraVar,5.5*60,'Isppa',[0:10:70]);

% Plot the results
h = figure;
ax = gca;
bar(bins,brs,'BaseValue',50)
hold on;
eb = errorbar(bins,brs,se);
eb.LineStyle = 'none';
eb.Color = ax.ColorOrder(1,:);

ax.XTick = bins;
ax.XTickLabel = {};
for ii = 1:length(bins)
ax.XTickLabel{ii} = ['Center: ', num2str(bins(ii)), '; ', num2str(nSessions(ii)), ' ses'];
end
ax.XTickLabelRotation = 90;
makeFigureBig(h);

%% Hypothesis 2: Coupling is the source of the variability
eulerGs = 'D:\Task\verasonicsLog\eulerGs_TaylorComputer.mat';
boltzmannGs = 'D:\Task\verasonicsLog\boltzGs2_taylorComputer_differentCouplingFile.mat';

sessions = sortSessions(tData,monk,0);

% Prune data. Currently this means selecting only 30 second sonications and
% only parameter sets with at least four per side. Also, sort by Ispta
% since that does result in a statistically significant difference
% idx = getSessionIdx(sessions,'duration',30000,'='); % only 30 seconds
idx = getSessionIdx(sessions,'duration',30000,'=','Ispta',1,'<'); % only 30 seconds; Ispta > 1
sessions2 = sessions(idx);

% 4 per side
keepIdx = true(size(sessions2));
for ii = 1:length(sessions2)
    if length(sessions2(ii).sessionsLeft) < 4 | length(sessions2(ii).sessionsRight) < 4
        keepIdx(ii) = false;
    end
end
sessions2 = sessions2(keepIdx);

% Get the index for the sessions to be tested, create the contralateral
% variable
[idxLeft,idxRight,idxCtl] = getLeftRightIdx(sessions2,1:length(sessions2));
idx1 = [idxLeft,idxRight];
contraVar = 100*y;
contraVar(idxLeft,:) = 100-contraVar(idxLeft,:); % Make it contralateral for comparison across side sonicated

% Check coupling
coupling = nan(size(tData));
com = nan(size(tData));
for ii = 1:length(idx1)
    if monk(idx1(ii)) == 'b'
        gs = boltzmannGs;
    elseif monk(idx1(ii)) == 'e'
        gs = eulerGs;
    end

    cr = ['D:\Task\verasonicsLog\',processedFiles{idx1(ii)}(1:end-4),'_final.mat'];
    [coupling(idx1(ii)),~,~,~,~,~,~,~,~,~,com(idx1(ii))] = checkCoupling(gs,cr,1);
end

% Plot
clc; close all
window = 5.5*60;
tmIdx = find(tm==window);
h = figure;
plot(com(idx1),(contraVar(idx1,tmIdx)),'*');
xlabel('Center of mass (cm)')
ylabel('Contralateral ')

hst = histogram(com,3);
idx = discretize(com,hst.BinEdges);

brs = nan(size(hst.Values));
sm = brs;
for ii = 1:length(hst.Values)
    curIdx = find(idx==ii);
    brs(ii) = mean(contraVar(curIdx,tmIdx),'omitnan');
    sm(ii) = semOmitNan(contraVar(curIdx,tmIdx),1);
end

binCenters = diff(hst.BinEdges)/2+hst.BinEdges(1:end-1);
h = figure;
ax = gca;
bar(binCenters,brs,'BaseValue',50);
hold on
ax.ColorOrderIndex = 1;
eb = errorbar(binCenters,brs,sm);
eb.LineStyle = 'none';
xlabel('Center of Mass (cm)')
ylabel('Contralateral Choices (%)')
makeFigureBig(h);

% Pass/Fail
psIdx = find(coupling==1);
fIdx = find(coupling==0);
brs = [mean(contraVar(psIdx,tmIdx),'omitnan'),mean(contraVar(fIdx,tmIdx),'omitnan')];
sm = [semOmitNan(contraVar(psIdx,tmIdx),1),semOmitNan(contraVar(fIdx,tmIdx),1)];

h = figure;
ax = gca;
bar(1:2,brs,'BaseValue',50);
hold on
ax.ColorOrderIndex = 1;
eb = errorbar(1:2,brs,sm);
eb.LineStyle = 'none';
xlabel('Pass/Fail (cm)')
ylabel('Contralateral Choices (%)')
ax.XTick = 1:2;
ax.XTickLabel = {'Pass','Fail'};
ax.XTickLabelRotation = 90;
makeFigureBig(h);

%% Hypothesis #3: Adaptation
close all hidden; clc
sessions = sortSessions(tData,monk,0);

% Prune data. Currently this means selecting only 30 second sonications and
% only parameter sets with at least four per side.
idx = getSessionIdx(sessions,'duration',30000,'='); % only 30 seconds
idx = getSessionIdx(sessions,'duration',30000,'=','Ispta',1,'>'); % only 30 seconds; Ispta > 1
sessions2 = sessions(idx);

% 4 per side
keepIdx = true(size(sessions2));
for ii = 1:length(sessions2)
    if length(sessions2(ii).sessionsLeft) < 4 | length(sessions2(ii).sessionsRight) < 4
        keepIdx(ii) = false;
    end
end
sessions2 = sessions2(keepIdx);

% Select variable to use for comparison and get the data matching the
% selected sessions
[idxLeft,idxRight,idxCtl] = getLeftRightIdx(sessions2,1:length(sessions2));
idx1 = [idxLeft,idxRight,idxCtl];
contraVar = nan(size(y));
contraVar(idx1,:) = 100*y(idx1,:);
contraVar(idxLeft,:) = 100-contraVar(idxLeft,:);

dailyIspta = nan(size(tData));
v = nan(size(tData));
dc = v;
nFoci = dc;
curIdx = 1;
for ii = 1:length(tData)
    v(ii) = tData(ii).sonication.voltage;
    dc(ii) = tData(ii).sonication.dc;
    nFoci(ii) = sum(tData(ii).sonication.nFoci);
end
nFoci(nFoci==0) = 1;
dc = dc./nFoci;

for ii = 1:length(dc)
    dailyIspta(ii) = p2I_brain(v(ii)*55.2*1e3)/1e4*dc(ii)/100;
end

day = getSessionDate(processedFiles);
day = day-min(day);
[day,sIdx] = sort(day);

tDataS = tData(sIdx);
monkSorted = monk(sIdx);
isptaSorted = dailyIspta(sIdx);
nDays = 10;
% Boltzmann
bIdx = find(monkSorted=='b');
daysBeforeBoltz = zeros(size(bIdx));
boltzIspta = isptaSorted(bIdx);
boltzSonicationBefore = daysBeforeBoltz;
preSessionBoltz = false(size(bIdx));
for ii = 1:length(bIdx)
    if ii == 1
        daysBeforeBoltz(ii)=0;
        continue
    end
    tmpIdx = find(day(bIdx)<day(bIdx(ii)) & day(bIdx)>=day(bIdx(ii))-nDays);
    daysBeforeBoltz(ii) = sum(boltzIspta(tmpIdx)>1);

    if daysBeforeBoltz(ii)>0
        boltzSonicationBefore(ii) = true;
    else
        boltzSonicationBefore(ii) = false;
    end

    if boltzIspta(ii-1)>1
        preSessionBoltz(ii) = true;
    end
end

% Euler
eIdx = find(monkSorted=='e');
daysBeforeEuler= zeros(size(eIdx));
eulerSonicationBefore = daysBeforeEuler;    
eulerIspta = isptaSorted(eIdx);
preSessionEuler = false(size(eIdx));
for ii = 1:length(eIdx)
    if ii == 1
        daysBeforeEuler(ii)=0;
        continue
    end
    tmpIdx = find(day(eIdx)<day(eIdx(ii)) & day(eIdx)>=day(eIdx(ii))-nDays);
    daysBeforeEuler(ii) = sum(eulerIspta(tmpIdx)>1);

    if daysBeforeEuler(ii)>0
        eulerSonicationBefore(ii) = true;
    else
        eulerSonicationBefore(ii) = false;
    end

    if eulerIspta(ii-1)>1
        preSessionEuler(ii) = true;
    end
end

window = 15.5*60;
tmIdx = find(tm==window);

brs = nan(1,nDays);
sm = brs;
cv = cell(1,nDays);
for ii = 1:nDays
    cv{ii} = contraVarSorted([eIdx(daysBeforeEuler==ii-1),bIdx(daysBeforeBoltz==ii-1)],tmIdx);
    brs(ii) = mean(cv{ii},'omitnan');
    sm(ii) = semOmitNan(cv{ii},1);
end 

h = figure;
ax = gca;
bar(1:nDays,brs,'BaseValue',50)
hold on;
ax.ColorOrderIndex = 1;
eb = errorbar(1:nDays,brs,sm,'linestyle','none');


h = figure;
ax = gca;
brs = [mean([contraVar(bIdx(logical(boltzSonicationBefore)),tmIdx);contraVar(eIdx(logical(eulerSonicationBefore)),tmIdx)],'omitnan'),...
    mean([contraVar(bIdx(~logical(boltzSonicationBefore)),tmIdx);contraVar(eIdx(~logical(eulerSonicationBefore)),tmIdx)],'omitnan')];
sm = [semOmitNan([contraVar(bIdx(logical(boltzSonicationBefore)),tmIdx);contraVar(eIdx(logical(eulerSonicationBefore)),tmIdx)],1),...
    semOmitNan([contraVar(bIdx(~logical(boltzSonicationBefore)),tmIdx);contraVar(eIdx(~logical(eulerSonicationBefore)),tmIdx)],1)];
bar(1:2,brs,'BaseValue',50)
hold on
ax.ColorOrderIndex = 1; 
eb = errorbar(1:2,brs,sm,'linestyle','none');

%%
h = figure;
ax = gca;
brs = [mean([contraVar(bIdx((preSessionBoltz)),tmIdx);contraVar(eIdx((preSessionEuler)),tmIdx)],'omitnan'),...
    mean([contraVar(bIdx(~(preSessionBoltz)),tmIdx);contraVar(eIdx(~(preSessionEuler)),tmIdx)],'omitnan')];
sm = [semOmitNan([contraVar(bIdx((preSessionEuler)),tmIdx);contraVar(eIdx((preSessionEuler)),tmIdx)],1),...
      semOmitNan([contraVar(bIdx(~(preSessionBoltz)),tmIdx);contraVar(eIdx(~(preSessionEuler)),tmIdx)],1)];
bar(1:2,brs,'BaseValue',50)
hold on
ax.ColorOrderIndex = 1; 
eb = errorbar(1:2,brs,sm,'linestyle','none');
% contraVarSorted = contraVar(sIdx,:);
% figure
% plot(daysBeforeBoltz,contraVar(bIdx,tmIdx),'*')
% hold on
% plot(daysBeforeEuler,contraVar(eIdx,tmIdx),'o')

%%
nDays = 30;
