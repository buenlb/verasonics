eegOutJ = struct('features',[],'tFeatures',[],'frequencies',[],'windowDur',...
    [],'notches',[]);
eegOutT = struct('features',[],'tFeatures',[],'frequencies',[],'windowDur',...
    [],'notches',[]);
eegOutTNT = struct('features',[],'tFeatures',[],'frequencies',[],'windowDur',...
    [],'notches',[]);
eegOutTaylorFileIO = struct('features',[],'tFeatures',[],'frequencies',[],'windowDur',...
    [],'notches',[]);
runningMe = cell(size(tData));
curF_idx = 0;

for ii = 1:length(tData)
    disp(['  ******Processing EEG data in session ', num2str(ii), ' of ', num2str(length(processedFiles))])
    tic
    for jj = 1:length(processedFiles{ii})
        if ~isnan(str2double(processedFiles{ii}(jj))) && isreal(str2double(processedFiles{ii}(jj)))
            date(ii).year = (processedFiles{ii}(jj:(jj+3)));
            date(ii).month = (processedFiles{ii}((jj+4):(jj+5)));
            date(ii).day = (processedFiles{ii}((jj+6):(jj+7)));
            break;
        end
    end
    switch monk(ii)
        case 'b'
            pth = 'D:\Task\Boltz\eeg\';
            baseName1 = 'boltzmannTask_';
        case 'e'
            pth = 'D:\Task\Euler\eeg\';
            baseName1 = 'Euler_';
    end
    baseName = [baseName1,date(ii).year(3:4),date(ii).month,date(ii).day];
    try
        [outJ, outT, outTNT, outFIO] = fullEegAnalysis(pth,baseName,tData(ii));
        eegOutJ(ii) = rmfield(outJ,'eegIn');
        eegOutT(ii) = rmfield(outT,'eegIn');
        eegOutTNT(ii) = outTNT;
        eegOutTaylorFileIO(ii) = rmfield(outFIO,'eegIn');
        disp('Success!!!')
    catch me
        try
            disp(['***FAILED: ', me.message]);
            if strcmp(me.identifier,'MATLAB:nomem')
                disp('OUT OF MEMORY! SAVING, ClEARING, AND CONTINUING')
                ii = ii-1;
                curF_idx = curF_idx+1;
                save(['tmpEegOut',num2str(curF_idx)], 'eegOutJ','eegOutT','eegOutTNT','eegOutTaylorFileIO');
                clear eegOutJ eegOutT eegOutTNT eegOutTaylorFileIO;
            else
            end
            runningMe{ii} = me;
        catch
        end
    end
end

%%
if ~exist('eegOutJ','var')
    eegOutJ = eeg.eegOutJ;
    eegOutT = eeg.eegOutT;
    eegOutTNT = eeg.eegOutTNT;
    eegOutTaylorFileIO = eeg.eegOutTaylorFileIO;
end
sWindow = 300;
tSmoothed = -10*60:(0.5*60):30*60;
maxDim = 0;
featuresJ = nan(length(eegOutJ),length(tSmoothed),size(eegOutJ(1).features,1));
featuresT = nan(length(eegOutJ),length(tSmoothed),size(eegOutT(1).features,1));
featuresTNT = nan(length(eegOutJ),length(tSmoothed),size(eegOutT(1).features,1));
featuresMyFileIO = nan(length(eegOutJ),length(tSmoothed),size(eegOutT(1).features,1));

trgT = nan(length(eegOutJ),length(tSmoothed));
bT = zeros(length(eegOutT),size(eegOutT(1).features,1));
for ii = 1:length(eegOutJ)
    disp(['Struct ', num2str(ii), ' of ', num2str(length(eegOutJ))])
    if isempty(eegOutJ(ii).features)
        continue
    end
    if size(eegOutJ(ii).features,2)>maxDim
        maxDim = size(eegOutJ(ii).features,2);
        mxI = ii;
    end

    curIdx = find(eegOutT(ii).tFeatures<0 & eegOutT(ii).tFeatures>-5*60);
    bT(ii,:) = mean(eegOutT(ii).features(:,curIdx),2,'omitnan');
    for jj = 1:length(tSmoothed)
        curIdx = find(eegOutJ(ii).tFeatures>=tSmoothed(jj) & eegOutJ(ii).tFeatures<tSmoothed(jj)+sWindow);
        featuresJ(ii,jj,:) = mean(eegOutJ(ii).features(:,curIdx),2,'omitnan');

        curIdx = find(eegOutT(ii).tFeatures>=tSmoothed(jj) & eegOutT(ii).tFeatures<tSmoothed(jj)+sWindow);
        featuresT(ii,jj,:) = mean(eegOutT(ii).features(:,curIdx),2,'omitnan');
        featuresTNT(ii,jj,:) = mean(eegOutTNT(ii).features(:,curIdx),2,'omitnan');

