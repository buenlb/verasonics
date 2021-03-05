function axs = plotTaskResults(tData)

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

rightDelay = rightDelay(~isnan(rightCh));
rightCh = rightCh(~isnan(rightCh));

leftDelay = leftDelay(~isnan(leftCh));
leftCh = leftCh(~isnan(leftCh));

cDelay = cDelay(~isnan(cCh));
cCh = cCh(~isnan(cCh));

h = figure;
ax1 = axes();
ax1.Position = [0.07,0.2,0.33,0.72];
barH = [mean(leftCh),mean(rightCh),mean(cCh)];
barStd = [std(leftCh)/sqrt(length(leftCh)),std(rightCh)/sqrt(length(rightCh)),std(cCh)/sqrt(length(cCh))];
bar(2,barH(1),'FaceColor',ax1.ColorOrder(1,:));
hold on
bar(3,barH(2),'FaceColor',ax1.ColorOrder(2,:));
bar(4,barH(3),'FaceColor',ax1.ColorOrder(3,:));
erBar = errorbar(2:4,barH,barStd);
erBar.Color = [0,0,0];
erBar.LineStyle = 'none';

ax1.XTick = 2:4;
ax1.XTickLabel = {'Left','Right','None'};
ylabel('Leftward Choices (%)')
makeFigureBig(h);

ax2 = axes();
ax2.Position = [0.47,0.24,0.43,0.72];
sigmoid_plot2(leftDelay',leftCh',1:length(leftCh),ax2.ColorOrder(1,:),4);
sigmoid_plot2(rightDelay',rightCh',1:length(rightCh),ax2.ColorOrder(2,:),4);
sigmoid_plot2(cDelay',cCh',1:length(cCh),ax2.ColorOrder(3,:),4);
ax2.ColorOrderIndex = 1;
plt = plot(-1,-1,'-',-1,-1,'-',-1,-1,'-','linewidth',2);
legend(plt,'Left','Right','None','location','northwest')
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
intervals = {[2,3],[2,4],[3,4]};
p = [p1 p2 p3];

intervals = intervals(p<=0.05);
p = p(p<0.05);

sigstar(intervals,p);

set(h,'position',[0.4880    0.1834    1.3034    0.45]*1e3);

ax3 = axes();
ax3.Position = [0.47,0,00.43,0.2];
hold on
text(ax2.XLim(1),0,'N Trials','Rotation',90)
for ii = 1:length(delayVector)
    text(delayVector(ii),0.75,num2str(length(ch(delay == delayVector(ii) & lgn==-1 & result < 3))),'Color',ax3.ColorOrder(1,:))
    text(delayVector(ii),0.45,num2str(length(ch(delay == delayVector(ii) & lgn==1 & result < 3))),'Color',ax3.ColorOrder(2,:))
    text(delayVector(ii),0.15,num2str(length(ch(delay == delayVector(ii) & lgn==0 & result < 3))),'Color',ax3.ColorOrder(3,:))
end
axis([ax2.XLim,0,1])
ax3.Visible  = 'off';
makeFigureBig(h)

axs = [ax1,ax2,ax3];