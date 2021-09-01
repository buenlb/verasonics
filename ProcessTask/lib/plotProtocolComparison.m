function h = plotProtocolComparison(tData,labels)
if length(tData)~=length(labels)
    error('Length of tData and labels must be the same!')
end

maxDelay = 5;

barH = zeros(1,length(tData)*2);
barStd = barH;
rightCh = cell(1,length(tData));
leftCh = cell(1,length(tData));
nTrialsAnova = zeros(size(tData));
for ii = 1:length(tData)
    rightCh{ii} = (tData(ii).ch(~isnan(tData(ii).ch) & tData(ii).lgn==1 & abs(tData(ii).delay) < maxDelay))';
    leftCh{ii} = (tData(ii).ch(~isnan(tData(ii).ch) & tData(ii).lgn==-1 & abs(tData(ii).delay) < maxDelay))';
    leftDelay{ii} = (tData(ii).delay(~isnan(tData(ii).ch) & tData(ii).lgn==-1 & abs(tData(ii).delay) < maxDelay))';
    rightDelay{ii} = (tData(ii).delay(~isnan(tData(ii).ch) & tData(ii).lgn==1 & abs(tData(ii).delay) < maxDelay))';
    
    barH((ii-1)*2+1) = mean(leftCh{ii});
    barH(ii*2) = mean(rightCh{ii});
    
    barStd((ii-1)*2+1) = std(leftCh{ii})/sqrt(length(leftCh{ii}));
    barStd(ii*2) = std(rightCh{ii})/sqrt(length(rightCh{ii}));
    
    nTrialsAnova(ii) = min([length(rightCh{ii}),length(leftCh{ii})]);
end
nTrialsAnova = min(nTrialsAnova);

h = figure;
ax1 = axes();
ax1.Position = [0.1300 0.2100 0.7750 0.7000];
hold on
ax2 = axes();
ax2.Position = [0.1300 0.000 0.7750 0.1000];
ax2.Visible = 'off';
axes(ax1);
curIdx = 1;
% intervals = cell(1,prod(1:length(tData)+1));
% p = zeros(1,prod(1:length(tData)+1));
xLabels = [];
xTick = [];

h2 = figure;
ax3 = axes();
ax3.Position = [0.1300 0.2100 0.7750 0.7000];
hold on
ax4 = axes();
ax4.Position = [0.1300 0.000 0.7750 0.1000];
ax4.Visible = 'off';
axes(ax3);
curIdx = 1;
% intervals = cell(1,prod(1:length(tData)+1));
% p = zeros(1,prod(1:length(tData)+1));
xLabels = [];
xTick = [];

for ii = 1:length(tData)
    for jj = 1:length(tData)
        if ii==jj
            intervals{curIdx} = [(ii-1)*3+1,(ii-1)*3+2];
            curInt = intervals{curIdx};
            
            p(curIdx) = rndttest(rightCh{ii},leftCh{ii});
            curIdx = curIdx+1;
        elseif jj < ii
            intervals{curIdx} = [(jj-1)*3+1,(ii-1)*3+1];
            p(curIdx) = rndttest(leftCh{jj},leftCh{ii});
            curIdx = curIdx+1;
            
            intervals{curIdx} = [(jj-1)*3+1,(ii-1)*3+2];
            p(curIdx) = rndttest(leftCh{jj},rightCh{ii});
            curIdx = curIdx+1;
            
            intervals{curIdx} = [(jj-1)*3+2,(ii-1)*3+1];
            p(curIdx) = rndttest(rightCh{jj},leftCh{ii});
            curIdx = curIdx+1;
            
            intervals{curIdx} = [(jj-1)*3+2,(ii-1)*3+2];
            p(curIdx) = rndttest(rightCh{jj},rightCh{ii});
            curIdx = curIdx+1;
        end
    end
    figure(h)
    bar(curInt(1),100*barH((ii-1)*2+1),'FaceColor',ax1.ColorOrder(1,:));
    bar(curInt(2),100*barH(2*ii),'FaceColor',ax1.ColorOrder(2,:));
    
    erBar = errorbar(curInt,100*barH((ii-1)*2+1:2*ii),100*barStd((ii-1)*2+1:2*ii));
    erBar.Color = [0,0,0];
    erBar.LineStyle = 'none';
    xTick = cat(2,xTick,curInt);
    xLabels = cat(2,xLabels,{'Left','Right'});
    
    figure(h2)
    bar(curInt(1),100*barH((ii-1)*2+1)-50,'FaceColor',ax1.ColorOrder(1,:));
    bar(curInt(2),100*barH(2*ii)-50,'FaceColor',ax1.ColorOrder(2,:));
    
    erBar = errorbar(curInt,100*barH((ii-1)*2+1:2*ii)-50,100*barStd((ii-1)*2+1:2*ii));
    erBar.Color = [0,0,0];
    erBar.LineStyle = 'none';
end
figure(h)
ax1.XTick = xTick;
ax1.XTickLabel = xLabels;

intervals = intervals(p<0.05);
p = p(p<0.05);
sigstar(intervals,p)
makeFigureBig(h);

axes(ax2)
axis([ax1.XLim,0,1])
for ii = 1:length(tData)
    text((ii-1)*3+1.5,0.75,labels{ii},'HorizontalAlignment','center')
end
makeFigureBig(h)

axes(ax1)

figure(h2)
ax3.XTick = xTick;
ax3.XTickLabel = xLabels;
sigstar(intervals,p)
makeFigureBig(h2);

axes(ax2)
axis([ax1.XLim,0,1])
for ii = 1:length(tData)
    text((ii-1)*3+1.5,0.75,labels{ii},'HorizontalAlignment','center')
end
makeFigureBig(h)

axes(ax3)

for ii = 1:length(tData)
    totData((ii-1)*nTrialsAnova+1:ii*nTrialsAnova,1) = leftCh{ii}(1:nTrialsAnova);
    totData((ii-1)*nTrialsAnova+1:ii*nTrialsAnova,2) = rightCh{ii}(1:nTrialsAnova);
end
anova2(totData,nTrialsAnova);