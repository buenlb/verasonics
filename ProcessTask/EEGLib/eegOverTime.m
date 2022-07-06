function [delta,theta,alpha,beta,gamma] = eegOverTime(t,eeg,tData,taskIdx,trId)
if length(t)~=length(eeg)
    error('tData, t and eeg must be the same length')
elseif length(t)~=length(tData)
    error('tData, t, and eeg must be the same length')
end

smoothingWindow = 5*60;
smallWindowLength = 0.5;

deltaInd = cell(size(tData));
thetaInd = cell(size(tData));
alphaInd = cell(size(tData));
betaInd = cell(size(tData));
gammaInd = cell(size(tData));
windowTimeInd = cell(size(tData));

preMaxDim = 0;
postMaxDim = 0;
for ii = 1:length(t)
    disp(['Processing session ', num2str(ii), ' of ', num2str(length(t))])
    if isempty(t{ii})
        continue
    end
    % Recenter data so that US occurs at time t=0
    usIdx = find(tData(ii).Block==tData(ii).usBlock);
    usIdx = usIdx(1);
    usIdx = find(usIdx==trId{ii});
    if isempty(usIdx)
        warning(['Couldn''t find the ultrasound trial so I am throwing this session (',...
            num2str(ii), ' out of the sessions given to me) out'])
        continue
    end
    try
    t{ii} = t{ii}-t{ii}(taskIdx{ii}(usIdx));
    catch
        keyboard
    end

    [deltaInd{ii},thetaInd{ii},alphaInd{ii},betaInd{ii},gammaInd{ii},windowTimeInd{ii}] = ...
        eegSpectra(t{ii},eeg{ii},smallWindowLength);

%     % Exclude time when the US is on
%     usOnIdx = find(windowTimeInd{ii}>-60 & windowTimeInd{ii}<95);
%     deltaInd{ii}(:,usOnIdx) = nan;
%     thetaInd{ii}(:,usOnIdx) = nan;
%     alphaInd{ii}(:,usOnIdx) = nan;
%     betaInd{ii}(:,usOnIdx) = nan;
%     gammaInd{ii}(:,usOnIdx) = nan;
% 
%     % Use the window size prescribed above to average the results
    for jj = 1:length(deltaInd{ii})
        curT = windowTimeInd{ii};
        curCenter = curT(jj);
        curIdx = find(curT>(curCenter-smoothingWindow/2) & curT<(curCenter+smoothingWindow/2));
        deltaInd{ii}(1,jj) = mean(deltaInd{ii}(1,curIdx),'omitnan');
        deltaInd{ii}(2,jj) = mean(deltaInd{ii}(2,curIdx),'omitnan');

        thetaInd{ii}(1,jj) = mean(thetaInd{ii}(1,curIdx),'omitnan');
        thetaInd{ii}(2,jj) = mean(thetaInd{ii}(2,curIdx),'omitnan');

        alphaInd{ii}(1,jj) = mean(alphaInd{ii}(1,curIdx),'omitnan');
        alphaInd{ii}(2,jj) = mean(alphaInd{ii}(2,curIdx),'omitnan');

        betaInd{ii}(1,jj) = mean(betaInd{ii}(1,curIdx),'omitnan');
        betaInd{ii}(2,jj) = mean(betaInd{ii}(2,curIdx),'omitnan');

        gammaInd{ii}(1,jj) = mean(gammaInd{ii}(1,curIdx),'omitnan');
        gammaInd{ii}(2,jj) = mean(gammaInd{ii}(2,curIdx),'omitnan');
    end
%     smoothingIndex = ceil(smoothingWindow/smallWindowLength);
%     deltaInd{ii}(1,:) = smooth(deltaInd{ii}(1,:),smoothingIndex);
%     deltaInd{ii}(2,:) = smooth(deltaInd{ii}(2,:),smoothingIndex);
%     
%     thetaInd{ii}(1,:) = smooth(thetaInd{ii}(1,:),smoothingIndex);
%     thetaInd{ii}(2,:) = smooth(thetaInd{ii}(2,:),smoothingIndex);
%     
%     alphaInd{ii}(1,:) = smooth(alphaInd{ii}(1,:),smoothingIndex);
%     alphaInd{ii}(2,:) = smooth(alphaInd{ii}(2,:),smoothingIndex);
%     
%     betaInd{ii}(1,:) = smooth(betaInd{ii}(1,:),smoothingIndex);
%     betaInd{ii}(2,:) = smooth(betaInd{ii}(2,:),smoothingIndex);
%     
%     gammaInd{ii}(1,:) = smooth(gammaInd{ii}(1,:),smoothingIndex);
%     gammaInd{ii}(2,:) = smooth(gammaInd{ii}(2,:),smoothingIndex);
    

    if preMaxDim < sum(windowTimeInd{ii}<0)
        preMaxDim = sum(windowTimeInd{ii}<0);
        preMaxIdx = ii;
    end
    if postMaxDim < sum(windowTimeInd{ii}>0)
        postMaxDim = sum(windowTimeInd{ii}>0);
        postMaxIdx = ii;
    end
end

%%
delta = nan(length(t),2,preMaxDim+postMaxDim);
theta = nan(length(t),2,preMaxDim+postMaxDim);
alpha = nan(length(t),2,preMaxDim+postMaxDim);
beta = nan(length(t),2,preMaxDim+postMaxDim);
gamma = nan(length(t),2,preMaxDim+postMaxDim);

tWindow = [windowTimeInd{preMaxIdx}(windowTimeInd{preMaxIdx}<=0),...
    windowTimeInd{postMaxIdx}(windowTimeInd{postMaxIdx}>0)];

