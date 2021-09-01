close all;

yAxLims = [-20,10];

h = figure;
subplot(131)
hold on
ax = gca;
barHght = 100*[mean(chHigh.left),mean(chMid.left),mean(chLow.left)]-50;
barSem = 100*[std(chHigh.left)/sqrt(length(chHigh.left)),std(chMid.left)/sqrt(length(chMid.left)),std(chLow.left)/sqrt(length(chLow.left))];
bar(2:4,barHght);
eb = errorbar(2:4,barHght,barSem);
eb.LineStyle = 'none';
eb.Color = 'k';

intervals = {[2,3],[2,4],[3,4]};
[~,p1] = ttest2(chHigh.left,chMid.left);
[~,p2] = ttest2(chHigh.left,chLow.left);
[~,p3] = ttest2(chLow.left,chMid.left);
p = [p1,p2,p3];
intervals = intervals(p<0.05);
p = p(p<0.05);


title('Left LGN')
ylabel('Percent Leftward Choices')
ax.XTick = 2:4;
ax.XTickLabel= {'High','Center','Low'};
ylim(yAxLims);
xtickangle(90)
sigstar(intervals,p);
makeFigureBig(h)
ax.YTickLabel=[30:10:60];

subplot(132)
hold on
ax = gca;
ax.ColorOrderIndex = 3;
barHght = 100*[mean(chHigh.ctl),mean(chMid.ctl),mean(chLow.ctl)]-50;
barSem = 100*[std(chHigh.ctl)/sqrt(length(chHigh.ctl)),std(chMid.ctl)/sqrt(length(chMid.ctl)),std(chLow.ctl)/sqrt(length(chLow.ctl))];
bar(2:4,barHght);
eb = errorbar(2:4,barHght,barSem);
eb.LineStyle = 'none';
eb.Color = 'k';

intervals = {[2,3],[2,4],[3,4]};
[~,p1] = ttest2(chHigh.ctl,chMid.ctl);
[~,p2] = ttest2(chHigh.ctl,chLow.ctl);
[~,p3] = ttest2(chLow.ctl,chMid.ctl);
p = [p1,p2,p3];
intervals = intervals(p<0.05);
p = p(p<0.05);

title('No US')
ylabel('Percent Leftward Choices')
ax.XTick = 2:4;
ax.XTickLabel= {'High','Center','Low'};
ylim(yAxLims);
xtickangle(90)
sigstar(intervals,p);
makeFigureBig(h)
ax.YTickLabel=[30:10:60];

subplot(133)
hold on
ax = gca;
ax.ColorOrderIndex = 2;
barHght = 100*[mean(chHigh.right),mean(chMid.right),mean(chLow.right)]-50;
barSem = 100*[std(chHigh.right)/sqrt(length(chHigh.right)),std(chMid.right)/sqrt(length(chMid.right)),std(chLow.right)/sqrt(length(chLow.right))];
bar(2:4,barHght);
eb = errorbar(2:4,barHght,barSem);
eb.LineStyle = 'none';
eb.Color = 'k';

intervals = {[2,3],[2,4],[3,4]};
[~,p1] = ttest2(chHigh.right,chMid.right);
[~,p2] = ttest2(chHigh.right,chLow.right);
[~,p3] = ttest2(chLow.right,chMid.right);
p = [p1,p2,p3];
intervals = intervals(p<0.05);
p = p(p<0.05);
sigstar(intervals,p);

title('Right LGN')
ylabel('Percent Leftward Choices')
ax.XTick = 2:4;
ax.XTickLabel= {'High','Center','Low'};
ylim(yAxLims);
xtickangle(90)
makeFigureBig(h)
ax.YTickLabel=[30:10:60];
h.Position = [h.Position(1:2),h.Position(3)*2,h.Position(4)]