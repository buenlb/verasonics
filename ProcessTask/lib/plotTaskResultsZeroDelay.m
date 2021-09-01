function axs = plotTaskResultsZeroDelay(tData,bars2plot)

if ~exist('bars2plot','var')
    bars2plot = ones(1,3);
end

lgn = tData.lgn;
ch = tData.ch;
delay = tData.delay;
% delayVector = tData.delayVector;
% result = tData.result;

leftCh = ch(lgn==-1&delay==0&~isnan(ch));
rightCh = ch(lgn==1&delay==0&~isnan(ch));
cCh = ch(lgn==0&delay==0&~isnan(ch));

colorOrder = [1,3,2];

h = figure;
hold on
ax1 = gca;
barH = 100*[mean(leftCh),mean(cCh),mean(rightCh)];
barStd = 100*[std(leftCh)/sqrt(length(leftCh)),std(cCh)/sqrt(length(cCh)),std(rightCh)/sqrt(length(rightCh))];
for ii = 1:length(bars2plot)
    if bars2plot(ii)
        bar(ii+1,barH(ii),'faceColor',ax1.ColorOrder(colorOrder(ii),:));
        erBar = errorbar(ii+1,barH(ii),barStd(ii));
        erBar.Color = [0,0,0];
        erBar.LineStyle = 'none';
    end
end

[~,p1] = ttest2(leftCh,rightCh);
[~,p2] = ttest2(leftCh,cCh);
[~,p3] = ttest2(cCh,rightCh);

intIdx = 1;
if sum(bars2plot)>1
    if bars2plot(1)&&bars2plot(2)
        intervals{intIdx} = [2,3];
        p(intIdx) = p2;
        intIdx = intIdx+1;
    end
    if bars2plot(1)&&bars2plot(3)
        intervals{intIdx} = [2,4];
        p(intIdx) = p1;
        intIdx = intIdx+1;
    end
    if bars2plot(2)&&bars2plot(3)
        intervals{intIdx} = [3,4];
        p(intIdx) = p3;
        intIdx = intIdx+1;
    end
end
    
intervals = intervals(p<=0.05);
p = p(p<0.05);

sigstar(intervals,p);
makeFigureBig(h);

if 0
%% Sigmoid fit
lgn = tData.lgn;
ch = tData.ch;
delay = tData.delay;
delayVector = tData.delayVector;
result = tData.result;

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

ax2 = axes();
ax2.Position = [0.47,0.24,0.43,0.72];
sigmoid_plot2(leftDelay',leftCh',1:length(leftCh),ax2.ColorOrder(1,:),4);
sigmoid_plot2(rightDelay',rightCh',1:length(rightCh),ax2.ColorOrder(2,:),4);
if plotCtl
    sigmoid_plot2(cDelay',cCh',1:length(cCh),ax2.ColorOrder(3,:),4);
end
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

% set(h,'position',[0.4880    0.1834    1.3034    0.45]*1e3);
set(h,'position',[98         368        1708         456]);
ax3 = axes();
ax3.Position = [0.47,0,00.43,0.2];
hold on
text(ax2.XLim(1),0,'N Trials','Rotation',90)
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
end