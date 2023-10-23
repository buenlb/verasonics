clear; clc;
%% Process Gamma results: Load data
logFile = 'D:\Gamma\Logs\boltzmann20230619.mat';

log = load(logFile);

eegPth = 'C:\Users\Taylor\Box Sync\MonkeyData\gamma\';
eegBase = 'boltzmann__230619';

[t,eeg,dig] = concatIntan(eegPth, eegBase);

eeg = notchFilter(eeg,20e3,[58,62]);
eeg = notchFilter(eeg,20e3,[118,122]);
eeg = notchFilter(eeg,20e3,[175,185]);
toc

%% Process EEG
[tWindow,eegLeft,eegRight,tableEntries] = processGamma_jn19(t,eeg,dig,log);

%% timeSpectrum
% close all
totEeg = (eegLeft+eegRight)/2;
desiredTimes = -0.5:0.25:7;
desiredFreq = [0.5,180];
window = 0.5;
% ts = nan(length(desiredFreq),length(desiredTimes),size(eegLeft,1));
clear ts tsRaw;
for ii = 1:size(totEeg,1)
    [ts(:,:,ii),fftX] = timeSpectrum(totEeg(ii,:),tWindow,window,desiredTimes,desiredFreq);
end

% Normalize the result to baseline
% One has to be careful with how we average to baseline here. Averaging to
% the baseline for every session biases the whole result towards an
% increase in the magnitude of each fourier coefficient. This is because if
% the baseline is small relative to the current window then you get:
% 
% (bigN-smallN)/smallN
% 
% Resulting in a large positive percentage. If, however, the baseline is
% large - indicating that the Fourier coefficient decreased, you end up
% with a smaller negative percentage:
% 
% (smallN-bigN)/bigN
% 
% Thus, we do the subtraction for each session but for the division we use
% an average across all sessions so that the change in the coefficient is
% weighted equally across sessions.
baselineSubtractor = ts(:,desiredTimes<=0,:);
baselineSubtractor = mean(baselineSubtractor,2);
baselineSubtractor = repmat(baselineSubtractor,[1,size(ts,2),1]);
baselineDivider = ts(:,desiredTimes==0,:);
baselineDivider = mean(baselineDivider,3);
baselineDivider = repmat(baselineDivider,[1,size(ts,2),size(ts,3)]);
ts = 100*(ts-baselineSubtractor)./baselineDivider;
tsAvg = mean(ts,3);

% figure
% imagesc(desiredTimes,fftX,tsAvg);
% caxis([-20,20]*2);
% colorbar;
return
%%
fs = 20e3;
window = 0.1;
band = [15,30];
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

% Parameters for spatial scan
% Sonication parameters
% Targeting
focalLocationLeft = [-9, -1.5, 57.5];
focalLocationRight = [9, -1.5, 58];
nFoci = [4,3,1];
focalDev = [4,4,0];

leftFoci = generateTargetBuckets(focalLocationLeft-[2,0,0],nFoci,focalDev);
rightFoci = generateTargetBuckets(focalLocationRight+[2,0,0],nFoci,focalDev);

vsxTime = 2.7;

% Plot Gamma Results by focus
params = [log.log.params];
leftIdx = [log.log.leftIdx];
rightIdx = [log.log.rightIdx];

cGammaLeft = nan(1,max(leftIdx));
cGammaRight = nan(1,max(rightIdx));

% foci = reshape([log.paramTable.focus],[3,24])';
% leftFoci = foci(foci(:,1)<0,:,:);
% rightFoci = foci(foci(:,1)>0,:,:);
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

    avgWindow = find(tGamma>0.1 & tGamma <0.4);
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

