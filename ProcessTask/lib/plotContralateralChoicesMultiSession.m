%% Convert to contralateral choices
leftSonication = find(sideSonicated<0);
rightSonication = find(sideSonicated>0);
ctlSonication = find(sideSonicated==0);

yContra = nan(size(y));
yContra(leftSonication,:) = 1-y(leftSonication,:);
yContra(rightSonication,:) = y(rightSonication,:);
yContra(ctlSonication,:) = y(ctlSonication,:);

%% Select indices
thrsh = 1.0;
ptIdx = find(Ispta>thrsh);
idxLeft = [];
idxRight = [];
idxCtl = [];
for ii = 1:length(ptIdx)
    disp(num2str(ii))
    idxLeft = cat(2,idxLeft,idxPts{ptIdx(ii)}(ss{ptIdx(ii)}==-1));
    idxRight = cat(2,idxRight,idxPts{ptIdx(ii)}(ss{ptIdx(ii)}==1));
    idxCtl = cat(2,idxCtl,idxPts{ptIdx(ii)}(ss{ptIdx(ii)}==0));
end

idxHigh = [idxLeft, idxRight];

ptIdx = 1:length(Ispta);
idxLeft = [];
idxRight = [];
idxCtl = [];
for ii = 1:length(ptIdx)
    disp(num2str(ii))
    idxLeft = cat(2,idxLeft,idxPts{ptIdx(ii)}(ss{ptIdx(ii)}==-1));
    idxRight = cat(2,idxRight,idxPts{ptIdx(ii)}(ss{ptIdx(ii)}==1));
    idxCtl = cat(2,idxCtl,idxPts{ptIdx(ii)}(ss{ptIdx(ii)}==0));
end

idxLow = idxCtl;

%% Plot change over time
% clear idxCtl
h = figure;
ax = gca;
yHigh = mean(yContra(idxHigh,:),1,'omitnan');
yHighSem = semOmitNan(yContra(idxHigh,:),1);
yLow = mean(yContra(idxLow,:),1,'omitnan');
yLowSem = semOmitNan(yContra(idxLow,:),1);
shadedErrorBar(tm/60+5,100*yHigh,100*yHighSem,'lineprops',{'Color',ax.ColorOrder(1,:),'linewidth',2})
hold on;
shadedErrorBar(tm/60+5,100*yLow,100*yLowSem,'lineprops',{'Color',ax.ColorOrder(3,:),'linewidth',2})
% if exist('idxCtl','var')
%     yCtl = mean(yContra(idxCtl,:),1,'omitnan');
%     yCtlSem = semOmitNan(yContra(idxCtl,:),1);
%     shadedErrorBar(tm/60+5,100*yCtl,100*yCtlSem,'lineprops',{'Color',ax.ColorOrder(3,:),'linewidth',2})
% end
axis([0,20,40,60])
plot([-120,120],[1,1]*66.67,'k:')
plot([-120,120],[1,1]*33.33,'k:')
plot([-120,120],[1,1]*50,'k-')
plot([-120,120],[1,1]*75,'k-.')
plot([-120,120],[1,1]*25,'k-.')
if ~exist('idxCtl','var')
    legend('High Energy','Low Energy','Location','northwest')
else
%     legend('Left LGN','Right LGN','Control','Location','northwest')
end
ylabel('Contralateral Choices (%)')
xlabel('Time (minutes)')
makeFigureBig(h);