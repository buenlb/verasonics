clear; close all; clc;

BOLTZ = 1;
EULER = 1;
EEG = 0;

if BOLTZ
    pth = 'D:\Task\Boltz\durable\';
    % pth = 'D:\Task\Euler\durable\';
    % pth = 'C:\Data\Task\Euler\durable\';
    files = dir([pth,'*.mat',]);
    
    if exist([pth,'curData.mat'],'file')
        old = load([pth,'curData.mat']);
    end
    
    curIdx = 1;
    found = 0;
    for ii = 1:length(files)
        monk(curIdx) = 'b';
        if strcmp(files(ii).name,'curData.mat')
            continue
        end
        if exist('old','var')
            disp(['File ', num2str(ii), ' of ', num2str(length(files))])
            for jj = 1:length(old.processedFiles)
                if strcmp([pth,files(ii).name],old.processedFiles{jj})
                    oldIdx = jj;
                    found = 1;
                    disp('Already Processed, Loading...')
                    break
                end
            end
        else
            found = 0;
        end
        if found
            if ~isfield(old.tData(oldIdx),'usBlock')
                old.tData(oldIdx).usBlock = 40;
            elseif isempty(old.tData(oldIdx).usBlock)
                old.tData(oldIdx).usBlock = 40;
            end
            tData(curIdx) = old.tData(oldIdx);
            processedFiles{curIdx} = old.processedFiles{oldIdx};
            curIdx = curIdx+1;
        else
            try
                tData(curIdx) = processTaskDataDurable([pth,files(ii).name]);
                processedFiles{curIdx} = [pth,files(ii).name];
                curIdx = curIdx+1;
            catch me
                warning(['Loading of file:', files(ii).name, ' failed.']);
                keyboard
            end
        end
        found = 0;
    end
    save([pth,'curData.mat'],'tData','processedFiles');
end

if EULER
    if ~BOLTZ
        curIdx = 1;
    end
    % pth = 'D:\Task\Boltz\durable\';
    pth = 'D:\Task\Euler\durable\';
%     pth = 'C:\Data\Task\Euler\durable\';
    files = dir([pth,'*.mat',]);
    
    if exist([pth,'curData.mat'],'file')
        old = load([pth,'curData.mat']);
    end
    found = 0;
    for ii = 1:length(files)
        monk(curIdx) = 'e';
        if strcmp(files(ii).name,'curData.mat')
            continue
        end
        if exist('old','var')
            disp(['File ', num2str(ii), ' of ', num2str(length(files))])
            for jj = 1:length(old.processedFiles)
                if strcmp([pth,files(ii).name],old.processedFiles{jj})
                    oldIdx = jj;
                    found = 1;
                    disp('Already Processed, Loading...')
                    break
                end
            end
        else
            found = 0;
        end
        if found
            tData(curIdx) = old.tData(oldIdx);
            processedFiles{curIdx} = old.processedFiles{oldIdx};
            curIdx = curIdx+1;
        else
            try
                tData(curIdx) = processTaskDataDurable([pth,files(ii).name]);
                processedFiles{curIdx} = [pth,files(ii).name];
                curIdx = curIdx+1;
            catch
                warning(['Loading of file:', files(ii).name, ' failed.']);
            end
        end
        found = 0;
    end
    save([pth,'curData.mat'],'tData','processedFiles');
end

%%
% runJanScripts
% return
date = struct('year',[],'month',[],'day',[]);
tA = [];
if EEG
    eegLeft = cell(size(tData));
    eegRight= cell(size(tData));
%     tEeg = cell(size(tData));
%     eeg = cell(size(tData));
    trId = cell(size(tData));
    taskIdx = cell(size(tData));
    for ii = 1:length(processedFiles)
        disp(['  Processing EEG data in session ', num2str(ii), ' of ', num2str(length(processedFiles))])
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
%         if isempty(tA)
%             [tA,eegLeft{ii},eegRight{ii},~,tEeg{ii},eeg{ii},~,~,trId{ii},taskIdx{ii}] =...
%                 loadEEGTaskData(pth,baseName,tData(ii));
%         else
%             [~,eegLeft{ii},eegRight{ii},~,tEeg{ii},eeg{ii},~,~,trId{ii},taskIdx{ii}] =...
%                 loadEEGTaskData(pth,baseName,tData(ii));
%         end
        if isempty(tA)
            [tA,eegLeft{ii},eegRight{ii},~,tEeg,eeg,~,~,trId{ii},taskIdx{ii}] =...
                loadEEGTaskData(pth,baseName,tData(ii));
        else
            [~,eegLeft{ii},eegRight{ii},~,tEeg,eeg,~,~,trId{ii},taskIdx{ii}] =...
                loadEEGTaskData(pth,baseName,tData(ii));
        end
        eegWindow1 = 500e-3;
        eegWindow2 = 60*5;
        eegWindowSep = 30;
        if isempty(eeg)
            continue
        end
        tAligned = alignEegSpectra({tEeg},tData(ii),taskIdx(ii),trId(ii));
        spectra = eegSpectra(tAligned,{eeg},eegWindow1);
        spectra2(ii) = smoothFrequencyBands(spectra,eegWindow2,eegWindowSep);
        keyboard
        toc
    end
%     eegWindow1 = 500e-3;
%     eegWindow2 = 60*5;
%     eegWindowSep = 30;
%     tAligned = alignEegSpectra(tEeg,tData,taskIdx,trId);
%     spectra = eegSpectra(tAligned,eeg,eegWindow1);
%     spectra2 = smoothFrequencyBands(spectra,eegWindow2,eegWindowSep);
end

%% Find relevant sessions
nBlocksBeforeAfter = 1;
blocksToSkip = 0;
usBlock = 40;

curLeft = 1;
curRight = 1;
curCtl = 1;
clear idxRight idxLeft idxCtl
% desiredVoltage = 17.7;
% desiredVoltage2 = 0;
desiredVoltage2 = 9;
desiredVoltage = 25.6;
for ii = 1:length(tData)
    if sum(isnan(tData(ii).sonicationProperties.FocalLocation)) &&...
            (tData(ii).sonicationProperties.voltage == desiredVoltage || tData(ii).sonicationProperties.voltage == desiredVoltage2)...
            && tData(ii).Block(end)>tData(ii).usBlock+blocksToSkip-1+nBlocksBeforeAfter
        idxCtl(curCtl) = ii;
        curCtl = curCtl+1;
    elseif sum(tData(ii).lgn)<0 &&...
            (tData(ii).sonicationProperties.voltage == desiredVoltage || tData(ii).sonicationProperties.voltage == desiredVoltage2)...
            && tData(ii).Block(end)>tData(ii).usBlock+blocksToSkip-1+nBlocksBeforeAfter
        idxLeft(curLeft) = ii;
        curLeft = curLeft+1;
    elseif sum(tData(ii).lgn)>0 &&...
            (tData(ii).sonicationProperties.voltage == desiredVoltage || tData(ii).sonicationProperties.voltage == desiredVoltage2)...
            && tData(ii).Block(end)>tData(ii).usBlock+blocksToSkip-1+nBlocksBeforeAfter
        idxRight(curRight) = ii;
        curRight = curRight+1;
    end
end

if exist('idxCtl','var')
    idx = idxCtl;
    clear newTCtl;
    for ii = 1:length(idx)
        newTCtl(ii) = selectTrials(tData(idx(ii)),~isnan(tData(idx(ii)).ch)&tData(idx(ii)).correctDelay);
        if newTCtl(ii).usBlock ~= 40
            disp(['Adjusting Block Center ', processedFiles{idx(ii)}])
            newTCtl(ii) = matchUsBlocks(newTCtl(ii),40);
        end
    end