nSessions = 0;
for ii = 1:length(t)
    if isempty(deltaInd{ii})
        continue
    end
    nSessions = nSessions+1;
    curPre = sum(windowTimeInd{ii}<0);
%     curPost = sum(windowTimeInd{ii}(windowTimeInd{ii}>0));
    delta(ii,:,(preMaxDim-curPre+1):((preMaxDim-curPre+1)+length(deltaInd{ii})-1)) = deltaInd{ii};
    theta(ii,:,(preMaxDim-curPre+1):((preMaxDim-curPre+1)+length(thetaInd{ii})-1)) = thetaInd{ii};
    alpha(ii,:,(preMaxDim-curPre+1):((preMaxDim-curPre+1)+length(alphaInd{ii})-1)) = alphaInd{ii};
    beta(ii,:,(preMaxDim-curPre+1):((preMaxDim-curPre+1)+length(betaInd{ii})-1)) = betaInd{ii};
    gamma(ii,:,(preMaxDim-curPre+1):((preMaxDim-curPre+1)+length(gammaInd{ii})-1)) = gammaInd{ii};
end

deltaStd(1,:) = std(delta(:,1,:),[],1,'omitnan')/sqrt(nSessions);
deltaStd(2,:) = std(delta(:,2,:),[],1,'omitnan')/sqrt(nSessions);
thetaStd(1,:) = std(theta(:,1,:),[],1,'omitnan')/sqrt(nSessions);
thetaStd(2,:) = std(theta(:,2,:),[],1,'omitnan')/sqrt(nSessions);
alphaStd(1,:) = std(alpha(:,1,:),[],1,'omitnan')/sqrt(nSessions);
alphaStd(2,:) = std(alpha(:,2,:),[],1,'omitnan')/sqrt(nSessions);
betaStd(1,:) = std(beta(:,1,:),[],1,'omitnan')/sqrt(nSessions);
betaStd(2,:) = std(beta(:,2,:),[],1,'omitnan')/sqrt(nSessions);
gammaStd(1,:) = std(gamma(:,1,:),[],1,'omitnan')/sqrt(nSessions);
gammaStd(2,:) = std(gamma(:,2,:),[],1,'omitnan')/sqrt(nSessions);

deltaMean(1,:) = mean(delta(:,1,:),1,'omitnan');
deltaMean(2,:) = mean(delta(:,2,:),1,'omitnan');
thetaMean(1,:) = mean(theta(:,1,:),1,'omitnan');
thetaMean(2,:) = mean(theta(:,2,:),1,'omitnan');
alphaMean(1,:) = mean(alpha(:,1,:),1,'omitnan');
alphaMean(2,:) = mean(alpha(:,2,:),1,'omitnan');
betaMean(1,:) = mean(beta(:,1,:),1,'omitnan');
betaMean(2,:) = mean(beta(:,2,:),1,'omitnan');
gammaMean(1,:) = mean(gamma(:,1,:),1,'omitnan');
gammaMean(2,:) = mean(gamma(:,2,:),1,'omitnan');

h = figure;
ax = gca;
shadedErrorBar(tWindow/60,deltaMean(1,:),deltaStd(1,:),'lineprops',{'Color',ax.ColorOrder(1,:),'linewidth',2})
hold on
shadedErrorBar(tWindow/60,deltaMean(2,:),deltaStd(2,:),'lineprops',{'Color',ax.ColorOrder(2,:),'linewidth',2})
xlabel('Time (minutes)')
title('Delta')
ax.XLim = [-10,15];
makeFigureBig(h)

h = figure;
ax = gca;
shadedErrorBar(tWindow/60,thetaMean(1,:),thetaStd(1,:),'lineprops',{'Color',ax.ColorOrder(1,:),'linewidth',2})
hold on
shadedErrorBar(tWindow/60,thetaMean(2,:),thetaStd(2,:),'lineprops',{'Color',ax.ColorOrder(2,:),'linewidth',2})
xlabel('Time (minutes)')
title('Theta')
ax.XLim = [-10,15];
makeFigureBig(h)

h = figure;
ax = gca;
shadedErrorBar(tWindow/60,alphaMean(1,:),alphaStd(1,:),'lineprops',{'Color',ax.ColorOrder(1,:),'linewidth',2})
hold on
shadedErrorBar(tWindow/60,alphaMean(2,:),alphaStd(2,:),'lineprops',{'Color',ax.ColorOrder(2,:),'linewidth',2})
xlabel('Time (minutes)')
title('Alpha')
ax.XLim = [-10,15];
makeFigureBig(h)

h = figure;
ax = gca;
shadedErrorBar(tWindow/60,betaMean(1,:),betaStd(1,:),'lineprops',{'Color',ax.ColorOrder(1,:),'linewidth',2})
hold on
shadedErrorBar(tWindow/60,betaMean(2,:),betaStd(2,:),'lineprops',{'Color',ax.ColorOrder(2,:),'linewidth',2})
xlabel('Time (minutes)')
title('Beta')
ax.XLim = [-10,15];
makeFigureBig(h)

h = figure;
ax = gca;
shadedErrorBar(tWindow/60,gammaMean(1,:),gammaStd(1,:),'lineprops',{'Color',ax.ColorOrder(1,:),'linewidth',2})
hold on
shadedErrorBar(tWindow/60,gammaMean(2,:),gammaStd(2,:),'lineprops',{'Color',ax.ColorOrder(2,:),'linewidth',2})
xlabel('Time (minutes)')
title('Gamma')
ax.XLim = [-10,15];
makeFigureBig(h)
keyboard