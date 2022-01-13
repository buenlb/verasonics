nBlocks = 2;
blockSize = 3;
blocksBetween = 40;
nBlocksBefore = 3;

[~,p0] = behaviorOverTimeKnownBlocks(newT,'Both',(nBlocksBefore+1)*blockSize);
p0 = p0{1}(blocksBetween/(nBlocksBefore+1));
%%
[time,p50,delZ,y] = behaviorOverTimeKnownBlocks(newT,'Both',nBlocks*blockSize,p0);

usBlocks = blocksBetween/nBlocks;

idxBefore = (usBlocks-nBlocksBefore):usBlocks;
idxAfter = (1+usBlocks):(1+usBlocks+nBlocksBefore);

blocksBefore = p50{1}(idxBefore);
blocksAfter = p50{1}(idxAfter);

h = figure;
ax = gca;
hold on
plot(time{1}/60,p50{1});
plot([time{1}(usBlocks),time{1}(usBlocks)]/60,[-20,20],'k--')
plot([time{1}(usBlocks*2),time{1}(usBlocks*2)]/60,[-20,20],'k--')
plot([time{1}(usBlocks*3),time{1}(usBlocks*3)]/60,[-20,20],'k--')

ax.ColorOrderIndex = 2;
plot(time{1}(idxBefore)/60,p50{1}(idxBefore),'*','linewidth',2,'MarkerSize',8)
plot(time{1}(idxAfter)/60,p50{1}(idxAfter),'*','linewidth',2,'MarkerSize',8)
[~,p] = ttest2(blocksBefore,blocksAfter);
text(time{1}(usBlocks)/60,10,['p=',num2str(p,2)]);

idxBefore = (2*usBlocks-nBlocksBefore):2*usBlocks;
idxAfter = (1+2*usBlocks):(1+2*usBlocks+nBlocksBefore);
blocksBefore = p50{1}(idxBefore);
blocksAfter = p50{1}(idxAfter);
ax.ColorOrderIndex = 4;
plot(time{1}(idxBefore)/60,p50{1}(idxBefore),'*','linewidth',2,'MarkerSize',8)
plot(time{1}(idxAfter)/60,p50{1}(idxAfter),'*','linewidth',2,'MarkerSize',8)
[~,p] = ttest2(blocksBefore,blocksAfter);
text(time{1}(2*usBlocks)/60,10,['p=',num2str(p,2)]);

xlabel('time (minutes)')
ylabel('Point of equal Probability (ms)')
title('Point of Equal Probability')
% axis([0,50,-30,20])
makeFigureBig(h)

%%
delays = unique(newT.delay);
idxSonication1Before = (blocksBetween*length(delays)*blockSize...
    -(nBlocksBefore+1)*nBlocks*length(delays)*blockSize+1):...
    blocksBetween*length(delays)*blockSize;
idxSonication1After= (blocksBetween*length(delays)*blockSize+1):...
    (blocksBetween*length(delays)*blockSize+(nBlocksBefore+1)*nBlocks*length(delays)*blockSize);
h = figure;
p(1:2)=plotSigmoid(newT,idxSonication1Before,h);
hold on
p(3:4)=plotSigmoid(newT,idxSonication1After,h);
title('Sonication 1')
legend([p(1),p(3)],'Before','After','location','southeast')

delays = unique(newT.delay);
idxSonication1Before = (2*blocksBetween*length(delays)*blockSize...
    -(nBlocksBefore+1)*nBlocks*length(delays)*blockSize+1):...
    2*blocksBetween*length(delays)*blockSize;
idxSonication1After= (2*blocksBetween*length(delays)*blockSize+1):...
    (2*blocksBetween*length(delays)*blockSize+(nBlocksBefore+1)*nBlocks*length(delays)*blockSize);
h = figure;
p(1:2)=plotSigmoid(newT,idxSonication1Before,h);
hold on
p(3:4)=plotSigmoid(newT,idxSonication1After,h);
title('Sonication 2')
legend([p(1),p(3)],'Before','After','location','southeast')

%%
y{1} = y{1}*100;
h = figure;
ax = gca;
hold on
plot(time{1}/60,y{1});
plot([time{1}(usBlocks),time{1}(usBlocks)]/60,[-20,100],'k--')
plot([time{1}(usBlocks*2),time{1}(usBlocks*2)]/60,[-20,100],'k--')
plot([time{1}(usBlocks*3),time{1}(usBlocks*3)]/60,[-20,100],'k--')

idxBefore = (usBlocks-nBlocksBefore):usBlocks;
idxAfter = (1+usBlocks):(1+usBlocks+nBlocksBefore);
blocksBefore = y{1}(idxBefore);
blocksAfter = y{1}(idxAfter);
ax.ColorOrderIndex = 2;
plot(time{1}(idxBefore)/60,y{1}(idxBefore),'*','linewidth',2,'MarkerSize',8)
plot(time{1}(idxAfter)/60,y{1}(idxAfter),'*','linewidth',2,'MarkerSize',8)
[~,p] = ttest2(blocksBefore,blocksAfter);
text(time{1}(usBlocks)/60,10,['p=',num2str(p,2)]);

idxBefore = (2*usBlocks-nBlocksBefore):2*usBlocks;
idxAfter = (1+2*usBlocks):(1+2*usBlocks+nBlocksBefore);
blocksBefore = y{1}(idxBefore);
blocksAfter = y{1}(idxAfter);
ax.ColorOrderIndex = 4;
plot(time{1}(idxBefore)/60,y{1}(idxBefore),'*','linewidth',2,'MarkerSize',8)
plot(time{1}(idxAfter)/60,y{1}(idxAfter),'*','linewidth',2,'MarkerSize',8)
[~,p] = ttest2(blocksBefore,blocksAfter);
text(time{1}(2*usBlocks)/60,10,['p=',num2str(p,2)]);

xlabel('time (minutes)')
ylabel('Percent Leftward Choices at P0')
axis([0,50,0,100])
makeFigureBig(h)