%         curIdx = find(eegOutT(ii).eegIn.t>=tSmoothed(jj) & eegOutT(ii).eegIn.t<tSmoothed(jj)+sWindow);
%         if ~isempty(curIdx)
%             trgT(ii,jj) = max(eegOutT(ii).eegIn.dig(1,curIdx));
%         else
%             trgT(ii,jj) = nan;
%         end
%         if tSmoothed(jj)==0 && ismember(ii,idx1)
% %             keyboard
%         end

        curIdx = find(eegOutTaylorFileIO(ii).tFeatures>=tSmoothed(jj) & eegOutTaylorFileIO(ii).tFeatures<tSmoothed(jj)+sWindow);
        featuresMyFileIO(ii,jj,:) = mean(eegOutTaylorFileIO(ii).features(:,curIdx),2,'omitnan');
    end
end
%%

keepIdx = keepIdxLog & keepIdxNan & keepIdxBl & keepIdxNs & keepIdxNc;

close all hidden
sessions = sortSessions(tData,monk,0);

% Select out the relevant sessions:
% Select for correct duration/Ispta
% sIdx = getSessionIdx(sessions,'duration',30000,'=','monk','b','=');
sIdx = getSessionIdx(sessions,'duration',30000,'=','Ispta',1,'>');
sessions2 = sessions(sIdx);

% Select only parameters with at least 5 per side
keepIdxSessions = true(size(sessions2));
for ii = 1:length(sessions2)
    if length(sessions2(ii).sessionsLeft) < 4 || length(sessions2(ii).sessionsRight) < 4
        keepIdxSessions(ii) = false;
    end

end
sessions2 = sessions2(keepIdxSessions);

[idxLeft,idxRight] = getLeftRightIdx(sessions2,1:length(sessions2));
idx1 = [idxLeft,idxRight];
disp([num2str(sum(~keepIdx(idx1))), ' removed from final sessions.'])
idx1 = idx1(keepIdx(idx1));
idx1 = idx1(idx1<=length(eegOutJ));

fRange = [30,70];
gIdxJ = find(eegOutJ(1).frequencies>=fRange(1) & eegOutJ(1).frequencies<=fRange(2));
gIdxT = find(eegOutT(1).frequencies>=fRange(1) & eegOutT(1).frequencies<=fRange(2));

f = eegOutT(1).frequencies;
deltaIdx = find(f>0 & f<=3);
thetaIdx = find(f>3 & f<=7);
alphaIdx = find(f>7 & f<=12);
betaIdx = find(f>12 & f<=30);
gammaIdx = find(f>30 & f<=70);
hGammaIdx = find(f>70 & f<=320);

gammaJ = mean(featuresJ(:,:,gIdxJ),3,'omitnan');
gammaT = mean(featuresT(:,:,gIdxT),3,'omitnan');
gammaTNT = mean(featuresTNT(:,:,gIdxT),3,'omitnan');
gammaMyFileIO = mean(featuresMyFileIO(:,:,gIdxT),3,'omitnan');

alphaT = mean(featuresT(:,:,alphaIdx),3,'omitnan');
betaT = mean(featuresT(:,:,betaIdx),3,'omitnan');
hGammaT = mean(featuresT(:,:,hGammaIdx),3,'omitnan');

% gammaJ = gammaJ/max(gammaJ(:));
% gammaT = gammaT/max(gammaT(:));
% gammaTNT = gammaTNT/max(gammaTNT(:));
% gammaMyFileIO = gammaMyFileIO/max(gammaMyFileIO(:));
% alphaT = alphaT/max(alphaT(:));
% betaT = betaT/max(betaT(:));
% hGammaT = hGammaT/max(hGammaT(:));

x = (tSmoothed(1:end))/60+5;
% tms = [0,5,10,15,20];
tms= 0:2.5:30;
temporalIdx = nan(size(tms));
for ii = 1:length(tms)
    temporalIdx(ii) = find(x==tms(ii));