end

% idxLeft = 34;
idx = idxLeft;
clear newTLeft;
for ii = 1:length(idx)
    newTLeft(ii) = selectTrials(tData(idx(ii)),~isnan(tData(idx(ii)).ch)&tData(idx(ii)).correctDelay);
    if newTLeft(ii).usBlock ~= 40
        disp(['Adjusting Block Center ', processedFiles{idx(ii)}])
        newTLeft(ii) = matchUsBlocks(newTLeft(ii),40);
    end
end

% idxRight = 35;
idx = idxRight;
clear newTRight;
for ii = 1:length(idx)
    newTRight(ii) = selectTrials(tData(idx(ii)),~isnan(tData(idx(ii)).ch)&tData(idx(ii)).correctDelay);
    if newTRight(ii).usBlock ~= 40
        disp(['Adjusting Block Center ', processedFiles{idx(ii)}])
        newTRight(ii) = matchUsBlocks(newTRight(ii),40);
    end
end

%% Plot EEG
minT = 0;
maxT = 0;
if EEG
    for ii = 1:length(spectra2)
        if length(spectra2(ii).windowTime)<2
            continue
        end
        if min(spectra2(ii).windowTime) < minT
            minT = min(spectra2(ii).windowTime);
        end
        if max(spectra2(ii).windowTime) > maxT
            maxT = max(spectra2(ii).windowTime);
        end
    end

    t = minT:eegWindowSep:maxT;
    delta = nan(size(spectra2(1).delta,1),length(spectra2),length(t));
    theta = nan(size(spectra2(1).delta,1),length(spectra2),length(t));
    alpha = nan(size(spectra2(1).delta,1),length(spectra2),length(t));
    beta = nan(size(spectra2(1).delta,1),length(spectra2),length(t));
    gamma = nan(size(spectra2(1).delta,1),length(spectra2),length(t));
    gen = nan(size(spectra2(1).delta,1),length(spectra2),length(t),size(spectra2(1).all0to100,3));
    for ii = 1:length(spectra2)
        if length(spectra2(ii).windowTime)<2
            continue
        end
        [~,curMin] = min(abs(t-spectra2(ii).windowTime(1)));
        [~,curMax] = min(abs(t-spectra2(ii).windowTime(end)));
        for jj = 1:size(spectra2(ii).delta,1)
            delta(jj,ii,curMin:curMax) = abs(spectra2(ii).delta(jj,:));
            theta(jj,ii,curMin:curMax) = abs(spectra2(ii).theta(jj,:));
            alpha(jj,ii,curMin:curMax) = abs(spectra2(ii).alpha(jj,:));
            beta(jj,ii,curMin:curMax) = abs(spectra2(ii).beta(jj,:));
            gamma(jj,ii,curMin:curMax) = abs(spectra2(ii).gamma(jj,:));
            gen(jj,ii,curMin:curMax,:) = abs(spectra2(ii).all0to100(jj,:,:));
        end
    end
    % Average across the pins
    delta = squeeze(mean(delta,1,'omitnan'));
    theta = squeeze(mean(theta,1,'omitnan'));
    alpha = squeeze(mean(alpha,1,'omitnan'));
    beta = squeeze(mean(beta,1,'omitnan'));
    gamma = squeeze(mean(gamma,1,'omitnan'));
    gen = squeeze(mean(gen,1,'omitnan'));

    idx1 = [idxRight,idxLeft];
    idx2 = idxCtl;
    h = figure;
    h.Position = [962    42   958   954];
    subplot(511)
    ax = gca;
    plotVep(t/60,delta(idx1,:),1,ax,{'Color',ax.ColorOrder(1,:)});
    plotVep(t/60,delta(idx2,:),1,ax,{'Color',ax.ColorOrder(2,:)});
    ax.XLim = [-10,15];
    ax.YLim = [0.5*mean(delta(:),'omitnan'),1.5*mean(delta(:),'omitnan')];
    makeFigureBig(h);

    subplot(512)
    ax = gca;
    plotVep(t/60,theta(idx1,:),1,ax,{'Color',ax.ColorOrder(1,:)});
    plotVep(t/60,theta(idx2,:),1,ax,{'Color',ax.ColorOrder(2,:)});
    ax.XLim = [-10,15];
    ax.YLim = [0.5*mean(theta(:),'omitnan'),1.5*mean(theta(:),'omitnan')];
    makeFigureBig(h);

    subplot(513)
    ax = gca;
    plotVep(t/60,alpha(idx1,:),1,ax,{'Color',ax.ColorOrder(1,:)});
    plotVep(t/60,alpha(idx2,:),1,ax,{'Color',ax.ColorOrder(2,:)});
    ax.XLim = [-10,15];
    ax.YLim = [0.5*mean(alpha(:),'omitnan'),1.5*mean(alpha(:),'omitnan')];
    makeFigureBig(h);

    subplot(514)
    ax = gca;
    plotVep(t/60,beta(idx1,:),1,ax,{'Color',ax.ColorOrder(1,:)});
    plotVep(t/60,beta(idx2,:),1,ax,{'Color',ax.ColorOrder(2,:)});
    ax.XLim = [-10,15];
    ax.YLim = [0.5*mean(beta(:),'omitnan'),1.5*mean(beta(:),'omitnan')];
    makeFigureBig(h);

    %%
%     subplot(515)
    h = figure;
    ax = gca;
    plotVep(t/60,gamma(idx1,:),1,ax,{'Color',ax.ColorOrder(1,:)});
    plotVep(t/60,gamma(idx2,:),1,ax,{'Color',ax.ColorOrder(2,:)});
    ax.XLim = [-10,15];
    ax.YLim = [0.5*mean(gamma(:),'omitnan'),2*mean(gamma(:),'omitnan')];
    makeFigureBig(h);

    h = figure;
    genIdx = find(spectra2(1).frequencies>30&spectra2(1).frequencies<=100);
    ax = gca;
    plotVep(t/60,mean(gen(idx1,:,genIdx),3,'omitnan'),1,ax,{'Color',ax.ColorOrder(1,:)});
    plotVep(t/60,mean(gen(idx2,:,genIdx),3,'omitnan'),1,ax,{'Color',ax.ColorOrder(2,:)});
    ax.XLim = [-10,15];
    ax.YLim = [0.5*mean(gamma(:),'omitnan'),2*mean(gamma(:),'omitnan')];
    makeFigureBig(h);
