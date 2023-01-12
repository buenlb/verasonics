close all

block1Before = 25;
block2Before = 39;
block1After = 42;
block2After = 56;

delays = unique(tData(idxLeft(1)).delay);
delays = delays(abs(delays)>20 | delays==0);

chBefore = zeros(length(idxLeft),length(delays));
x0 = zeros(size(idxRight));
chBeforeStd = chBefore;
for ii = 1:length(idxLeft)
    curIdx = find(tData(idxLeft(ii)).Block <= block2Before & tData(idxLeft(ii)).Block >= block1Before & tData(idxLeft(ii)).correctDelay'...
        & ~isnan(tData(idxLeft(ii)).ch'));
    curCh = tData(idxLeft(ii)).ch(curIdx);
    curDelay = tData(idxLeft(ii)).delay(curIdx);
    for kk = 1:length(delays)
        chBefore(ii,kk) = mean(curCh(curDelay==delays(kk)));
        chBeforeStd(ii,kk) = std(curCh(curDelay==delays(kk)))/sqrt(sum(curDelay==delays(kk)));
    end
    [slope, bias, downshift, scale] = fitSigmoid(curDelay,curCh);
    x0(ii) = equalProbabilityPoint(slope,bias,downshift,scale);
end

chAfter= zeros(length(idxLeft),length(delays));
yl = zeros(size(idxLeft));
chAfterStd = chAfter;
for ii = 1:length(idxLeft)
    curIdx = find(tData(idxLeft(ii)).Block <= block2After & tData(idxLeft(ii)).Block >= block1After & tData(idxLeft(ii)).correctDelay'...
        & ~isnan(tData(idxLeft(ii)).ch'));
    curCh = tData(idxLeft(ii)).ch(curIdx);
    curDelay = tData(idxLeft(ii)).delay(curIdx);
    for kk = 1:length(delays)
        chAfter(ii,kk) = mean(curCh(curDelay==delays(kk)));
        chAfterStd(ii,kk) = std(curCh(curDelay==delays(kk)))/sqrt(sum(curDelay==delays(kk)));
    end
    [slope, bias, downshift, scale] = fitSigmoid(curDelay,curCh);
    yl(ii) = sigmoid_ext(x0(ii),slope,bias,downshift,scale);
end
%%
h = figure;
ax = gca;
errorbar(delays,mean(chBefore,1),std(chBefore,[],1)/sqrt(size(chBefore,1)),'*','linewidth',2,'markersize',8);
hold on
errorbar(delays,mean(chAfter,1),std(chAfter,[],1)/sqrt(size(chBefore,1)),'*','linewidth',2,'markersize',8);

[slope, bias, downshift, scale] = fitSigmoid(delays,mean(chBefore,1));
x = linspace(min(delays),max(delays),1e2);
y = sigmoid_ext(x,slope,bias,downshift,scale);
ax.ColorOrderIndex = 1;
plot(x,y,'linewidth',2);

[slope, bias, downshift, scale] = fitSigmoid(delays,mean(chAfter,1));
x = linspace(min(delays),max(delays),1e2);
y = sigmoid_ext(x,slope,bias,downshift,scale);
plot(x,y,'linewidth',2);

legend('before','after','location','northwest')
title('Left LGN')
axis([min(delays),max(delays),0,1])
makeFigureBig(h);

delays = unique(tData(idxRight(1)).delay);
delays = delays(abs(delays)>20 | delays==0);

chBefore = zeros(length(idxRight),length(delays));
x0 = zeros(size(idxRight));
chBeforeStd = chBefore;
for ii = 1:length(idxRight)
    curIdx = find(tData(idxRight(ii)).Block <= block2Before & tData(idxRight(ii)).Block >= block1Before & tData(idxRight(ii)).correctDelay'...
        & ~isnan(tData(idxRight(ii)).ch'));
    curCh = tData(idxRight(ii)).ch(curIdx);
    curDelay = tData(idxRight(ii)).delay(curIdx);
    for kk = 1:length(delays)
        chBefore(ii,kk) = mean(curCh(curDelay==delays(kk)));
        chBeforeStd(ii,kk) = std(curCh(curDelay==delays(kk)))/sqrt(sum(curDelay==delays(kk)));
    end
    [slope, bias, downshift, scale] = fitSigmoid(curDelay,curCh);
    x0(ii) = equalProbabilityPoint(slope,bias,downshift,scale);
end

chAfter= zeros(length(idxRight),length(delays));
yr = zeros(size(idxRight));
chAfterStd = chAfter;
for ii = 1:length(idxRight)
    curIdx = find(tData(idxRight(ii)).Block <= block2After & tData(idxRight(ii)).Block >= block1After & tData(idxRight(ii)).correctDelay'...
        & ~isnan(tData(idxRight(ii)).ch'));
    curCh = tData(idxRight(ii)).ch(curIdx);
    curDelay = tData(idxRight(ii)).delay(curIdx);
    for kk = 1:length(delays)
        chAfter(ii,kk) = mean(curCh(curDelay==delays(kk)));
        chAfterStd(ii,kk) = std(curCh(curDelay==delays(kk)))/sqrt(sum(curDelay==delays(kk)));
    end
    [slope, bias, downshift, scale] = fitSigmoid(curDelay,curCh);
    yr(ii) = sigmoid_ext(x0(ii),slope,bias,downshift,scale);
end

h = figure;
ax = gca;
errorbar(delays,mean(chBefore,1),std(chBefore,[],1)/sqrt(size(chBefore,1)),'*','linewidth',2,'markersize',8);
hold on
errorbar(delays,mean(chAfter,1),std(chAfter,[],1)/sqrt(size(chBefore,1)),'*','linewidth',2,'markersize',8);

[slope, bias, downshift, scale] = fitSigmoid(delays,mean(chBefore,1));
x = linspace(min(delays),max(delays),1e2);
y = sigmoid_ext(x,slope,bias,downshift,scale);
ax.ColorOrderIndex = 1;
plot(x,y,'linewidth',2);

[slope, bias, downshift, scale] = fitSigmoid(delays,mean(chAfter,1));
x = linspace(min(delays),max(delays),1e2);
y = sigmoid_ext(x,slope,bias,downshift,scale);
plot(x,y,'linewidth',2);

legend('before','after','location','northwest')
title('Right LGN')
axis([min(delays),max(delays),0,1])
makeFigureBig(h);