end
ZSCORE = 0;
if ZSCORE
    [alphaZ,alphaZSem] = zscore_omitnan(alphaT(idx1,:),1);
    [betaZ,betaZSem] = zscore_omitnan(betaT(idx1,:),1);
    [gammaZ,gammaZSem] = zscore_omitnan(gammaT(idx1,:),1);
    [hGammaZ,hGammaZSem] = zscore_omitnan(hGammaT(idx1,:),1);
    
    [alphaZC,alphaZSemC] = zscore_omitnan(alphaT(idxCtl,:),1);
    [betaZC,betaZSemC] = zscore_omitnan(betaT(idxCtl,:),1);
    [gammaZC,gammaZSemC] = zscore_omitnan(gammaT(idxCtl,:),1);
    [hGammaZC,hGammaZSemC] = zscore_omitnan(hGammaT(idxCtl,:),1);
else
    alphaZ = nan(size(alphaT,1),length(tms));
    betaZ = nan(size(betaT,1),length(tms));
    gammaZ = nan(size(gammaT,1),length(tms));
    hGammaZ = nan(size(hGammaT,1),length(tms));

    alphaN = nan(size(alphaT,1),length(x));
    betaN = nan(size(betaT,1),length(x));
    gammaN = nan(size(gammaT,1),length(x));
    hGammaN = nan(size(hGammaT,1),length(x));
    
    baselineIdx = [-5, 0];
%     baselineIdx = 0;
    tmIdx = nan(size(baselineIdx));
    for ii = 1:length(baselineIdx)
        tmIdx(ii) = find(x==baselineIdx(ii));
    end
    for ii = 1:size(gammaT,1)
%         alphaZ(ii,:) = alphaT(ii,temporalIdx)/mean(alphaT(ii,tmIdx),'omitnan');
%         betaZ(ii,:) = betaT(ii,temporalIdx)/mean(betaT(ii,tmIdx),'omitnan');
%         gammaZ(ii,:) = gammaT(ii,temporalIdx)/mean(gammaT(ii,tmIdx),'omitnan');
%         hGammaZ(ii,:) = hGammaT(ii,temporalIdx)/mean(hGammaT(ii,tmIdx),'omitnan');
% 
%         alphaN(ii,:) = alphaT(ii,:)/mean(alphaT(ii,tmIdx),'omitnan');
%         betaN(ii,:) = betaT(ii,:)/mean(betaT(ii,tmIdx),'omitnan');
%         gammaN(ii,:) = gammaT(ii,:)/mean(gammaT(ii,tmIdx),'omitnan');
%         hGammaN(ii,:) = hGammaT(ii,:)/mean(hGammaT(ii,tmIdx),'omitnan');

        alphaZ(ii,:) = alphaT(ii,temporalIdx)/mean(bT(ii,alphaIdx),'omitnan');
        betaZ(ii,:) = betaT(ii,temporalIdx)/mean(bT(ii,betaIdx),'omitnan');
        gammaZ(ii,:) = gammaT(ii,temporalIdx)/mean(bT(ii,gammaIdx),'omitnan');
        hGammaZ(ii,:) = hGammaT(ii,temporalIdx)/mean(bT(ii,hGammaIdx),'omitnan');

        alphaN(ii,:) = alphaT(ii,:)/mean(bT(ii,alphaIdx),'omitnan');
        betaN(ii,:) = betaT(ii,:)/mean(bT(ii,betaIdx),'omitnan');
        gammaN(ii,:) = gammaT(ii,:)/mean(bT(ii,gammaIdx),'omitnan');
        hGammaN(ii,:) = hGammaT(ii,:)/mean(bT(ii,hGammaIdx),'omitnan');

%         alphaZ(ii,:) = alphaT(ii,:)/mean(alphaT(ii,x<=0),'omitnan');
%         betaZ(ii,:) = betaT(ii,:)/mean(betaT(ii,x<=0),'omitnan');
%         gammaZ(ii,:) = gammaT(ii,:)/mean(gammaT(ii,x<=0),'omitnan');
%         hGammaZ(ii,:) = hGammaT(ii,:)/mean(hGammaT(ii,x<=0),'omitnan');
    end

