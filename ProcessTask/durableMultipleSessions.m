clear all;

LEFT = 0;
% tData(1) = processTaskDataDurable('D:\Task\Euler\durable\Euler20220221.mat');
% tData(2) = processTaskDataDurable('D:\Task\Euler\durable\Euler20220112.mat');
if LEFT
    tData(1) = processTaskDataDurable('D:\Task\Boltz\durable\Boltzmann20220209.mat');

    newT(1) = selectTrials(tData(1),~isnan(tData(1).ch)&tData(1).correctDelay);
else
    tData(1) = processTaskDataDurable('D:\Task\Boltz\durable\Boltzmann20220114.mat');
    tData(2) = processTaskDataDurable('D:\Task\Boltz\durable\Boltzmann20220117.mat');
    tData(3) = processTaskDataDurable('D:\Task\Boltz\durable\Boltzmann20220119b.mat');
    tData(4) = processTaskDataDurable('D:\Task\Boltz\durable\Boltzmann20220127.mat');
    tData(5) = processTaskDataDurable('D:\Task\Boltz\durable\Boltzmann20220217.mat');
    tData(6) = processTaskDataDurable('D:\Task\Boltz\durable\Boltzmann20220224.mat');
    tData(7) = processTaskDataDurable('D:\Task\Boltz\durable\Boltzmann20220228.mat');
    
    % tData(1) = processTaskDataDurable('D:\Task\Boltz\durable\Boltzmann20220121.mat');
    
%     tData(5) = processTaskDataDurable('D:\Task\Euler\durable\Euler20220207.mat');
%     tData(6) = processTaskDataDurable('D:\Task\Euler\durable\Euler20220204.mat');
%     tData(7) = processTaskDataDurable('D:\Task\Euler\durable\Euler20220130.mat');

    % newT(1) = selectTrials(tData(1),~isnan(tData(1).ch));
    newT(1) = selectTrials(tData(1),~isnan(tData(1).ch)&tData(1).correctDelay);
    newT(2) = selectTrials(tData(2),~isnan(tData(2).ch)&tData(2).correctDelay);
    newT(3) = selectTrials(tData(3),~isnan(tData(3).ch)&tData(3).correctDelay);
    newT(4) = selectTrials(tData(4),~isnan(tData(4).ch)&tData(4).correctDelay);
    newT(5) = selectTrials(tData(5),~isnan(tData(5).ch)&tData(5).correctDelay);
    newT(6) = selectTrials(tData(6),~isnan(tData(6).ch)&tData(6).correctDelay);
    newT(7) = selectTrials(tData(7),~isnan(tData(7).ch)&tData(7).correctDelay);
%     newT(5) = selectTrials(tData(5),~isnan(tData(5).ch)&tData(5).correctDelay);
end
%%
% newT = newT(4);

nBlocks = 2;
blockSize = 3;
blocksBetween = 40;
nBlocksBefore = 3;

[~,p0] = behaviorOverTimeSessionAverage(newT,'Both',(nBlocksBefore+1)*blockSize);
p0 = p0(blocksBetween/(nBlocksBefore+1));

[time,p50,delZ,ch,y] = behaviorOverTimeSessionAverage(newT,'Both',nBlocks*blockSize,p0);

nSonications = floor(length(p50)/(blocksBetween/nBlocks));

%%
delays = unique(tData(1).delay);
h = figure;
ax = gca;
plot(p50);
hold on

h2 = figure;
ax2 = gca;
plot(100*y);
hold on
for ii = 1:1
    figure(h)
    plot(ii*blocksBetween/nBlocks*[1,1],[-100,100],'k--');

    figure(h2)
    plot(ii*blocksBetween/nBlocks*[1,1],[-100,100],'k--');

    usIdx = ii*blocksBetween/nBlocks;
    blocksBefore = (usIdx-nBlocksBefore):usIdx;
    blocksAfter = (usIdx+2):(usIdx+nBlocksBefore+2);
    if blocksAfter(end) > length(p50)
        continue;
    end
    
    figure(h)
    ax.ColorOrderIndex = ii+1;
    plot(blocksBefore,p50(blocksBefore),'*','markersize',10,'linewidth',3)
    plot(blocksAfter,p50(blocksAfter),'*','markersize',10,'linewidth',3)

    figure(h2)
    ax2.ColorOrderIndex = ii+1;
    plot(blocksBefore,100*y(blocksBefore),'*','markersize',10,'linewidth',3)
    plot(blocksAfter,100*y(blocksAfter),'*','markersize',10,'linewidth',3)

    figure(h)
    [~,p] = ttest2(p50(blocksBefore),p50(blocksAfter));
    text(usIdx,min(delays)+0.15*max(delays),['p=',num2str(p,2)])

    figure(h2)
    [~,p] = ttest2(y(blocksBefore),y(blocksAfter));
    text(usIdx,10,['p=',num2str(p,2)])

    sigH = figure;
    trIdxBefore = (ii*blocksBetween*length(delays)*blockSize...
        -(nBlocksBefore+1)*nBlocks*length(delays)*blockSize+1):...
        ii*blocksBetween*length(delays)*blockSize;
    trIdxAfter = (ii*blocksBetween*length(delays)*blockSize+1):...
        (ii*blocksBetween*length(delays)*blockSize...
        +(nBlocksBefore+1)*nBlocks*length(delays)*blockSize);
    plt1 = plotSigmoid(newT,trIdxBefore,sigH);
    hold on
    plt2 = plotSigmoid(newT,trIdxAfter,sigH);
    legend([plt1(1),plt2(1)],'Before','After')
    title(['Sonication ', num2str(ii)])
end
figure(h)
axis([1,length(p50),min(delays),max(delays)])
makeFigureBig(h);

figure(h2)
axis([1,length(y),1,100])
makeFigureBig(h2);