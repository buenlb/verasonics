function axs = plotTaskResults(tData,makeDelaysEqual,plotCtl,taskType)

if ~exist('makeDelaysEqual','var')
    makeDelaysEqual = 0;
end

if ~exist('taskType','var')
    taskType = 'timing';
end

if ~exist('plotCtl','var')
    plotCtl = 1;
end

switch taskType
    case 'brightness'
        idx = logical(tData.task) & tData.correctDelay;
        delay = tData.brightnessOffset(idx);
        delayVector = tData.brightnessOffsetVector;
    case 'timing'
        idx = logical(~tData.task) & tData.correctDelay;
        delay = tData.delay(idx);
        delayVector = tData.delayVector;
    case 'all'
        idx = true(size(tData.task));
    otherwise
        error('Unrecognized Task Name!')
end

lgn = tData.lgn(idx);
ch = tData.ch(idx);

rightDelay = delay(lgn==1);
leftDelay = delay(lgn==-1);
cDelay = delay(lgn==0);

leftCh = ch(lgn==-1);
rightCh = ch(lgn==1);
cCh = ch(lgn==0);

if makeDelaysEqual
    [rightDelay,rightCh] = equalDelays(rightDelay,rightCh,delayVector);
    [leftDelay,leftCh] = equalDelays(leftDelay,leftCh,delayVector);
    [cDelay,cCh] = equalDelays(cDelay,cCh,delayVector);
end
rightDelay = rightDelay(~isnan(rightCh));
rightCh = rightCh(~isnan(rightCh));

leftDelay = leftDelay(~isnan(leftCh));
leftCh = leftCh(~isnan(leftCh));

cDelay = cDelay(~isnan(cCh));
cCh = cCh(~isnan(cCh));

h = figure;
ax1 = axes();
ax1.Position = [0.07,0.2,0.33,0.72];
if plotCtl
    barH = 100*[mean(leftCh),mean(cCh),mean(rightCh)];
    barStd = 100*[std(leftCh)/sqrt(length(leftCh)),std(cCh)/sqrt(length(cCh)),std(rightCh)/sqrt(length(rightCh))];
else
    barH = 100*[mean(leftCh),mean(rightCh)];
    barStd = 100*[std(leftCh)/sqrt(length(leftCh)),std(rightCh)/sqrt(length(rightCh))];
end
bar(2,barH(1),'FaceColor',ax1.ColorOrder(1,:));
hold on
if plotCtl
    bar(4,barH(3),'FaceColor',ax1.ColorOrder(2,:));
    bar(3,barH(2),'FaceColor',ax1.ColorOrder(3,:));
    erBar = errorbar(2:4,barH,barStd);
else
    bar(3,barH(2),'FaceColor',ax1.ColorOrder(2,:));
    erBar = errorbar(2:3,barH,barStd);
end
erBar.Color = [0,0,0];
erBar.LineStyle = 'none';

if plotCtl
    ax1.XTick = 2:4;
    ax1.XTickLabel = {'Left','None','Right'};
else
    ax1.XTick = 2:3;
    ax1.XTickLabel = {'Left','Right'};
end
ylabel('Leftward Choices (%)')
makeFigureBig(h);

ax2 = axes();
ax2.Position = [0.47,0.24,0.43,0.72];
if plotCtl
    sigmoid_plot2(cDelay',cCh',1:length(cCh),ax2.ColorOrder(3,:),4);
end
sigmoid_plot2(leftDelay',leftCh',1:length(leftCh),ax2.ColorOrder(1,:),4);
sigmoid_plot2(rightDelay',rightCh',1:length(rightCh),ax2.ColorOrder(2,:),4);
ax2.XLim = [min(cDelay),max(cDelay)];
ax2.ColorOrderIndex = 1;
if plotCtl
    plt = plot(-1,-1,'-',-1,-1,'-',-1,-1,'-','linewidth',2);
    legend(plt,'Left','Right','None','location','northwest')
else
    plt = plot(-1,-1,'-',-1,-1,'-','linewidth',2);
    legend(plt,'Left','Right','location','northwest')
end
    
xlabel('delay (ms)')
ylabel('Leftward Choice (%)')
makeFigureBig(h)

axes(ax1);
disp('*****Significance*****')
[~,p1] = ttest2(leftCh,rightCh);
disp(['Left/Right: p=',num2str(p1,2)])
[~,p2] = ttest2(leftCh,cCh);
disp(['Left/Ctl: p=',num2str(p2,2)])
[~,p3] = ttest2(cCh,rightCh);
disp(['Right/Ctl: p=',num2str(p3,2)])

% Show significance
if plotCtl
    intervals = {[2,4],[2,3],[3,4]};
    p = [p1 p2 p3];
else
    intervals = {[2,3]};
    p = p1;
end

intervals = intervals(p<=0.05);
p = p(p<0.05);

sigstar(intervals,p);

% set(h,'position',[0.4880    0.1834    1.3034    0.45]*1e3);
set(h,'position',[98         368        1708         456]);
ax3 = axes();
ax3.Position = [0.47,0,00.43,0.2];
hold on
text(ax2.XLim(1)-1/20*(ax2.XLim(2)-ax2.XLim(1)),0,'N Trials','Rotation',90)
for ii = 1:length(delayVector)
    text(delayVector(ii),0.75,num2str(sum(~isnan(leftCh) & leftDelay == delayVector(ii))),'Color',ax3.ColorOrder(1,:))
    text(delayVector(ii),0.45,num2str(sum(~isnan(rightCh) & rightDelay == delayVector(ii))),'Color',ax3.ColorOrder(2,:))
    if plotCtl
        text(delayVector(ii),0.15,num2str(sum(~isnan(cCh) & cDelay == delayVector(ii))),'Color',ax3.ColorOrder(3,:))
    end
end
axis([ax2.XLim,0,1])
ax3.Visible  = 'off';
makeFigureBig(h)

axs = [ax1,ax2,ax3];