%     gammaN = gammaZ;
%     alphaN = alphaZ;
%     betaN = betaZ;
%     hGammaN = hGammaZ;

%     [alphaZ,alphaZSem] = zscore_omitnan(alphaZ(idx1,:),1);
%     [betaZ,betaZSem] = zscore_omitnan(betaZ(idx1,:),1);
%     [gammaZ,gammaZSem] = zscore_omitnan(gammaZ(idx1,:),1);
%     [hGammaZ,hGammaZSem] = zscore_omitnan(hGammaZ(idx1,:),1);

    alphaZSem = semOmitNan(alphaZ(idx1,:),1);
    alphaZ = mean(alphaZ(idx1,:),1,'omitnan');
    betaZSem = semOmitNan(betaZ(idx1,:),1);
    betaZ = mean(betaZ(idx1,:),1,'omitnan');
    gammaZSem = semOmitNan(gammaZ(idx1,:),1);
    gammaZ = mean(gammaZ(idx1,:),1,'omitnan');
    hGammaZSem = semOmitNan(hGammaZ(idx1,:),1);
    hGammaZ = mean(hGammaZ(idx1,:),1,'omitnan');
end

h = figure;
ax = gca;
hold on;
shadedErrorBar(x(temporalIdx),alphaZ,alphaZSem,'lineprops',{'Color',ax.ColorOrder(4,:),'linewidth',2});
shadedErrorBar(x(temporalIdx),betaZ,betaZSem,'lineprops',{'Color',ax.ColorOrder(5,:),'linewidth',2});
% shadedErrorBar(x(temporalIdx),gammaZ,gammaZSem,'lineprops',{'Color',ax.ColorOrder(7,:),'linewidth',2});
shadedErrorBar(x(temporalIdx),hGammaZ,hGammaZSem,'lineprops',{'Color',ax.ColorOrder(6,:),'linewidth',2});

% shadedErrorBar(x,alphaZC,alphaZSemC,'lineprops',{'Color',ax.ColorOrder(1,:),'linewidth',2,'linestyle','--'});
% shadedErrorBar(x,betaZC,betaZSemC,'lineprops',{'Color',ax.ColorOrder(2,:),'linewidth',2,'linestyle','--'});
% shadedErrorBar(x,gammaZC,gammaZSemC,'lineprops',{'Color',ax.ColorOrder(3,:),'linewidth',2,'linestyle','--'});
% shadedErrorBar(x,hGammaZC,hGammaZSemC,'lineprops',{'Color',ax.ColorOrder(4,:),'linewidth',2,'linestyle','--'});

% legend('Gamma LGN','High Gamma LGN', 'Gamma Control','High Gamma Control')
legend('Alpha','Beta','High Gamma')
xlabel('time (minutes)')
ylabel('Z Score');
ax.XLim = [0,20];
ax.YLim = [0.8,1.5];
makeFigureBig(h);

% Anova
INCLUDEHG = 0;
anovaTms = [5,10,15]+0.5;
anovaTmIdx = zeros(size(anovaTms));
for ii = 1:length(anovaTms)
    anovaTmIdx(ii) = find(anovaTms(ii) == x);
end
if INCLUDEHG
    group1 = cell(4*length(idx1),length(anovaTms));
else
    group1 = cell(3*length(idx1),length(anovaTms));
end
group2 = nan(size(group1));
for ii = 1:length(anovaTms)
    for jj = 1:length(idx1)
        group1{jj,ii} = 'alpha';
        group1{jj+length(idx1),ii} = 'beta';
        group1{jj+2*length(idx1),ii} = 'gamma';
        if INCLUDEHG
            group1{jj+3*length(idx1),ii} = 'hGamma';
        end
    end
    group2(:,ii) = anovaTms(ii);
end

if INCLUDEHG
    anovaVar = real([alphaN(idx1,anovaTmIdx);betaN(idx1,anovaTmIdx);gammaN(idx1,anovaTmIdx);hGammaN(idx1,anovaTmIdx)]);
else
    anovaVar = real([alphaN(idx1,anovaTmIdx);betaN(idx1,anovaTmIdx);hGammaN(idx1,anovaTmIdx)]);
end
[p,tbl,stats,interaction] = anovan(anovaVar(:),{group1(:),group2(:)},'model','interaction','varnames',{'Band','Time'});
for t = 2 : size(tbl, 1) - 2
    fprintf('%s \t F(%d,%d) = %.2f, p = %.2g\n', tbl{t, 1}, tbl{t, 3}, tbl{size(tbl, 1) - 1, 3}, tbl{t, 6}, tbl{t, 7});
