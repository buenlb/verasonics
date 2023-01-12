function curP = durableAnova(var2plot,tWindow,tm,idxLeft,idxRight)

var2test = var2plot;
var2plot = var2test;

inters = {[-10,-5],[5.0,30.0]};
curP = zeros(size(inters));
for hh = 1:length(inters)
    tmpTm = inters{hh}(1):tWindow/60:inters{hh}(2);
    tmIdx = zeros(size(tmpTm));
    for ii = 1:length(tmpTm)
        tmIdx(ii) = find(tm==tmpTm(ii)*60)
    end
    
    tmpL = var2test(idxLeft,tmIdx);
    tmpR = var2test(idxRight,tmIdx);
    
    var = [tmpL;tmpR];
    group1 = cell(size(var));
    group2 = nan(size(var));
    for ii = 1:size(tmpL,1)
        for jj = 1:size(tmpL,2)
            group1{ii,jj} = 'Left';
        end
    end
    
    for ii = 1:size(tmpR,1)
        for jj = 1:size(tmpR,2)
            group1{ii+size(tmpL,1),jj} = 'Right';
        end
    end
    
    for ii = 1:size(group2,1)
        for jj = 1:size(group2,2)
            group2(ii,jj) = tm(tmIdx(jj))/60;
        end
    end

    [p,tbl,stats,interaction] = anovan(var(:),{group1(:),group2(:)},'model','interaction','varnames',{'Side','Time'});
    curP(hh) = p(1);
end
for t = 2 : size(tbl, 1) - 2
    fprintf('%s \t F(%d,%d) = %.2f, p = %.2g\n', tbl{t, 1}, tbl{t, 3}, tbl{size(tbl, 1) - 1, 3}, tbl{t, 6}, tbl{t, 7});
end
% close all hidden
h = figure;
ax = gca;
yLeft = mean(var2plot(idxLeft,:),1,'omitnan');
yLeftSem = semOmitNan(var2plot(idxLeft,:),1);
yRight = mean(var2plot(idxRight,:),1,'omitnan');
yRightSem = semOmitNan(var2plot(idxRight,:),1);
% shadedErrorBar(tm/60,yLeft,yLeftSem,'lineprops',{'Color',ax.ColorOrder(1,:),'linewidth',2})
hold on;
shadedErrorBar(tm/60,yRight,yRightSem,'lineprops',{'Color',ax.ColorOrder(2,:),'linewidth',2})
if exist('idxCtl','var')
    yCtl = mean(var2plot(idxCtl,:),1,'omitnan');
    yCtlSem = semOmitNan(var2plot(idxCtl,:),1);
    shadedErrorBar(tm/60,yCtl,yCtlSem,'lineprops',{'Color',ax.ColorOrder(3,:),'linewidth',2})
end
% keyboard
% sigstar(inters,curP)
ax.XLim = [0,60];
% axis([-10,25,30,70])
% ax.XLim = [0,25];
% ax.XLim = [0,40];
plot([-120,120],[1,1]*66.67,'k:')
plot([-120,120],[1,1]*33.33,'k:')
plot([-120,120],[1,1]*50,'--','Color',[0.5,0.5,0.5])
% plot([-120,120],[1,1]*50,'k-')
plot([-120,120],[1,1]*75,'k-.')
plot([-120,120],[1,1]*25,'k-.')
xlabel('Time (minutes)')
ylabel('Leftward Bias (%)')
if ~exist('idxCtl','var')
    legend('Left LGN','Right LGN','Location','southwest')
else
    legend('Left LGN','Right LGN','Control','Location','southwest')
end
ax.YLim = [20,80];
makeFigureBig(h);
for ii = 1:length(inters)
    disp(['Interval:', num2str(inters{ii}(1)),':',num2str(inters{ii}(2)),'; p-value',num2str(curP(ii))])
end
% h = figure;
% plot(tm/60,sum(var2plot([idxLeft,idx])))


