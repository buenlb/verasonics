function [ph,yh,sh,trIdxBefore,trIdxAfter] = plotDurableResults(tData,p,y,usIdx,nBlocksPerPoint,nPoints,ph,yh,sh)
if ~exist('nPoints','var')
    nPoints = 4;
end
if ~exist('ph','var')
    ph = figure;
elseif isempty(ph)
    ph = figure;
end
if ~exist('sh','var')
    sh = figure;
elseif isempty(ph)
    sh = figure;
end
if ~exist('yh','var')
    yh = figure;
elseif isempty(ph)
    yh = figure;
end

delays = unique(tData(1).delay);
trialsPerBlock= zeros(size(tData));
for ii = 1:length(tData)
    delays = unique([unique(tData(ii).delay); delays]);
    trialsPerBlock(ii) = tData(ii).trialsPerBucket;
end

if length(delays) > 5
    warning('Extra delays. Throwing out any extra delays from before US')
    delays = unique(tData(1).delay(150:end));
    if length(delays)>5
        error('Still too many delays')
    end
end

trialsPerBlock = unique(trialsPerBlock);
if length(trialsPerBlock) > 1
    error('Different runs have a different number of trials per block. I don''t know how to combine them.')
end

figure(ph);
ax = gca;
plot(p);
hold on

figure(yh)
ax2 = gca;
plot(100*y);
hold on
figure(ph)
plot(usIdx*[1,1],[-100,100],'k--');

figure(yh)
plot(usIdx*[1,1],[-100,100],'k--');

blocksBefore = (usIdx-nPoints-1):usIdx-1;
blocksAfter = (usIdx+2):(usIdx+nPoints+2);

figure(ph)
ax.ColorOrderIndex = 2;
% plot(blocksBefore,p(blocksBefore),'*','markersize',10,'linewidth',3)
% plot(blocksAfter,p(blocksAfter),'*','markersize',10,'linewidth',3)

figure(yh)
ax2.ColorOrderIndex = 2;
% plot(blocksBefore,100*y(blocksBefore),'*','markersize',10,'linewidth',3)
% plot(blocksAfter,100*y(blocksAfter),'*','markersize',10,'linewidth',3)

figure(ph)
[~,p] = ttest2(p(blocksBefore),p(blocksAfter));
text(usIdx,min(delays)+0.15*max(delays),['p=',num2str(p,2)])

figure(yh)
[~,p] = ttest2(y(blocksBefore),y(blocksAfter));
text(usIdx,10,['p=',num2str(p,2)])


trIdxBefore = (usIdx*length(delays)*nBlocksPerPoint*trialsPerBlock...
    -nBlocksPerPoint*length(delays)*trialsPerBlock*(nPoints+1.5)+1):...
    (usIdx-0.5)*length(delays)*nBlocksPerPoint*trialsPerBlock;
trIdxAfter = (usIdx+1.5)*length(delays)*nBlocksPerPoint*trialsPerBlock+1:...
    ((usIdx+1.5)*length(delays)*nBlocksPerPoint*trialsPerBlock+...
    nBlocksPerPoint*length(delays)*trialsPerBlock*(nPoints+1));

plt1 = plotSigmoid(tData,trIdxBefore,sh);
hold on
plt2 = plotSigmoid(tData,trIdxAfter,sh);
legend([plt1(1),plt2(1)],'Before','After')
title('Behavior Before/After Sonication')

figure(ph)
axis([1,40,min(delays),max(delays)])
makeFigureBig(ph);

figure(yh)
axis([1,40,1,100])
makeFigureBig(yh);