end
% [P,T,STATS,TERMS] = anovan(anovaVar(:),{group1{:};group2(:)})

%%

% Bar Plots
h = figure;
ax = gca;
hold on
tRange = [5.5,5.5];
alphaInTime = real(mean(alphaN(idx1,x>=tRange(1) & x<=tRange(2)),2,'omitnan'));
betaInTime = real(mean(betaN(idx1,x>=tRange(1) & x<=tRange(2)),2,'omitnan'));
gammaInTime = real(mean(gammaN(idx1,x>=tRange(1) & x<=tRange(2)),2,'omitnan'));
hGammaInTime = real(mean(hGammaN(idx1,x>=tRange(1) & x<=tRange(2)),2,'omitnan'));

bar(1:3,100*([mean(gammaInTime,'omitnan'),mean(alphaInTime,'omitnan'),mean(betaInTime,'omitnan')]-1),'BaseValue',0)
ax.ColorOrderIndex = 1;
eb = errorbar(1:3,100*([mean(gammaInTime,'omitnan'),mean(alphaInTime,'omitnan'),mean(betaInTime,'omitnan')]-1),...
    100*[semOmitNan(gammaInTime,1),semOmitNan(alphaInTime,1),semOmitNan(betaInTime,1)]);
set(eb,'linestyle','none')
ylabel('Change (%)')
ax.XTick = 1:3;
ax.XTickLabel = {'\gamma','\alpha','\beta'};
[~,pEeg(1)] = ttest2(gammaInTime,alphaInTime);
[~,pEeg(2)] = ttest2(gammaInTime,betaInTime);
[~,pEeg(3)] = ttest2(alphaInTime,betaInTime);
sigstar({[1,2],[1,3],[2,3]},pEeg)
makeFigureBig(h)
%%

x = (tSmoothed(1:end))/60+5;
h = figure;
hold on
ax = gca;
plotVep(x,gammaJ(idx1,:),1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(x,gammaTNT(idx1,:),1,ax,{'Color',ax.ColorOrder(2,:)});
plotVep(x,gammaT(idx1,:),1,ax,{'Color',ax.ColorOrder(3,:)});
plotVep(x,gammaMyFileIO(idx1,:),1,ax,{'Color',ax.ColorOrder(4,:)});
legend('J','TNT','T','TFileIO')
ax.XLim = [-5,20];
makeFigureBig(h);

h = figure;
ax = gca;
plotVep(x,gammaTNT(idx1,:),1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(x,gammaTNT(idxCtl,:),1,ax,{'Color',ax.ColorOrder(3,:)});
title('Without Thresholding')
legend('LGN','Control')
ax.XLim = [-5,10];
makeFigureBig(h);

h = figure;
ax = gca;
plotVep(x,gammaT(idx1,:),1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(x,gammaT(idxCtl,:),1,ax,{'Color',ax.ColorOrder(3,:)});
title('With Thresholding')
legend('LGN','Control')
ax.XLim = [-5,10];
makeFigureBig(h);

h = figure;
ax = gca;
plotVep(x,gammaMyFileIO(idx1,:),1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(x,gammaMyFileIO(idxCtl,:),1,ax,{'Color',ax.ColorOrder(3,:)});
title('My File IO and Thresholding')
legend('LGN','Control')
ax.XLim = [-5,15];
makeFigureBig(h);

%% Anova
rhythm = real([hGammaN(:); gammaN(:); betaN(:); alphaN(:)]);
tmG = repmat(x',[size(hGammaN,1)*4,1]);
% groupT = num2cell(tmG);
groupT = cell(size(tmG));
for ii = 1:length(tmG)
    groupT{ii} = num2str(tmG(ii));
end
groupR = cell(size(groupT));
[groupR{1:length(hGammaT(:))}] = deal('HG');
[groupR{(length(hGammaT(:))+1):2*length(hGammaT(:))}] = deal('G');
[groupR{(2*length(hGammaT(:))+1):3*length(hGammaT(:))}] = deal('B');
[groupR{(3*length(hGammaT(:))+1):end}] = deal('A');

[pvals, table, stats] = anovan(rhythm,{groupR groupT});