%% Bar Plots of spectra
    t1 = -5.5*60;
    t2 = 5.5*60;
    h = figure;
    hold on
    ax = gca;
    idxBefore = find(t==t1);
    idxAfter = find(t==t2);
    bar(1:2,[mean(delta(idx1,idxBefore),'omitnan'),mean(delta(idx1,idxAfter),'omitnan')])
    eb = errorbar(1:2,[mean(delta(idx1,idxBefore),'omitnan'),mean(delta(idx1,idxAfter),'omitnan')],...
        [std(delta(idx1,idxBefore),'omitnan'),std(delta(idx1,idxAfter),'omitnan')]/sqrt(sum(~isnan(delta(idx1,idxBefore)))));
    set(eb,'linestyle','none','linewidth',2,'Color',ax.ColorOrder(1,:));

    [~,p] = ttest2(delta(idx1,idxBefore),delta(idx1,idxAfter));
    
    title(['\delta (p=', num2str(p,2),')']);
    ax.XTick = 1:2;
    ax.XTickLabel = {'Before','After'};
    ax.XTickLabelRotation = 90;
    makeFigureBig(h);

    h = figure;
    hold on
    ax = gca;
    idxBefore = find(t==t1);
    idxAfter = find(t==t2);
    bar(1:2,[mean(theta(idx1,idxBefore),'omitnan'),mean(theta(idx1,idxAfter),'omitnan')])
    eb = errorbar(1:2,[mean(theta(idx1,idxBefore),'omitnan'),mean(theta(idx1,idxAfter),'omitnan')],...
        [std(theta(idx1,idxBefore),'omitnan'),std(theta(idx1,idxAfter),'omitnan')]/sqrt(sum(~isnan(theta(idx1,idxBefore)))));
    set(eb,'linestyle','none','linewidth',2,'Color',ax.ColorOrder(1,:));

    [~,p] = ttest2(theta(idx1,idxBefore),theta(idx1,idxAfter));
    
    title(['\theta (p=', num2str(p,2),')']);
    ax.XTick = 1:2;
    ax.XTickLabel = {'Before','After'};
    ax.XTickLabelRotation = 90;
    makeFigureBig(h);

    h = figure;
    hold on
    ax = gca;
    idxBefore = find(t==t1);
    idxAfter = find(t==t2);
    bar(1:2,[mean(alpha(idx1,idxBefore),'omitnan'),mean(alpha(idx1,idxAfter),'omitnan')])
    eb = errorbar(1:2,[mean(alpha(idx1,idxBefore),'omitnan'),mean(alpha(idx1,idxAfter),'omitnan')],...
        [std(alpha(idx1,idxBefore),'omitnan'),std(alpha(idx1,idxAfter),'omitnan')]/sqrt(sum(~isnan(alpha(idx1,idxBefore)))));
    set(eb,'linestyle','none','linewidth',2,'Color',ax.ColorOrder(1,:));

    [~,p] = ttest2(alpha(idx1,idxBefore),alpha(idx1,idxAfter));
    
    title(['\alpha (p=', num2str(p,2),')']);
    ax.XTick = 1:2;
    ax.XTickLabel = {'Before','After'};
    ax.XTickLabelRotation = 90;
    makeFigureBig(h);

    h = figure;
    hold on
    ax = gca;
    idxBefore = find(t==t1);
    idxAfter = find(t==t2);
    bar(1:2,[mean(beta(idx1,idxBefore),'omitnan'),mean(beta(idx1,idxAfter),'omitnan')])
    eb = errorbar(1:2,[mean(beta(idx1,idxBefore),'omitnan'),mean(beta(idx1,idxAfter),'omitnan')],...
        [std(beta(idx1,idxBefore),'omitnan'),std(beta(idx1,idxAfter),'omitnan')]/sqrt(sum(~isnan(beta(idx1,idxBefore)))));
    set(eb,'linestyle','none','linewidth',2,'Color',ax.ColorOrder(1,:));

    [~,p] = ttest2(beta(idx1,idxBefore),beta(idx1,idxAfter));
    
    title(['\beta (p=', num2str(p,2),')']);
    ax.XTick = 1:2;
    ax.XTickLabel = {'Before','After'};
    ax.XTickLabelRotation = 90;
    makeFigureBig(h);

    h = figure;
    hold on
    ax = gca;
    idxBefore = find(t==t1);
    idxAfter = find(t==t2);
    bar(1:2,[mean(gamma(idx1,idxBefore),'omitnan'),mean(gamma(idx1,idxAfter),'omitnan')])
    eb = errorbar(1:2,[mean(gamma(idx1,idxBefore),'omitnan'),mean(gamma(idx1,idxAfter),'omitnan')],...
        [std(gamma(idx1,idxBefore),'omitnan'),std(gamma(idx1,idxAfter),'omitnan')]/sqrt(sum(~isnan(gamma(idx1,idxBefore)))));
    set(eb,'linestyle','none','linewidth',2,'Color',ax.ColorOrder(1,:));

    [~,p] = ttest2(gamma(idx1,idxBefore),gamma(idx1,idxAfter));
    
    title(['\gamma (p=', num2str(p,2),')']);
    ax.XTick = 1:2;
    ax.XTickLabel = {'Before','After'};
    ax.XTickLabelRotation = 90;
    makeFigureBig(h);

    h = figure;
    hold on
    ax = gca;
    idxBefore = find(t==t1);
    idxAfter = find(t==t2);
    bar(1:2,[mean(mean(gen(idx1,idxBefore,genIdx),3,'omitnan'),1,'omitnan'),mean(mean(gen(idx1,idxAfter,genIdx),3,'omitnan'),1,'omitnan')])
    eb = errorbar(1:2,[mean(mean(gen(idx1,idxBefore,genIdx),3,'omitnan'),1,'omitnan'),mean(mean(gen(idx1,idxAfter,genIdx),3,'omitnan'),1,'omitnan')],...
        [std(gamma(idx1,idxBefore),'omitnan'),std(gamma(idx1,idxAfter),'omitnan')]/sqrt(sum(~isnan(gamma(idx1,idxBefore)))));
    set(eb,'linestyle','none','linewidth',2,'Color',ax.ColorOrder(1,:));

    [~,p] = ttest2(mean(gen(idx1,idxBefore,genIdx),3,'omitnan'),mean(gen(idx1,idxAfter,genIdx),3,'omitnan'));
    
    title(['\gamma (p=', num2str(p,2),')']);
    ax.XTick = 1:2;
    ax.XTickLabel = {'Before','After'};
    ax.XTickLabelRotation = 90;
    makeFigureBig(h);
%%
    gen2 = squeeze(mean(gen,1,'omitnan'));
    for ii = 1:size(gen,3)
