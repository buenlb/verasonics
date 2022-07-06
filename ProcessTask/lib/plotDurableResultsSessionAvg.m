function plotDurableResultsSessionAvg(tData,p,y,usIdx,nBlocksPerPoint,nPoints)

yM = mean(y,1);
yStd = std(y,[],1);

pM = mean(p,2);
pStd = std(p,[],1);

blocksBefore = (usIdx-nPoints-1):usIdx-1;
blocksAfter = (usIdx+1):(usIdx+nPoints+1);

h = figure;
yBefore = mean(y(blocksBefore),1);
yAfter = mean(y(blocksAfter),1);
bar(1:2,[mean(yBefore),mean(yAfter)])
hold on
eb = errorbar(1:2,[mean(yBefore),mean(yAfter)],[std(yBefore),std(yAfter)]);
set(eb,'linestyle','none','Color',[0,0,0]);
xticks(1:2);
xticklabels({'Befire','After'})
xtickangle(90)
