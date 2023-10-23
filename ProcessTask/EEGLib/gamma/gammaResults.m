close all hidden; clear; clc;
%% Process Gamma results: Load data
logFile = 'D:\Gamma\Logs\boltzmann20230619.mat';

log = load(logFile);

eegPth = 'C:\Users\Taylor\Box Sync\MonkeyData\gamma\';
eegBase = 'boltzmann__230619';

[t,eeg,dig] = concatIntan(eegPth, eegBase);

eeg = notchFilter(eeg,20e3,[55,65]);
eeg = notchFilter(eeg,20e3,[118,122]);
eeg = notchFilter(eeg,20e3,[175,185]);
toc

%% Process EEG
[tWindow,eegLeft,eegRight] = processGamma(t,eeg,dig,log);

fs = 20e3;
window = 0.1;
band = [30,70];
gammaLeft = nan(size(eegLeft,1),floor((tWindow(end)-tWindow(1))/0.1));
gammaRight = gammaLeft;
gamma = gammaLeft;
tGamma = (tWindow(1)+window):window:tWindow(end);
baseLineIdx = find(tGamma<0);
for ii = 1:size(eegLeft,1)
    gammaLeft(ii,:) = averageFreqBandTime(eegLeft(ii,:),band,fs,window);
    gammaRight(ii,:) = averageFreqBandTime(eegRight(ii,:),band,fs,window);
    gamma(ii,:) = averageFreqBandTime(mean([eegLeft(ii,:);eegRight(ii,:)],1,'omitnan'),band,fs,window);

    gammaLeft(ii,:) = (gammaLeft(ii,:)-mean(gammaLeft(ii,baseLineIdx),'omitnan'))/mean(gammaLeft(ii,baseLineIdx),'omitnan');
    gammaRight(ii,:) = (gammaRight(ii,:)-mean(gammaRight(ii,baseLineIdx),'omitnan'))/mean(gammaRight(ii,baseLineIdx),'omitnan');
    gamma(ii,:) = (gamma(ii,:)-mean(gamma(ii,baseLineIdx),'omitnan'))/mean(gamma(ii,baseLineIdx),'omitnan');
end
gamma = gammaRight;
% Plot all gamma results
yLims = [0,200];
h = figure;
ax = gca;
g = shadedErrorBar(tGamma,100*mean(gamma,1,'omitnan'),100*semOmitNan(gamma,1),'lineprops',{'Color',ax.ColorOrder(1,:)});
hold on
sonication = polyshape([0,0,0.1,0.1],[yLims(1),yLims(2),yLims(2),yLims(1)]);
sn = plot(sonication);
sn.FaceAlpha = 0.5;
sn.EdgeColor = 'none';
sn.FaceColor = ax.ColorOrder(5,:);
ax.YLim = yLims;
xlabel('Time (s)')
ylabel('Change in Gamma (%)')
legend([g.mainLine,sn],{'Gamma','Sonication'})
makeFigureBig(h);

%% Plot Gamma Results by focus
params = [log.params];
leftIdx = [log.leftIdx];
rightIdx = [log.rightIdx];

cGammaLeft = nan(1,max(leftIdx));
cGammaRight = nan(1,max(rightIdx));

left = nan(size(leftFoci));
right = nan(size(rightFoci));
hLeft = figure;
hRight = figure;
for ii = 1:max(leftIdx)
    [a,b] = ind2sub(size(leftFoci),ii);

    figure(hLeft)
    subplot(size(leftFoci,2),size(leftFoci,1),ii);
    ax = gca;
    g = shadedErrorBar(tGamma,100*mean(gamma(leftIdx==ii,:),1,'omitnan'),100*semOmitNan(gamma(leftIdx==ii,:),1),'lineprops',{'Color',ax.ColorOrder(1,:)});
    hold on
    sonication = polyshape([0,0,0.1,0.1],[yLims(1),yLims(2),yLims(2),yLims(1)]);
    sn = plot(sonication);
    sn.FaceAlpha = 0.5;
    sn.EdgeColor = 'none';
    sn.FaceColor = ax.ColorOrder(5,:);
    ax.YLim = yLims;
    xlabel('Time (s)')
    ylabel('Change in Gamma (%)')
    title(['Focus: ', num2str(leftFoci{a,b})])
    if ii == 1
        legend([g.mainLine,sn],{'Gamma','Sonication'})
    end
    makeFigureBig(h);
    avgWindow = find(tGamma>0.8 & tGamma <3.6);
    curGamma = mean(gamma(leftIdx==ii,:),1,'omitnan');
    left(a,b) = mean(curGamma(avgWindow),'omitnan');

    figure(hRight)
    subplot(size(leftFoci,2),size(leftFoci,1),ii);
    ax = gca;
    g = shadedErrorBar(tGamma,100*mean(gamma(rightIdx==ii,:),1,'omitnan'),100*semOmitNan(gamma(rightIdx==ii,:),1),'lineprops',{'Color',ax.ColorOrder(1,:)});
    hold on
    sonication = polyshape([0,0,0.1,0.1],[yLims(1),yLims(2),yLims(2),yLims(1)]);
    sn = plot(sonication);
    sn.FaceAlpha = 0.5;
    sn.EdgeColor = 'none';
    sn.FaceColor = ax.ColorOrder(5,:);
    ax.YLim = yLims;
    xlabel('Time (s)')
    ylabel('Change in Gamma (%)')
    title(['Focus: ', num2str(rightFoci{a,b})])
    if ii == 1
        legend([g.mainLine,sn],{'Gamma','Sonication'})
    end
    makeFigureBig(h);

    avgWindow = find(tGamma>0.1 & tGamma <0.5);
    curGamma = mean(gamma(leftIdx==ii,:),1,'omitnan');
    left(a,b) = mean(curGamma(avgWindow),'omitnan');

    curGamma = mean(gamma(rightIdx==ii,:),1,'omitnan');
    right(a,b) = mean(curGamma(avgWindow),'omitnan');
end

h = figure;
subplot(121)
imagesc('XData',(-5.5:4:2.5)','YData',(-17:4:-5)','CData',left)
colorbar
xlabel('Anterior/Posterior')
ylabel('Lateral/Medial')
title('Left LGN')
axis('tight')
makeFigureBig(h)
subplot(122)
imagesc('XData',(-5.5:4:2.5)','YData',(5:4:17)','CData',right)
colorbar
axis('tight')
xlabel('Anterior/Posterior')
ylabel('Lateral/Medial')
title('Right LGN')
makeFigureBig(h)