%         gen2()
    end
    h = figure;
    ax = gca;
    imagesc(t/60,spectra2(1).frequencies,log10(gen2'))
    xlabel('time (minutes)')
    ylabel('frequency (Hz)')
    ax.XLim = [-5,15];
%     ax.YLim = [0,20];
    makeFigureBig(h);

%% VEPs
desiredDelay = 'a';
timeWindow = 5*60;
eegBefore = [];
eegAfter = [];
[~,~,~,~,~,idxBLeft,idxALeft] = beforeAfterSonicationTime(newTLeft,timeWindow,2);
for ii = 1:length(idxLeft)
    idxBefore = intersect(trId{idxLeft(ii)},idxBLeft{ii});
    idxAfter = intersect(trId{idxLeft(ii)},idxALeft{ii});
    if length(idxBefore)~=length(idxBLeft{ii})
        warning('Missing some trials before sonication in EEG')
    end
    if length(idxAfter)~=length(idxALeft{ii})
        warning('Missing some trials after sonication in EEG')
    end
    
    switch desiredDelay
        case 'n'
            idxBefore = intersect(idxBefore,find(newTLeft(ii).delay < 0));
            idxAfter = intersect(idxAfter,find(newTLeft(ii).delay < 0));
        case 'p'
            idxBefore = intersect(idxBefore,find(newTLeft(ii).delay > 0));
            idxAfter = intersect(idxAfter,find(newTLeft(ii).delay > 0));
        case 'z'
            idxBefore = intersect(idxBefore,find(newTLeft(ii).delay == 0));
            idxAfter = intersect(idxAfter,find(newTLeft(ii).delay == 0));
        case 'a'
        otherwise
            error('Bad Delay')
    end

    idxBeforeEeg = zeros(size(idxBefore));
    idxAfterEeg = zeros(size(idxAfter));
    for jj = 1:length(idxBefore)
        idxBeforeEeg(jj) = find(idxBefore(jj)==trId{idxLeft(ii)});
    end
    for jj = 1:length(idxAfter)
        idxAfterEeg(jj) = find(idxAfter(jj)==trId{idxLeft(ii)});
    end

    eegBefore = cat(1,eegBefore,eegLeft{idxLeft(ii)}(idxBeforeEeg,:));
    eegAfter = cat(1,eegAfter,eegLeft{idxLeft(ii)}(idxAfterEeg,:));
    eegBefore = cat(1,eegBefore,eegRight{idxLeft(ii)}(idxBeforeEeg,:));
    eegAfter = cat(1,eegAfter,eegRight{idxLeft(ii)}(idxAfterEeg,:));

%     h = figure(99);
%     clf
%     ax = gca;
%     plotVep (tA*1e3,[eegLeft{idxLeft(ii)}(idxBeforeEeg,:);eegRight{idxLeft(ii)}(idxBeforeEeg,:)],1,ax,{'Color', ax.ColorOrder(1,:)});
%     plotVep (tA*1e3,[eegLeft{idxLeft(ii)}(idxAfterEeg,:);eegRight{idxLeft(ii)}(idxAfterEeg,:)],1,ax,{'Color', ax.ColorOrder(2,:)});
%     waitforbuttonpress
end
h = figure;
ax = gca;
plotVep (tA*1e3,eegBefore,1,ax,{'Color', ax.ColorOrder(1,:)});
plotVep (tA*1e3,eegAfter,1,ax,{'Color', ax.ColorOrder(2,:)});
% p = addSignificance(eegBefore,eegAfter,tA*1e3,h,0.05);
legend('Before','After','location','southwest')
xlabel('time (ms)')
ylabel('voltage (mV)')
title('Left LGN')
axis([-800,800,-15,15])
makeFigureBig(h);

eegBefore = [];
eegAfter = [];
[~,~,~,~,~,idxBRight,idxARight] = beforeAfterSonicationTime(newTRight,timeWindow,2);
for ii = 1:length(idxRight)
    idxBefore = intersect(trId{idxRight(ii)},idxBRight{ii});
    idxAfter = intersect(trId{idxRight(ii)},idxARight{ii});
    if length(idxBefore)~=length(idxBRight{ii})
        warning('Missing some trials before sonication in EEG')
    end
    if length(idxAfter)~=length(idxARight{ii})
        warning('Missing some trials after sonication in EEG')
    end

    switch desiredDelay
        case 'n'
            idxBefore = intersect(idxBefore,find(newTRight(ii).delay < 0));
            idxAfter = intersect(idxAfter,find(newTRight(ii).delay < 0));
        case 'p'
            idxBefore = intersect(idxBefore,find(newTRight(ii).delay > 0));
            idxAfter = intersect(idxAfter,find(newTRight(ii).delay > 0));
        case 'z'
            idxBefore = intersect(idxBefore,find(newTRight(ii).delay == 0));
            idxAfter = intersect(idxAfter,find(newTRight(ii).delay == 0));
        case 'a'
        otherwise
            error('Bad Delay')
    end

    idxBeforeEeg = zeros(size(idxBefore));
    idxAfterEeg = zeros(size(idxAfter));
    for jj = 1:length(idxBefore)
        idxBeforeEeg(jj) = find(idxBefore(jj)==trId{idxRight(ii)});
    end
    for jj = 1:length(idxAfter)
        idxAfterEeg(jj) = find(idxAfter(jj)==trId{idxRight(ii)});
    end

    eegBefore = cat(1,eegBefore,eegRight{idxRight(ii)}(idxBeforeEeg,:));
    eegAfter = cat(1,eegAfter,eegRight{idxRight(ii)}(idxAfterEeg,:));
    eegBefore = cat(1,eegBefore,eegRight{idxRight(ii)}(idxBeforeEeg,:));
    eegAfter = cat(1,eegAfter,eegRight{idxRight(ii)}(idxAfterEeg,:));
end
h = figure;
ax = gca;
plotVep (tA*1e3,eegBefore,1,ax,{'Color', ax.ColorOrder(1,:)});
plotVep (tA*1e3,eegAfter,1,ax,{'Color', ax.ColorOrder(2,:)});
% p = addSignificance(eegBefore,eegAfter,tA*1e3,h,0.05);
legend('Before','After','location','southwest')
xlabel('time (ms)')
ylabel('voltage (mV)')
title('Right LGN')
axis([-800,800,-15,15])
makeFigureBig(h);

eegBefore = [];
eegAfter = [];
newTLGN = cat(2,newTLeft,newTRight);
[~,~,~,~,~,idxBBoth,idxABoth] = beforeAfterSonicationTime(newTLGN,timeWindow,2);
curIdx = [idxLeft,idxRight];
for ii = 1:length(curIdx)
    idxBefore = intersect(trId{curIdx(ii)},idxBBoth{ii});
    idxAfter = intersect(trId{curIdx(ii)},idxABoth{ii});
    if length(idxBefore)~=length(idxBBoth{ii})
        warning('Missing some trials before sonication in EEG')
    end
    if length(idxAfter)~=length(idxABoth{ii})
        warning('Missing some trials after sonication in EEG')
    end
    
    switch desiredDelay
        case 'n'
            idxBefore = intersect(idxBefore,find(newTLGN(ii).delay < 0));
            idxAfter = intersect(idxAfter,find(newTLGN(ii).delay < 0));
        case 'p'
            idxBefore = intersect(idxBefore,find(newTLGN(ii).delay > 0));
            idxAfter = intersect(idxAfter,find(newTLGN(ii).delay > 0));
        case 'z'
            idxBefore = intersect(idxBefore,find(newTLGN(ii).delay == 0));
            idxAfter = intersect(idxAfter,find(newTLGN(ii).delay == 0));
        case 'a'
        otherwise
            error('Bad Delay')
    end

    idxBeforeEeg = zeros(size(idxBefore));
    idxAfterEeg = zeros(size(idxAfter));
    for jj = 1:length(idxBefore)
        idxBeforeEeg(jj) = find(idxBefore(jj)==trId{curIdx(ii)});
    end
    for jj = 1:length(idxAfter)
        idxAfterEeg(jj) = find(idxAfter(jj)==trId{curIdx(ii)});
    end

    eegBefore = cat(1,eegBefore,eegLeft{curIdx(ii)}(idxBeforeEeg,:));
    eegAfter = cat(1,eegAfter,eegLeft{curIdx(ii)}(idxAfterEeg,:));
    eegBefore = cat(1,eegBefore,eegRight{curIdx(ii)}(idxBeforeEeg,:));
    eegAfter = cat(1,eegAfter,eegRight{curIdx(ii)}(idxAfterEeg,:));
end
h = figure;
ax = gca;
plotVep (tA*1e3,eegBefore,1,ax,{'Color', ax.ColorOrder(1,:)});
plotVep (tA*1e3,eegAfter,1,ax,{'Color', ax.ColorOrder(2,:)});
% p = addSignificance(eegBefore,eegAfter,tA*1e3,h,0.05);
legend('Before','After','location','southwest')
xlabel('time (ms)')
ylabel('voltage (mV)')
title('Both LGNs')
axis([-800,800,-15,15])
makeFigureBig(h);

end

%% Bar plot averaging by block number

[yLeft,pBLeft,pALeft] = beforeAfterSonication(newTLeft,usBlock,nBlocksBeforeAfter,blocksToSkip);
[yRight,pBRight,pARight] = beforeAfterSonication(newTRight,usBlock,nBlocksBeforeAfter,blocksToSkip);
if exist('idxCtl','var')
    [yCtl,pBCtl,pACtl] = beforeAfterSonication(newTCtl,usBlock,nBlocksBeforeAfter,blocksToSkip);
end

h = figure;
ax = gca;
bar(1,mean(yLeft)*100,'BaseValue',50);
hold on
bar(2,mean(yRight)*100,'BaseValue',50);
if exist('idxCtl','var')
    bar(3,mean(yCtl)*100,'BaseValue',50);
end
ax.ColorOrderIndex = 1;
eb = errorbar(1,mean(yLeft)*100,100*std(yLeft)/sqrt(length(yLeft)));
set(eb,'linestyle','none','linewidth',2)
eb = errorbar(2,mean(yRight)*100,100*std(yRight)/sqrt(length(yRight)));
set(eb,'linestyle','none','linewidth',2)
if exist('idxCtl','var')
    eb = errorbar(3,mean(yCtl)*100,100*std(yCtl)/sqrt(length(yCtl)));
    set(eb,'linestyle','none','linewidth',2)
end
xticks(1:2);
xticklabels({'Left','Right'})
xtickangle(90);
axis([0,4,25,75])
ylabel('Percent Leftward Choices')
% title(['Change at Equal Probability Point (n=', num2str(length(idxLeft)+length(idxRight)),')']);

[~,p1] = ttest2(yLeft,yRight);
if exist('idxCtl','var')
    [~,p2] = ttest2(yLeft,yCtl);
    [~,p3] = ttest2(yRight,yCtl);
    sigstar({[1,2],[1,3],[2,3]},[p1,p2,p3]);
else
    sigstar({[1,2]},p1);
end
makeFigureBig(h);

%% Time Bar Plot
timeWindow = 5*60;
[yLeft,~,~,nBefLeft,nAftLeft,idxBLeft,idxALeft] = beforeAfterSonicationTime(newTLeft,timeWindow,0);
[yRight,~,~,nBefRight,nAftRight,idxBRight,idxARight] = beforeAfterSonicationTime(newTRight,timeWindow,0);
if exist('idxCtl','var')
    [yCtl,~,~,nBefCtl,nAftCtl] = beforeAfterSonicationTime(newTCtl,timeWindow,0);
end

% yLeft = yLeft(nAftLeft>=100);
% yRight = yRight(nAftRight>=100);

h = figure;
ax = gca;
bar(1,mean(yLeft)*100,'BaseValue',50);
hold on
ax.ColorOrderIndex = 1;
eb = errorbar(1,mean(yLeft)*100,100*std(yLeft)/sqrt(length(yLeft)));
set(eb,'linestyle','none','linewidth',2)
if exist('idxCtl','var')
    ax.ColorOrderIndex = 2;
    bar(3,mean(yRight)*100,'BaseValue',50);
    ax.ColorOrderIndex = 3;
    bar(2,mean(yCtl)*100,'BaseValue',50);
    ax.ColorOrderIndex = 3;
    eb = errorbar(2,mean(yCtl)*100,100*std(yCtl)/sqrt(length(yCtl)));
    set(eb,'linestyle','none','linewidth',2)
    ax.ColorOrderIndex = 2;
    eb = errorbar(3,mean(yRight)*100,100*std(yRight)/sqrt(length(yRight)));
    set(eb,'linestyle','none','linewidth',2)
    xticks(1:3);
    xticklabels({'Left','Control','Right'})
else
    bar(2,mean(yRight)*100,'BaseValue',50);
    eb = errorbar(2,mean(yRight)*100,100*std(yRight)/sqrt(length(yRight)));
    set(eb,'linestyle','none','linewidth',2)
    xticks(1:2);
    xticklabels({'Left','Right'})
end

xtickangle(90);
axis([0,4,25,75])
ylabel('Percent Leftward Choices')
% title(['Change at Equal Probability Point (n=', num2str(length(idxLeft)+length(idxRight)),')']);

[~,p1] = ttest2(yLeft,yRight);
if exist('idxCtl','var')
    [~,p2] = ttest2(yLeft,yCtl);
    [~,p3] = ttest2(yRight,yCtl);
    ints = {[1,2],[1,3],[2,3]};
    p = [p2,p1,p3];
    sigstar(ints(p<0.05),p(p<0.05));
else
    sigstar({[1,2]},p1);
end
makeFigureBig(h);

%% Time based sigmoid comparison
curSession = 7;
[~,meanChoicesAfter,~,meanChoicesBefore,allDelays] = beforeAfterSonicationTimeSigmoid(tData(idxLeft),timeWindow,0);
delays = [];
for ii = 1:length(meanChoicesBefore)
    delays = cat(1,delays,allDelays{ii});
end
delays = unique(delays);

chAfter = nan(length(meanChoicesBefore),length(delays));
chBefore = nan(length(meanChoicesBefore),length(delays));
for ii = 1:length(meanChoicesAfter)
    for jj = 1:length(delays)
        if ~isempty(find(allDelays{ii}==delays(jj)))
            chAfter(ii,jj) = meanChoicesAfter{ii}(allDelays{ii}==delays(jj));
            chBefore(ii,jj) = meanChoicesBefore{ii}(allDelays{ii}==delays(jj));
        end
    end
end

h = figure;
ax = gca;

plot(delays,mean(chBefore,1,'omitnan'),'*','linewidth',3,'markersize',8)
hold on
ax.ColorOrderIndex = 1;
eb = errorbar(delays,mean(chBefore,1,'omitnan'),semOmitNan(chBefore,1));
set(eb,'linestyle','none')
[slope, bias, downshift, scale] = fitSigmoid(delays,mean(chBefore,1,'omitnan'));
x = linspace(min(delays),max(delays),1e3);
y = sigmoid_ext(x,slope,bias,downshift,scale);
p0Before = equalProbabilityPoint(slope,bias,downshift,scale);
ax.ColorOrderIndex = 1;
plt(1) = plot(x,y,'LineWidth',2);

ax.ColorOrderIndex = 2;
plot(delays,mean(chAfter,1,'omitnan'),'*','linewidth',3,'markersize',8)
hold on
ax.ColorOrderIndex = 2;
eb = errorbar(delays,mean(chAfter,1,'omitnan'),semOmitNan(chAfter,1));
set(eb,'linestyle','none')
[slope, bias, downshift, scale] = fitSigmoid(delays,mean(chAfter,1,'omitnan'));
x = linspace(min(delays),max(delays),1e3);
y = sigmoid_ext(x,slope,bias,downshift,scale);
p0After= equalProbabilityPoint(slope,bias,downshift,scale);
yAfter = sigmoid_ext(p0Before,slope,bias,downshift,scale);
ax.ColorOrderIndex = 2;
plt(2) = plot(x,y,'LineWidth',2);
title('Left LGN')
xlabel('Delays (ms)')
ylabel('Leftward Choices (%)')
legend(plt,'Before','After')
makeFigureBig(h)

disp(['Left Points of EP: Before: ', num2str(p0Before,3), 'ms. After: ', num2str(p0After,3),'ms'])
disp(['Left Percent Change at EP: ', num2str(100*yAfter,3),'%'])

% idxRight = 43;
[~,meanChoicesAfter,~,meanChoicesBefore,allDelays] = beforeAfterSonicationTimeSigmoid(tData(idxRight),timeWindow,0);
delays = [];
for ii = 1:length(meanChoicesBefore)
    delays = cat(1,delays,allDelays{ii});
end
delays = unique(delays);

chAfter = nan(length(meanChoicesBefore),length(delays));
chBefore = nan(length(meanChoicesBefore),length(delays));
for ii = 1:length(meanChoicesAfter)
    for jj = 1:length(delays)
        if ~isempty(find(allDelays{ii}==delays(jj)))
            chAfter(ii,jj) = meanChoicesAfter{ii}(allDelays{ii}==delays(jj));
            chBefore(ii,jj) = meanChoicesBefore{ii}(allDelays{ii}==delays(jj));
        end
    end
end

h = figure;
ax = gca;

plot(delays,mean(chBefore,1,'omitnan'),'*','linewidth',3,'markersize',8)
hold on
ax.ColorOrderIndex = 1;
eb = errorbar(delays,mean(chBefore,1,'omitnan'),semOmitNan(chBefore,1));
set(eb,'linestyle','none')
[slope, bias, downshift, scale] = fitSigmoid(delays,mean(chBefore,1,'omitnan'));
x = linspace(min(delays),max(delays),1e3);
y = sigmoid_ext(x,slope,bias,downshift,scale);
p0Before = equalProbabilityPoint(slope,bias,downshift,scale);
ax.ColorOrderIndex = 1;
plt(1) = plot(x,y,'LineWidth',2);

ax.ColorOrderIndex = 2;
plot(delays,mean(chAfter,1,'omitnan'),'*','linewidth',3,'markersize',8)
hold on
ax.ColorOrderIndex = 2;
eb = errorbar(delays,mean(chAfter,1,'omitnan'),semOmitNan(chAfter,1));
set(eb,'linestyle','none')
[slope, bias, downshift, scale] = fitSigmoid(delays,mean(chAfter,1,'omitnan'));
x = linspace(min(delays),max(delays),1e3);
y = sigmoid_ext(x,slope,bias,downshift,scale);
p0After= equalProbabilityPoint(slope,bias,downshift,scale);
yAfter = sigmoid_ext(p0Before,slope,bias,downshift,scale);
ax.ColorOrderIndex = 2;
plt(2) = plot(x,y,'LineWidth',2);
title('Right LGN')
xlabel('Delays (ms)')
ylabel('Leftward Choices (%)')
legend(plt,'Before','After')
makeFigureBig(h)

disp(['Right Points of EP: Before: ', num2str(p0Before,3), 'ms. After: ', num2str(p0After,3),'ms'])
disp(['Right Percent Change at EP: ', num2str(100*yAfter,3),'%'])

[~,meanChoicesAfter,~,meanChoicesBefore,allDelays] = beforeAfterSonicationTimeSigmoid(tData(idxCtl),timeWindow,0);
delays = [];
for ii = 1:length(meanChoicesBefore)
    delays = cat(1,delays,allDelays{ii});
end
delays = unique(delays);

chAfter = nan(length(meanChoicesBefore),length(delays));
chBefore = nan(length(meanChoicesBefore),length(delays));
for ii = 1:length(meanChoicesAfter)
    for jj = 1:length(delays)
        if ~isempty(find(allDelays{ii}==delays(jj)))
            chAfter(ii,jj) = meanChoicesAfter{ii}(allDelays{ii}==delays(jj));
            chBefore(ii,jj) = meanChoicesBefore{ii}(allDelays{ii}==delays(jj));
        end
    end
end

h = figure;
ax = gca;

plot(delays,mean(chBefore,1,'omitnan'),'*','linewidth',3,'markersize',8)
hold on
ax.ColorOrderIndex = 1;
eb = errorbar(delays,mean(chBefore,1,'omitnan'),semOmitNan(chBefore,1));
set(eb,'linestyle','none')
[slope, bias, downshift, scale] = fitSigmoid(delays,mean(chBefore,1,'omitnan'));
x = linspace(min(delays),max(delays),1e3);
y = sigmoid_ext(x,slope,bias,downshift,scale);
p0Before = equalProbabilityPoint(slope,bias,downshift,scale);
ax.ColorOrderIndex = 1;
plt(1) = plot(x,y,'LineWidth',2);

ax.ColorOrderIndex = 2;
plot(delays,mean(chAfter,1,'omitnan'),'*','linewidth',3,'markersize',8)
hold on
ax.ColorOrderIndex = 2;
eb = errorbar(delays,mean(chAfter,1,'omitnan'),semOmitNan(chAfter,1));
set(eb,'linestyle','none')
[slope, bias, downshift, scale] = fitSigmoid(delays,mean(chAfter,1,'omitnan'));
x = linspace(min(delays),max(delays),1e3);
y = sigmoid_ext(x,slope,bias,downshift,scale);
p0After= equalProbabilityPoint(slope,bias,downshift,scale);
yAfter = sigmoid_ext(p0Before,slope,bias,downshift,scale);
ax.ColorOrderIndex = 2;
plt(2) = plot(x,y,'LineWidth',2);
title('Control')
xlabel('Delays (ms)')
ylabel('Leftward Choices (%)')
legend(plt,'Before','After')
makeFigureBig(h)

disp(['Control Points of EP: Before: ', num2str(p0Before,3), 'ms. After: ', num2str(p0After,3),'ms'])
disp(['Control Percent Change at EP: ', num2str(100*yAfter,3),'%'])
return
%% Behavior over time
% idxRight = idxRight(1:3);
% idxLeft = idxLeft(1:3);
tWindow = 5*60;
dt = 30;
tBefore = 15*60;
tAfter = 60*60;
tm = -ceil(tBefore/dt)*dt:dt:ceil(tAfter/dt)*dt;

pTimeLeft = zeros(length(idxLeft),length(tm));
yTimeLeft = zeros(length(idxLeft),length(tm));
mTimeLeft = zeros(length(idxLeft),length(tm));
rawChLeft = zeros(length(idxLeft),length(tm));
nTrialsLeft = zeros(length(idxLeft),length(tm));
for ii = 1:length(idxLeft)
    disp(['Processing Left LGN (', num2str(ii), ' of ', num2str(length(idxLeft)),')'])
    [~,p0,~,~,~,bu] = behaviorOverTimeTime(newTLeft(ii),tWindow,[],-tWindow);
    [~,pTimeLeft(ii,:),yTimeLeft(ii,:),mTimeLeft(ii,:),rawChLeft(ii,:),nTrialsLeft(ii,:),bu2] = behaviorOverTimeTime(newTLeft(ii),tWindow,p0,tm);
end

pTimeRight = zeros(length(idxRight),length(tm));
yTimeRight = zeros(length(idxRight),length(tm));
mTimeRight = zeros(length(idxRight),length(tm));
rawChRight= zeros(length(idxLeft),length(tm));
nTrialsRight = zeros(length(idxRight),length(tm));
for ii = 1:length(idxRight)
    disp(['Processing Right LGN (', num2str(ii), ' of ', num2str(length(idxRight)),')'])
    [~,p0] = behaviorOverTimeTime(newTRight(ii),tWindow,[],-tWindow);
    [~,pTimeRight(ii,:),yTimeRight(ii,:),mTimeRight(ii,:),rawChRight(ii,:),nTrialsRight(ii,:)] = behaviorOverTimeTime(newTRight(ii),tWindow,p0,tm);
end

if exist('idxCtl','var')
    pTimeCtl = zeros(length(idxCtl),length(tm));
    yTimeCtl = zeros(length(idxCtl),length(tm));
    mTimeCtl = zeros(length(idxCtl),length(tm));
    rawChCtl = zeros(length(idxCtl),length(tm));
    nTrialsCtl = zeros(length(idxCtl),length(tm));
    for ii = 1:length(idxCtl)
        disp(['Processing Ctl LGN (', num2str(ii), ' of ', num2str(length(idxCtl)),')'])
        [~,p0,~,~,~,bu] = behaviorOverTimeTime(newTCtl(ii),tWindow,[],-tWindow);
        [~,pTimeCtl(ii,:),yTimeCtl(ii,:),mTimeCtl(ii,:),rawChCtl(ii,:),nTrialsCtl(ii,:),bu2] = behaviorOverTimeTime(newTCtl(ii),tWindow,p0,tm);
    end
end

%% Plot Results: bias
% Average the left
variableToPlot = yTimeLeft;

yTimeLeftMean = mean(variableToPlot,1,'omitnan');
yTimeLeftSem = std(variableToPlot,[],1,'omitnan')./sqrt(sum(~isnan(variableToPlot),1));

% Average the Right
variableToPlot = yTimeRight;

yTimeRightMean = mean(variableToPlot,1,'omitnan');
yTimeRightSem = std(variableToPlot,[],1,'omitnan')./sqrt(sum(~isnan(variableToPlot),1));

if exist('idxCtl','var')
    % Average the left
    variableToPlot = yTimeCtl;
    
    yTimeCtlMean = mean(variableToPlot,1,'omitnan');
    yTimeCtlSem = std(variableToPlot,[],1,'omitnan')./sqrt(sum(~isnan(variableToPlot),1));
end
windowShift = 5;
% Plot
h = figure;
ax = gca;
shadedErrorBar(tm/60+windowShift,100*yTimeLeftMean,100*yTimeLeftSem,'lineprops',{'linewidth',2,'Color',ax.ColorOrder(1,:)});
hold on
shadedErrorBar(tm/60+windowShift,100*yTimeRightMean,100*yTimeRightSem,'lineprops',{'linewidth',2,'Color',ax.ColorOrder(2,:)});
if exist('idxCtl','var')
    shadedErrorBar(tm/60+windowShift,100*yTimeCtlMean,100*yTimeCtlSem,'lineprops',{'linewidth',2,'Color',ax.ColorOrder(3,:)});
end
axis([0,20,30,70])
plot([-120,120],[1,1]*66.67,'k:')
plot([-120,120],[1,1]*33.33,'k:')
plot([-120,120],[1,1]*50,'k-')
plot([-120,120],[1,1]*75,'k-.')
plot([-120,120],[1,1]*25,'k-.')
plot([5.5,5.5]-windowShift  ,[30,70],'k--','linewidth',2)

% Show where it is significant
% p = addSignificance(yTimeLeft,yTimeRight,tm/60+windowShift,h,0.05);

legend('Left LGN','Right LGN','Control','location','northwest')
xlabel('Time (minutes)')
ylabel('Leftward Choices (%)')
% title(['Choice at Equal Probability Point (', num2str(tWindow/60),' minute window)'])
makeFigureBig(h);

%% Plot Results: Point of equal probability
% Average the left
variableToPlot = pTimeLeft;

yTimeLeftMean = mean(variableToPlot,1,'omitnan');
yTimeLeftSem = std(variableToPlot,[],1,'omitnan')./sqrt(sum(~isnan(variableToPlot),1));

% Average the Right
variableToPlot = pTimeRight;

yTimeRightMean = mean(variableToPlot,1,'omitnan');
yTimeRightSem = std(variableToPlot,[],1,'omitnan')./sqrt(sum(~isnan(variableToPlot),1));

% Average the Right
if exist('idxCtl','var')
    variableToPlot = pTimeCtl;
    
    yTimeCtlMean = mean(variableToPlot,1,'omitnan');
    yTimeCtlSem = std(variableToPlot,[],1,'omitnan')./sqrt(sum(~isnan(variableToPlot),1));
end

% Plot
h = figure;
ax = gca;
shadedErrorBar(tm/60,yTimeLeftMean,yTimeLeftSem,'lineprops',{'linewidth',2,'Color',ax.ColorOrder(1,:)});
hold on
shadedErrorBar(tm/60,yTimeRightMean,yTimeRightSem,'lineprops',{'linewidth',2,'Color',ax.ColorOrder(2,:)});
if exist('idxCtl','var')
    shadedErrorBar(tm/60,yTimeCtlMean,yTimeCtlSem,'lineprops',{'linewidth',2,'Color',ax.ColorOrder(3,:)});
end
axis([min(tm)/60,20,-40,40])

% Show where it is significant
addSignificance(pTimeLeft,pTimeRight,tm/60,h,0.05);

legend('Left LGN','Right LGN','Control','location','northwest')
xlabel('Time (minutes)')
ylabel('Leftward Choices (%)')
title(['No Bias Delay (', num2str(tWindow/60),' minute window)'])
makeFigureBig(h);

%% Plot results Contralateral Bias

% Average LGN targeting
variableToPlot = cat(1,1-yTimeLeft,yTimeRight);
contraChoice = variableToPlot;

yTimeRightMean = mean(variableToPlot,1,'omitnan');
yTimeRightSem = std(variableToPlot,[],1,'omitnan')./sqrt(sum(~isnan(variableToPlot),1));

if exist('idxCtl','var')
    % Average the left
    variableToPlot = yTimeCtl;
    
    yTimeCtlMean = mean(variableToPlot,1,'omitnan');
    yTimeCtlSem = std(variableToPlot,[],1,'omitnan')./sqrt(sum(~isnan(variableToPlot),1));
end

% Plot
h = figure;
ax = gca;
hold on
shadedErrorBar(tm/60,100*yTimeRightMean,100*yTimeRightSem,'lineprops',{'linewidth',2,'Color',ax.ColorOrder(2,:)});
if exist('idxCtl','var')
    shadedErrorBar(tm/60,100*yTimeCtlMean,100*yTimeCtlSem,'lineprops',{'linewidth',2,'Color',ax.ColorOrder(3,:)});
end
axis([-5,15,30,70])
plot([-120,120],[1,1]*66.67,'k:')
plot([-120,120],[1,1]*33.33,'k:')
plot([-120,120],[1,1]*50,'k-')
plot([-120,120],[1,1]*75,'k-.')
plot([-120,120],[1,1]*25,'k-.')

% Show where it is significant
p = addSignificance(contraChoice,yTimeCtl,tm/60,h,0.05);

legend('LGN','Control','location','northwest')
xlabel('Time (minutes)')
ylabel('Contralateral Choices (%)')
% title(['Choice at Equal Probability Point (', num2str(tWindow/60),' minute window)'])
makeFigureBig(h);
return
%% Behavior over time averaging by block number
nBlocks = 30;
blockSize = 3;
blocksBetween = 40;

yl = cell(size(newTLeft));
timeLeftTot = yl;
idxLeftTot = yl;
ylb = yl;
timeLeftTotB = yl;
idxLeftTotB = yl;
for ii = 1:length(idxLeft)
    disp(['Processing Left LGN (', num2str(ii), ' of ', num2str(length(idxLeft)),')'])
    
    [~,p0] = behaviorOverTimeBlocks(newTLeft(ii),nBlocks,[],blocksBetween-nBlocks);
    p0 = p0(1);

    [timeLeft,p50Left,yLeft,delZLeft,chLeft,idxLeftBlocks] =...
        behaviorOverTimeBlocks(newTLeft(ii),nBlocks,p0,42);

    [timeLeftBef,p50LeftBef,yLeftBef,~,~,idxLeftBlocksBef] =...
        behaviorOverTimeBlocks(newTLeft(ii),nBlocks,p0,0);
    
    yl{ii} = yLeft;
    idxLeftTot{ii} = idxLeftBlocks;
    timeLeftTot{ii} = timeLeft;

    ylb{ii} = yLeftBef;
    idxLeftTotB{ii} = idxLeftBlocksBef;
    timeLeftTotB{ii} = timeLeftBef;
end
yl = myCell2Mat(yl);
idxLeftTot = myCell2Mat(idxLeftTot);
timeLeftTot = myCell2Mat(timeLeftTot);

ylb = myCell2Mat(ylb);
idxLeftTotB = myCell2Mat(idxLeftTotB);
timeLeftTotB = myCell2Mat(timeLeftTotB);

yr = cell(size(newTRight));
idxRightTot = yr;
timeRightTot = yr;
yrb = yr;
timeRightTotB = yr;
idxRightTotB = yr;
for ii = 1:length(idxRight)
    disp(['Processing Right LGN (', num2str(ii), ' of ', num2str(length(idxRight)),')'])
    
    [~,p0] = behaviorOverTimeBlocks(newTRight(ii),nBlocks,[],blocksBetween-nBlocks);
    p0 = p0(1);

    [timeRight,p50Right,yRight,delZRight,chRight,idxRightBlocks] =...
        behaviorOverTimeBlocks(newTRight(ii),nBlocks,p0,42);

    [timeRightBef,p50RightBef,yRightBef,~,~,idxRightBlocksBef] =...
        behaviorOverTimeBlocks(newTRight(ii),nBlocks,p0,0);
    
    yr{ii} = yRight;
    idxRightTot{ii} = idxRightBlocks;
    timeRightTot{ii} = timeRight;

    yrb{ii} = yRightBef;
    idxRightTotB{ii} = idxRightBlocksBef;
    timeRightTotB{ii} = timeRightBef;
end
yr = myCell2Mat(yr);
idxRightTot = myCell2Mat(idxRightTot);
timeRightTot = myCell2Mat(timeRightTot);

yrb = myCell2Mat(yrb);
idxRightTotB = myCell2Mat(idxRightTotB);
timeRightTotB = myCell2Mat(timeRightTotB);

% Blocks
h = figure;
% timeC = 20*nBlocks/60;
timeC = 20/60;

ax = gca;

mxIdxRight = find(~isnan(idxRightTot(:,end)));
mxIdxRight = mxIdxRight(1);

mxIdxLeft = find(~isnan(idxLeftTot(:,end)));
mxIdxLeft = mxIdxLeft(1);

yLeftMean = 100*mean(yl,1,'omitnan');
yLeftSem = 100*std(yl,[],1,'omitnan')./sqrt(sum(~isnan(yl),1));

yRightMean = 100*mean(yr,1,'omitnan');
yRightSem = 100*std(yr,[],1,'omitnan')./sqrt(sum(~isnan(yr),1));

yLeftMeanB = 100*mean(ylb,1,'omitnan');
yLeftSemB = 100*std(ylb,[],1,'omitnan')./sqrt(sum(~isnan(ylb),1));
yLeftMeanB = yLeftMeanB(newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)))<=blocksBetween-nBlocks);
yLeftSemB = yLeftSemB(newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)))<=blocksBetween-nBlocks);
xLeftB = newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)));
xLeftB = xLeftB(xLeftB<=blocksBetween-nBlocks);

