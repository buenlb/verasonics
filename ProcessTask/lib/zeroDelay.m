function [contra, ipsa, ch] = zeroDelay(tData,plotCtl)
ch = tData.ch(boolean(tData.lgn&tData.delay==0));
delay = tData.delay(boolean(tData.lgn&tData.delay==0));
lgn = tData.lgn(boolean(tData.lgn&tData.delay==0));

contra = (~isnan(ch)&delay==0&lgn==-1&ch==0) | (~isnan(ch)&delay==0&lgn==1&ch==1);
ipsa = (~isnan(ch)&delay==0&lgn==-1&ch==1) | (~isnan(ch)&delay==0&lgn==1&ch==0);


leftCh = tData.ch(tData.lgn==-1);
leftCh = leftCh(~isnan(leftCh));
rightCh = tData.ch(tData.lgn==1);
rightCh = rightCh(~isnan(rightCh));
cCh = tData.ch(~tData.lgn);
cCh = cCh(~isnan(cCh));

if plotCtl
    barH = 100*[mean(leftCh),mean(rightCh),mean(cCh)];
    barStd = 100*[std(leftCh)/sqrt(length(leftCh)),std(rightCh)/sqrt(length(rightCh)),std(cCh)/sqrt(length(cCh))];
else
    barH = 100*[mean(leftCh),mean(rightCh)];
    barStd = 100*[std(leftCh)/sqrt(length(leftCh)),std(rightCh)/sqrt(length(rightCh))];
end
h = figure;
ax1 = gca;
bar(2,barH(1),'FaceColor',ax1.ColorOrder(1,:));
hold on
bar(3,barH(2),'FaceColor',ax1.ColorOrder(2,:));
if plotCtl
    bar(4,barH(3),'FaceColor',ax1.ColorOrder(3,:));
    erBar = errorbar(2:4,barH,barStd);
else
    erBar = errorbar(2:3,barH,barStd);
end
erBar.Color = [0,0,0];
erBar.LineStyle = 'none';

if plotCtl
    ax1.XTick = 2:4;
    ax1.XTickLabel = {'Left','Right','None'};
else
    ax1.XTick = 2:3;
    ax1.XTickLabel = {'Left','Right'};
end
ylabel('Leftward Choices (%)')
makeFigureBig(h);

disp('*****Significance*****')
[~,p1] = ttest2(leftCh,rightCh);
disp(['Left/Right: p=',num2str(p1,2)])
[~,p2] = ttest2(leftCh,cCh);
disp(['Left/Ctl: p=',num2str(p2,2)])
[~,p3] = ttest2(cCh,rightCh);
disp(['Right/Ctl: p=',num2str(p3,2)])

% Show significance
if plotCtl
    intervals = {[2,3],[2,4],[3,4]};
    p = [p1 p2 p3];
else
    intervals = {[2,3]};
    p = p1;
end

intervals = intervals(p<=0.05);
p = p(p<0.05);

sigstar(intervals,p);
ch = struct('left',leftCh,'right',rightCh,'ctl',cCh);