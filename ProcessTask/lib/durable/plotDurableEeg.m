eegOut = struct('features',[],'tFeatures',[],'frequencies',[],'windowDur',...
    [],'notches',[]);

for ii = 1:length(tData)
    if ii > 1
        toc(tLast)
    end
    disp(['  ******Processing EEG data in session ', num2str(ii), ' of ', num2str(length(processedFiles))])
    tLast = tic;
    for jj = 1:length(processedFiles{ii})
        if ~isnan(str2double(processedFiles{ii}(jj))) && isreal(str2double(processedFiles{ii}(jj)))
            date(ii).year = (processedFiles{ii}(jj:(jj+3)));
            date(ii).month = (processedFiles{ii}((jj+4):(jj+5)));
            date(ii).day = (processedFiles{ii}((jj+6):(jj+7)));
            break;
        end
    end
    switch monk(ii)
        case 'b'
            pth = 'D:\Task\Boltz\eeg\';
            baseName1 = 'boltzmannTask_';
        case 'e'
            pth = 'D:\Task\Euler\eeg\';
            baseName1 = 'Euler_';
    end
    baseName = [baseName1,date(ii).year(3:4),date(ii).month,date(ii).day];
    try
        out = eegAnalysisDurable(pth,baseName,tData(ii));
        eegOut(ii) = rmfield(out,'eegIn');
    catch me
        disp(['***FAILED: ', me.message]);
    end
end

%% Align to US and bin into larger windows
sWindow = 300;
tSmoothed = -10*60:30:20*60;
maxDim = 0;
features = nan(length(eegOut),length(tSmoothed),size(eegOut(1).features,1));

trgT = nan(length(eegOut),length(tSmoothed));
for ii = 1:length(eegOut)
    disp(['Struct ', num2str(ii), ' of ', num2str(length(eegOut))])
    if isempty(eegOut(ii).features)
        continue
    end
    if size(eegOut(ii).features,2)>maxDim
        maxDim = size(eegOut(ii).features,2);
        mxI = ii;
    end
    for jj = 1:length(tSmoothed)
        curIdx = find(eegOut(ii).tFeatures>=tSmoothed(jj) & eegOut(ii).tFeatures<tSmoothed(jj)-sWindow);
        features(ii,jj,:) = mean(eegOut(ii).features(:,curIdx),2,'omitnan');
    end
end

%%
f = eegOut(1).frequencies;
deltaIdx = find(f>0 & f<=3);
thetaIdx = find(f>3 & f<=7);
alphaIdx = find(f>7 & f<=12);
betaIdx = find(f>12 & f<=30);
gammaIdx = find(f>30 & f<=70);
hGammaIdx = find(f>70 & f<=320);

alpha = mean(features(:,:,alphaIdx),3,'omitnan');
beta = mean(features(:,:,betaIdx),3,'omitnan');
gamma = mean(features(:,:,gammaIdx),3,'omitnan');
hGamma = mean(features(:,:,hGammaIdx),3,'omitnan');

x = (tSmoothed(1:end))/60+5;
ZSCORE = 0;
if ZSCORE
    [alphaZ,alphaZSem] = zscore_omitnan(alpha(idx1,:),1);
    [betaZ,betaZSem] = zscore_omitnan(beta(idx1,:),1);
    [gammaZ,gammaZSem] = zscore_omitnan(gamma(idx1,:),1);
    [hGammaZ,hGammaZSem] = zscore_omitnan(hGamma(idx1,:),1);
    
    [alphaZC,alphaZSemC] = zscore_omitnan(alpha(idxCtl,:),1);
    [betaZC,betaZSemC] = zscore_omitnan(beta(idxCtl,:),1);
    [gammaZC,gammaZSemC] = zscore_omitnan(gamma(idxCtl,:),1);
    [hGammaZC,hGammaZSemC] = zscore_omitnan(hGamma(idxCtl,:),1);
else
    alphaZ = nan(size(alpha));
    betaZ = nan(size(beta));
    gammaZ = nan(size(gamma));
    hGammaZ = nan(size(hGamma));
    for ii = 1:size(gamma,1)
        alphaZ(ii,:) = alpha(ii,:)/mean(alpha(ii,x<0 & x>-5),'omitnan');
        betaZ(ii,:) = beta(ii,:)/mean(beta(ii,x<0 & x>-5),'omitnan');
        gammaZ(ii,:) = gamma(ii,:)/mean(gamma(ii,x<0 & x>-5),'omitnan');
        hGammaZ(ii,:) = hGamma(ii,:)/mean(hGamma(ii,x<0 & x>-5),'omitnan');
    end
    gammaN = gammaZ;
    alphaN = alphaZ;
    betaN = betaZ;
    hGammaN = hGammaZ;

%     [alphaZ,alphaZSem] = zscore_omitnan(alphaZ(idx1,:),1);
%     [betaZ,betaZSem] = zscore_omitnan(betaZ(idx1,:),1);
%     [gammaZ,gammaZSem] = zscore_omitnan(gammaZ(idx1,:),1);
%     [hGammaZ,hGammaZSem] = zscore_omitnan(hGammaZ(idx1,:),1);

    alphaZSem = semOmitNan(alphaZ(idx1,:),1);
    alphaZ = mean(alphaZ(idx1,:),1,'omitnan');
    betaZSem = semOmitNan(betaZ(idx1,:),1);
    betaZ = mean(betaZ(idx1,:),1,'omitnan');
    gammaZSem = semOmitNan(gammaZ(idx1,:),1);
    gammaZ = mean(gammaZ(idx1,:),1,'omitnan');
    hGammaZSem = semOmitNan(hGammaZ(idx1,:),1);
    hGammaZ = mean(hGammaZ(idx1,:),1,'omitnan');
end

h = figure;
ax = gca;
hold on;
shadedErrorBar(x,alphaZ,alphaZSem,'lineprops',{'Color',ax.ColorOrder(4,:),'linewidth',2});
shadedErrorBar(x,betaZ,betaZSem,'lineprops',{'Color',ax.ColorOrder(5,:),'linewidth',2});
shadedErrorBar(x,gammaZ,gammaZSem,'lineprops',{'Color',ax.ColorOrder(6,:),'linewidth',2});
% shadedErrorBar(x,hGammaZ,hGammaZSem,'lineprops',{'Color',ax.ColorOrder(4,:),'linewidth',2});

% shadedErrorBar(x,alphaZC,alphaZSemC,'lineprops',{'Color',ax.ColorOrder(1,:),'linewidth',2,'linestyle','--'});
% shadedErrorBar(x,betaZC,betaZSemC,'lineprops',{'Color',ax.ColorOrder(2,:),'linewidth',2,'linestyle','--'});
% shadedErrorBar(x,gammaZC,gammaZSemC,'lineprops',{'Color',ax.ColorOrder(3,:),'linewidth',2,'linestyle','--'});
% shadedErrorBar(x,hGammaZC,hGammaZSemC,'lineprops',{'Color',ax.ColorOrder(4,:),'linewidth',2,'linestyle','--'});

% legend('Gamma LGN','High Gamma LGN', 'Gamma Control','High Gamma Control')
legend('Alpha','Beta', 'Gamma','High Gamma')
xlabel('time (minutes)')
ylabel('Z Score');
ax.XLim = [-10,20];
ax.YLim = [0.8,2];
makeFigureBig(h);