yRightMeanB = 100*mean(yrb,1,'omitnan');
yRightSemB = 100*std(yrb,[],1,'omitnan')./sqrt(sum(~isnan(yrb),1));
yRightMeanB = yRightMeanB(newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)))<=blocksBetween-nBlocks);
yRightSemB = yRightSemB(newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)))<=blocksBetween-nBlocks);
xRightB = newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)));
xRightB = xRightB(xRightB<=blocksBetween-nBlocks);

yLeftMeanS = 100*mean(ylb,1,'omitnan');
yLeftSemS = 100*std(ylb,[],1,'omitnan')./sqrt(sum(~isnan(ylb),1));
yLeftMeanS = yLeftMeanS(newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)))>blocksBetween-nBlocks&...
    newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)))<42);
yLeftSemS = yLeftSemS(newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)))>blocksBetween-nBlocks&...
    newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)))<42);
xLeftS = newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)));
xLeftS = xLeftS(xLeftS>blocksBetween-nBlocks&xLeftS<42);

yRightMeanS = 100*mean(yrb,1,'omitnan');
yRightSemS = 100*std(yrb,[],1,'omitnan')./sqrt(sum(~isnan(yrb),1));
yRightMeanS = yRightMeanS(newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)))>blocksBetween-nBlocks&...
    newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)))<42);
