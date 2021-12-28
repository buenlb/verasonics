function [delays,leftChoices_lLgn,leftChoices_rLgn,leftChoices_ctl,nTrials] = plotSessionAveragedSigmoids(tData,plotCtl,useActualDelays,delayBuckets,validIdx)
if ~exist('plotCtl','var')
    plotCtl = 0;
end
if ~exist('useActualDelays','var')
    useActualDelays = 1;
end
if ~exist('validIdx','var')
    validIdx = [];
end

if ~useActualDelays
    delays = [];
    % Select delays
    for ii = 1:length(tData)
        if exist('delayBuckets','var')
            error('delayBuckets is not yet implemented when useActualDelays is turned off');
        else
            delays = union(unique(tData(ii).delay),delays);
        end
    end
else
    if exist('delayBuckets','var')
        delays = delayBuckets;
    else
        delays = sortActualDelays(tData);
    end
    if size(delays,1)<size(delays,2)
        delays = delays';
    end
end
leftChoices_lLgn = nan(length(tData),length(delays));
leftChoices_rLgn = nan(length(tData),length(delays));
leftChoices_ctl = nan(length(tData),length(delays));
nTrials = zeros(3,length(delays));

%% Get averages at each delay
for ii = 1:length(tData)
    if ~isempty(validIdx)
        tmp = false(size(tData(ii).ch));
        if max(validIdx{ii})>length(tData(ii).ch)
            warning('Valid Index contains entries outside of the current session');
        end
        tmp(validIdx{ii}) = true;
        tData(ii).ch(~tmp) = nan;
    end
    if ~useActualDelays
        curDelays = unique(T2.delay);
        for jj = 1:length(curDelays)
            curIdx = find(curDelays(jj)==delays);
            leftChoices_lLgn(ii,curIdx) = mean(tData(ii).ch(tData(ii).lgn==-1 & tData(ii).delay==curDelays(jj) & tData(ii).correctDelay),'omitnan');
            leftChoices_rLgn(ii,curIdx) = mean(tData(ii).ch(tData(ii).lgn==1 & tData(ii).delay==curDelays(jj) & tData(ii).correctDelay),'omitnan');
            leftChoices_ctl(ii,curIdx) = mean(tData(ii).ch(tData(ii).lgn==0 & tData(ii).delay==curDelays(jj) & tData(ii).correctDelay),'omitnan');
        end
    else
        delayIdx = actualDelayMatch(tData(ii),delays);
        for jj = 1:length(delays)
            curDelayIdx = false(size(tData(ii).actualDelay));
            curDelayIdx(delayIdx==jj) = true;
            leftChoices_lLgn(ii,jj) = mean(tData(ii).ch(tData(ii).lgn==-1 & curDelayIdx),'omitnan');
            leftChoices_rLgn(ii,jj) = mean(tData(ii).ch(tData(ii).lgn==1 & curDelayIdx),'omitnan');
            leftChoices_ctl(ii,jj) = mean(tData(ii).ch(tData(ii).lgn==0 & curDelayIdx),'omitnan');
            nTrials(1,jj) = sum(tData(ii).lgn==-1 & curDelayIdx)+nTrials(1,jj);
            nTrials(2,jj) = sum(tData(ii).lgn==0 & curDelayIdx)+nTrials(2,jj);
            nTrials(3,jj) = sum(tData(ii).lgn==1 & curDelayIdx)+nTrials(3,jj);
        end
    end
end

totAvgL = mean(leftChoices_lLgn,1,'omitnan');
totAvgR = mean(leftChoices_rLgn,1,'omitnan');
totAvgC = mean(leftChoices_ctl,1,'omitnan');

h = figure;
hold on
ax = gca;
sigmoid_plot2(delays',totAvgL,[],ax.ColorOrder(1,:),4);
sigmoid_plot2(delays',totAvgR,[],ax.ColorOrder(2,:),4);
if plotCtl
    sigmoid_plot2(delays',totAvgC,[],ax.ColorOrder(3,:),4);
end
ax.ColorOrderIndex = 1;
plt = plot(0,0,'-',0,0,'-',0,0,'-','linewidth',2);
xl = xlabel('delays (ms)');
ylabel('% Leftward Choices');

if plotCtl
    legend(plt,'Left LGN','Right LGN','No US','location','northwest');
else
    legend(plt(1:2),'Left LGN','Right LGN','location','northwest');
end
%% Turn this code on/off to toggle a display of the number of sessions
% xl.Position = [1e-4,-0.05,-1];
% for ii = 1:length(delays)
%     tx = text(delays(ii),-0.15,num2str(sum(~isnan(leftChoices_lLgn(:,ii)))));
%     tx.Color = ax.ColorOrder(1,:);
%     
%     tx = text(delays(ii),-0.2,num2str(sum(~isnan(leftChoices_rLgn(:,ii)))));
%     tx.Color = ax.ColorOrder(2,:);
%     
%     if plotCtl
%         tx = text(delays(ii),-0.25,num2str(sum(~isnan(leftChoices_ctl(:,ii)))));
%         tx.Color = ax.ColorOrder(3,:);
%     end
% end
%%
set(h,'position',[359   444   614   352]);
makeFigureBig(h);