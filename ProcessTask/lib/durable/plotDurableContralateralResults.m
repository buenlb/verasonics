function [h,mLine] = plotDurableContralateralResults(tm,y,idxLeft,idxRight,h,idxCtl,xLim,yLim)

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

% tmp = 100-100*y(idxLeft,:);
% tmp = mean(tmp,1,'omitnan');
% tmp2 = mean(100*y(idxRight,:),1,'omitnan');
% contraVar = mean([tmp;tmp2],1,'omitnan');
% contraVar = [tmp;tmp2];

s = shadedErrorBar(tm/60,mean(contraVar,1,'omitnan'),semOmitNan(contraVar,1),'lineprops',{'Color',ax.ColorOrder(ax.ColorOrderIndex,:),'linewidth',2});
mLine(1) = s.mainLine;
if exist('idxCtl','var')
    contraVar = 100*y(idxCtl,:);
    s = shadedErrorBar(tm/60,mean(contraVar,1,'omitnan'),semOmitNan(contraVar,1),'lineprops',{'Color',ax.ColorOrder(ax.ColorOrderIndex,:),'linewidth',2});
    mLine(2) = s.mainLine;
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