yRightSemS = yRightSemS(newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)))>blocksBetween-nBlocks&...
    newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)))<42);
xRightS = newTRight(mxIdxRight).Block((idxRightTotB(mxIdxRight,:)));
xRightS = xRightS(xRightS>blocksBetween-nBlocks&xRightS<42);

shadedErrorBar(newTLeft(mxIdxLeft).Block((idxLeftTot(mxIdxLeft,:))),yLeftMean,yLeftSem,'lineprops',{'linewidth',2,'Color',ax.ColorOrder(1,:)})
% plot((1:length(yLeft))*timeC,yLeft,'linewidth',2)
hold on
shadedErrorBar(newTRight(mxIdxRight).Block((idxRightTot(mxIdxRight,:))),yRightMean,yRightSem,'lineprops',{'linewidth',2,'Color',ax.ColorOrder(2,:)})
shadedErrorBar(xRightB,yRightMeanB,yRightSemB,'lineprops',{'linewidth',2,'Color',ax.ColorOrder(2,:)})
shadedErrorBar(xLeftB,yLeftMeanB,yLeftSemB,'lineprops',{'linewidth',2,'Color',ax.ColorOrder(1,:)})
shadedErrorBar(xLeftS,yLeftMeanS,yLeftSemS,'lineprops',{'linewidth',2,'Color',ax.ColorOrder(1,:),'linestyle','--'})
shadedErrorBar(xRightS,yRightMeanS,yRightSemS,'lineprops',{'linewidth',2,'Color',ax.ColorOrder(2,:),'linestyle','--'})

% plot([1,1],[1,1],'-','')
% plot((1:length(yRight))*timeC,yRight,'linewidth',2)
begSonication = 0;
% endSonication = blocksBetween+2-nBlocks/2;
% plot([1,1]*begSonication*timeC,[0,100],'k--',timeC*[1,1]*endSonication,[0,100],'k--')
% sn = polyshape([begSonication,begSonication,begSonication+0.5/timeC,begSonication+0.5/timeC]*timeC,[0,100,100,0]);
% plot(sn,'FaceAlpha',0.3,'FaceColor',ax.ColorOrder(5,:),'EdgeAlpha',0)
plot([0,120],[1,1]*66.67,'k:')
plot([0,120],[1,1]*33.33,'k:')
plot([0,120],[1,1]*50,'k-')

plot([0,120],[1,1]*75,'k-.')
plot([0,120],[1,1]*25,'k-.')
legend('Left LGN','Right LGN','location','northwest')
xlabel('Block')
ylabel('Leftward Choices (%)')
title(['Choice at Equal Probability Point. WS = ', num2str(nBlocks)])
axis([0,120,0,100])
makeFigureBig(h);
