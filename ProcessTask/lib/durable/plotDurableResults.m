function h = plotDurableResults(tm,y,idxLeft,idxRight,idxCtl,h,xLim,yLim)

if ~exist('h','var')
    h = figure;
end

if isempty(idxCtl)
    clear idxCtl;
end
if ~exist('xLim','var')
    xLim = [0,20];
end
if ~exist('yLim','var')
    yLim = [20,80];
end

ax = gca;
yLeft = mean(y(idxLeft,:),1,'omitnan');
yLeftSem = semOmitNan(y(idxLeft,:),1);
yRight = mean(y(idxRight,:),1,'omitnan');
yRightSem = semOmitNan(y(idxRight,:),1);
shadedErrorBar(tm/60,yLeft,yLeftSem,'lineprops',{'Color',ax.ColorOrder(1,:),'linewidth',2})
hold on;
shadedErrorBar(tm/60,yRight,yRightSem,'lineprops',{'Color',ax.ColorOrder(2,:),'linewidth',2})
if exist('idxCtl','var')
    yCtl = mean(y(idxCtl,:),1,'omitnan');
    yCtlSem = semOmitNan(y(idxCtl,:),1);
    shadedErrorBar(tm/60,yCtl,yCtlSem,'lineprops',{'Color',ax.ColorOrder(3,:),'linewidth',2})
end
ax.XLim = [0,60];
plot([-120,120],[1,1]*66.67,'k-')
plot([-120,120],[1,1]*33.33,'k-')
plot([-120,120],[1,1]*50,'-','Color',[0.5,0.5,0.5])
% plot([-120,120],[1,1]*50,'k-')
plot([-120,120],[1,1]*75,'k-')
plot([-120,120],[1,1]*25,'k-')
xlabel('Time (minutes)')
ylabel('Leftward Bias (%)')
if ~exist('idxCtl','var')
    legend('Left LGN','Right LGN','Location','southwest')
else
    legend('Left LGN','Right LGN','Control','Location','southwest')
end
ax.YLim = yLim;
ax.XLim = xLim;
makeFigureBig(h);
