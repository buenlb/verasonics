function axs = plotGrayScreen(tData)

axs(1) = plotEyeData_fixationWindow(tData);

axs(2) = plotEyeData_fixBreaks(tData);

m = computeM(tData,'usOn','choicemade',[0,50]);

h = figure;
ax = gca;

lgn = tData.lgn;

mRight = m(lgn>0);
mRight = mRight(~isnan(mRight));

mLeft = m(lgn<0);
mLeft = mLeft(~isnan(mLeft));

barH = 100*[mean(mLeft),mean(mRight)];
barStd = 100*[std(mLeft)/sqrt(length(mLeft)),std(mRight)/sqrt(length(mRight))];
bar(2,barH(1),'FaceColor',ax.ColorOrder(1,:));
hold on
bar(3,barH(2),'FaceColor',ax.ColorOrder(2,:));
erBar = errorbar(2:3,barH,barStd);
erBar.Color = [0,0,0];
erBar.LineStyle = 'none';

ax.XTick = 2:3;
ax.XTickLabel = {'Left','Right'};
ylabel('Time in Left Hemifield (%)')
makeFigureBig(h);

[~,p] = ttest2(mLeft,mRight);
intervals = {[2,3]};

intervals = intervals(p<=0.05);
p = p(p<=0.05);

sigstar(intervals,p);
axs(3) = ax;

ch = tData.ch;
chLeft = ch(lgn<0);
chRight = ch(lgn>0);

chLeft = chLeft(~isnan(chLeft));
chRight = chRight(~isnan(chRight));

h = figure;
ax = gca;

barH = 100*[mean(chLeft),mean(chRight)];
barStd = 100*[std(chLeft)/sqrt(length(chLeft)),std(chRight)/sqrt(length(chRight))];
bar(2,barH(1),'FaceColor',ax.ColorOrder(1,:));
hold on
bar(3,barH(2),'FaceColor',ax.ColorOrder(2,:));
erBar = errorbar(2:3,barH,barStd);
erBar.Color = [0,0,0];
erBar.LineStyle = 'none';

ax.XTick = 2:3;
ax.XTickLabel = {'Left','Right'};
ylabel('Leftward Choices (%)')
makeFigureBig(h);

[~,p] = ttest2(chLeft,chRight);
intervals = {[2,3]};

intervals = intervals(p<=0.05);
p = p(p<=0.05);

sigstar(intervals,p);
axs(4) = ax;


for ii = 1:length(ch)
    chTime(ii) = tData.timing(ii).eventTimes(6)-tData.timing(ii).eventTimes(3);
end
chTimeLeft = chTime(lgn<0);
chTimeRight = chTime(lgn>0);
chTimeLeft = chTimeLeft(~isnan(chTimeLeft));
chTimeRight = chTimeRight(~isnan(chTimeRight));

h = figure;
ax = gca;

barH = 1e3*[mean(chTimeLeft),mean(chTimeRight)];
barStd = 1e3*[std(chTimeLeft)/sqrt(length(chTimeLeft)),std(chTimeRight)/sqrt(length(chTimeRight))];
bar(2,barH(1),'FaceColor',ax.ColorOrder(1,:));
hold on
bar(3,barH(2),'FaceColor',ax.ColorOrder(2,:));
erBar = errorbar(2:3,barH,barStd);
erBar.Color = [0,0,0];
erBar.LineStyle = 'none';

ax.XTick = 2:3;
ax.XTickLabel = {'Left','Right'};
ylabel('Time of Choice')
makeFigureBig(h);

[~,p] = ttest2(chTimeLeft,chTimeRight);
intervals = {[2,3]};

intervals = intervals(p<=0.05);
p = p(p<=0.05);

sigstar(intervals,p);
axs(4) = ax;