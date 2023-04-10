function h = plotDurableContralateralResults(tm,y,idxLeft,idxRight,h,idxCtl,xLim,yLim)

if ~exist('h','var')
    h = figure;
elseif isempty(h)
    h = figure;
end
figure(h);
ax = gca;
hold on;

if isempty(idxCtl)
    clear idxCtl;
end
if ~exist('xLim','var')
    xLim = [0,20];
end
if ~exist('yLim','var')
    yLim = [20,80];
end

contraVar = 100*y;
contraVar(idxLeft,:) = 100-contraVar(idxLeft,:);
idx = [idxLeft,idxRight];
contraVar = contraVar(idx,:);

contraVar(:,sum(~isnan(contraVar),1)<6) = nan;

shadedErrorBar(tm/60,mean(contraVar,1,'omitnan'),semOmitNan(contraVar,1),'lineprops',{'Color',ax.ColorOrder(ax.ColorOrderIndex,:),'linewidth',2})
if exist('idxCtl','var')
    contraVar = 100*y(idxCtl,:);
    shadedErrorBar(tm/60,mean(contraVar,1,'omitnan'),semOmitNan(contraVar,1),'lineprops',{'Color',ax.ColorOrder(ax.ColorOrderIndex,:),'linewidth',2})
end
ax.XLim = [0,60];
plot([-120,120],[1,1]*66.67,'k-')
plot([-120,120],[1,1]*33.33,'k-')
plot([-120,120],[1,1]*50,'-','Color',[0.5,0.5,0.5])
% plot([-120,120],[1,1]*50,'k-')
plot([-120,120],[1,1]*75,'k-')
plot([-120,120],[1,1]*25,'k-')
xlabel('Time (minutes)')
ylabel('Contralateral Bias (%)')
if exist('idxCtl','var')
    legend('Verum','Sham','Location','southwest')
end
ax.YLim = yLim;
ax.XLim = xLim;
makeFigureBig(h);
