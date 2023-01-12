clear; close all; clc
monk = 'b';

switch monk
    case 'b'
        files = {'D:\Task\Boltz\boltzmann20211005.mat',...
        'D:\Task\Boltz\boltzmann20211008.mat',...
        'D:\Task\Boltz\boltzmann20211011.mat',...
        'D:\Task\Boltz\boltzmann20211013.mat',...
        'D:\Task\Boltz\boltzmann20211020.mat',...
        'D:\Task\Boltz\boltzmann20211101.mat',...
        'D:\Task\Boltz\boltzmann20211109.mat',...
        'D:\Task\Boltz\boltzmann20211111.mat',...
        'D:\Task\Boltz\boltzmann20211118.mat'};
    case 'e'
        files = {'D:\Task\Euler\Euler20210217.mat',...
            'D:\Task\Euler\Euler20210218.mat',...
            'D:\Task\Euler\Euler20210219B.mat',...
            'D:\Task\Euler\Euler20210226.mat',...
            'D:\Task\Euler\Euler20210301.mat',...
            'D:\Task\Euler\Euler20210316.mat',...
            'D:\Task\Euler\Euler20210331_b.mat',...
            'D:\Task\Euler\Euler20210402.mat',...
            'D:\Task\Euler\Euler20210407.mat',...
            'D:\Task\Euler\Euler20210511.mat',...
            'D:\Task\Euler\Euler20210517.mat',...
            'D:\Task\Euler\Euler20210520.mat'};
end

tA = [];
for ii = 1:length(files)
    disp(['Session ', num2str(ii), ' of ', num2str(length(files))])
    tData(ii) = processTaskData(files{ii});
    for jj = 1:length(files{ii})
        if ~isnan(str2double(files{ii}(jj))) && isreal(str2double(files{ii}(jj)))
            date(ii).year = (files{ii}(jj:(jj+3)));
            date(ii).month = (files{ii}((jj+4):(jj+5)));
            date(ii).day = (files{ii}((jj+6):(jj+7)));
            break;
        end
    end
    switch monk
        case 'b'
            pth = 'D:\Task\Boltz\eeg\';
            baseName1 = 'boltzmannTask_';
        case 'e'
            pth = 'D:\Task\Euler\eeg\';
            baseName1 = 'Euler_';
    end
    baseName = [baseName1,date(ii).year(3:4),date(ii).month,date(ii).day];
    if isempty(tA)
        [tA,eegLeft{ii},eegRight{ii},trigCheck{ii}] = loadEEGTaskData(pth,baseName,tData(ii));
    else
        [~,eegLeft{ii},eegRight{ii},trigCheck{ii}] = loadEEGTaskData(pth,baseName,tData(ii));
    end
    if ~isempty(eegLeft{ii})
        h = figure(99);
        tmpIdx = find(tData(ii).lgn);
        plotVep(tA*1e3,trigCheck{ii}(tmpIdx,:))
        title(['Session: ', num2str(ii)])
        drawnow
        keyboard
    end
end
%% 
curEegLeftPosDelay = [];
curEegRightPosDelay = [];
curEegLeftNegDelay = [];
curEegRightNegDelay = [];
curEegLeftZerDelay = [];
curEegRightZerDelay = [];
curEegLeft = [];
curEegRight = [];

curEegLeftPosDelayLeftLGN = [];
curEegRightPosDelayLeftLGN = [];
curEegLeftNegDelayLeftLGN = [];
curEegRightNegDelayLeftLGN = [];
curEegLeftZerDelayLeftLGN = [];
curEegRightZerDelayLeftLGN = [];
curEegLeftLeftLGN = [];
curEegRightLeftLGN = [];

curEegLeftPosDelayRightLGN = [];
curEegRightPosDelayRightLGN = [];
curEegLeftNegDelayRightLGN = [];
curEegRightNegDelayRightLGN = [];
curEegLeftZerDelayRightLGN = [];
curEegRightZerDelayRightLGN = [];
curEegLeftRightLGN = [];
curEegRightRightLGN = [];

curEegRightPosDelayCtl = [];
curEegRightNegDelayCtl = [];
curEegRightZerDelayCtl = [];
curEegLeftPosDelayCtl = [];
curEegLeftNegDelayCtl = [];
curEegLeftZerDelayCtl = [];

for ii = 1:length(files)
    if isempty(eegLeft{ii})
        continue
    end
    curIdx = find(tData(ii).delay > 0 & ~tData(ii).lgn & ~isnan(tData(ii).ch));
    curEegLeftPosDelay = cat(1,curEegLeftPosDelay,eegLeft{ii}(curIdx,:));
    curEegRightPosDelay = cat(1,curEegRightPosDelay,eegRight{ii}(curIdx,:));

    curIdx = find(tData(ii).delay < 0 & ~tData(ii).lgn & ~isnan(tData(ii).ch));
    curEegLeftNegDelay = cat(1,curEegLeftNegDelay,eegLeft{ii}(curIdx,:));
    curEegRightNegDelay = cat(1,curEegRightNegDelay,eegRight{ii}(curIdx,:));

    curIdx = find(tData(ii).delay == 0 & ~tData(ii).lgn & ~isnan(tData(ii).ch));
    curEegLeftZerDelay = cat(1,curEegLeftZerDelay,eegLeft{ii}(curIdx,:));
    curEegRightZerDelay = cat(1,curEegRightZerDelay,eegRight{ii}(curIdx,:));

    curIdx = 1:size(eegLeft{ii},1);
    curEegLeft = cat(1,curEegLeft,eegLeft{ii}(curIdx,:));
    curEegRight = cat(1,curEegRight,eegRight{ii}(curIdx,:));

    % Left LGN
    curIdx = find(tData(ii).delay > 0 & tData(ii).lgn<0 & ~isnan(tData(ii).ch));
    curEegLeftPosDelayLeftLGN = cat(1,curEegLeftPosDelayLeftLGN,eegLeft{ii}(curIdx,:));
    curEegRightPosDelayLeftLGN = cat(1,curEegRightPosDelayLeftLGN,eegRight{ii}(curIdx,:));

    curIdx = find(tData(ii).delay < 0 & tData(ii).lgn<0 & ~isnan(tData(ii).ch));
    curEegLeftNegDelayLeftLGN = cat(1,curEegLeftNegDelayLeftLGN,eegLeft{ii}(curIdx,:));
    curEegRightNegDelayLeftLGN = cat(1,curEegRightNegDelayLeftLGN,eegRight{ii}(curIdx,:));

    curIdx = find(tData(ii).delay == 0 & tData(ii).lgn<0 & ~isnan(tData(ii).ch));
    curEegLeftZerDelayLeftLGN = cat(1,curEegLeftZerDelayLeftLGN,eegLeft{ii}(curIdx,:));
    curEegRightZerDelayLeftLGN = cat(1,curEegRightZerDelayLeftLGN,eegRight{ii}(curIdx,:));

    curIdx = 1:size(eegLeft{ii},1);
    curEegLeftLeftLGN = cat(1,curEegLeftLeftLGN,eegLeft{ii}(curIdx,:));
    curEegRightLeftLGN = cat(1,curEegRightLeftLGN,eegRight{ii}(curIdx,:));

    % Right LGN
    curIdx = find(tData(ii).delay > 0 & tData(ii).lgn>0 & ~isnan(tData(ii).ch));
    curEegLeftPosDelayRightLGN = cat(1,curEegLeftPosDelayRightLGN,eegLeft{ii}(curIdx,:));
    curEegRightPosDelayRightLGN = cat(1,curEegRightPosDelayRightLGN,eegRight{ii}(curIdx,:));

    curIdx = find(tData(ii).delay < 0 & tData(ii).lgn>0 & ~isnan(tData(ii).ch));
    curEegLeftNegDelayRightLGN = cat(1,curEegLeftNegDelayRightLGN,eegLeft{ii}(curIdx,:));
    curEegRightNegDelayRightLGN = cat(1,curEegRightNegDelayRightLGN,eegRight{ii}(curIdx,:));

    curIdx = find(tData(ii).delay == 0 & tData(ii).lgn>0 & ~isnan(tData(ii).ch));
    curEegLeftZerDelayRightLGN = cat(1,curEegLeftZerDelayRightLGN,eegLeft{ii}(curIdx,:));
    curEegRightZerDelayRightLGN = cat(1,curEegRightZerDelayRightLGN,eegRight{ii}(curIdx,:));

    curIdx = 1:size(eegLeft{ii},1);
    curEegLeftRightLGN = cat(1,curEegLeftRightLGN,eegLeft{ii}(curIdx,:));
    curEegRightRightLGN = cat(1,curEegRightRightLGN,eegRight{ii}(curIdx,:));

    % Control
    curIdx = find(tData(ii).delay > 0 & tData(ii).lgn==0 & ~isnan(tData(ii).ch));
    curEegLeftPosDelayCtl = cat(1,curEegLeftPosDelayCtl,eegLeft{ii}(curIdx,:));
    curEegRightPosDelayCtl = cat(1,curEegRightPosDelayCtl,eegRight{ii}(curIdx,:));

    curIdx = find(tData(ii).delay < 0 & tData(ii).lgn==0 & ~isnan(tData(ii).ch));
    curEegLeftNegDelayCtl = cat(1,curEegLeftNegDelayCtl,eegLeft{ii}(curIdx,:));
    curEegRightNegDelayCtl = cat(1,curEegRightNegDelayCtl,eegRight{ii}(curIdx,:));

    curIdx = find(tData(ii).delay == 0 & tData(ii).lgn==0 & ~isnan(tData(ii).ch));
    curEegLeftZerDelayCtl = cat(1,curEegLeftZerDelayCtl,eegLeft{ii}(curIdx,:));
    curEegRightZerDelayCtl = cat(1,curEegRightZerDelayCtl,eegRight{ii}(curIdx,:));
    
end
%%
h = figure;
ax = gca;
plotVep(tA,curEegLeftPosDelayLeftLGN,1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(tA,curEegRightPosDelayLeftLGN,1,ax,{'Color',ax.ColorOrder(2,:)});
legend('Left Pin','Right Pin')
title('Positive Delay Left LGN')
makeFigureBig(h)

h = figure;
ax = gca;
plotVep(tA,curEegLeftPosDelayRightLGN,1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(tA,curEegRightPosDelayRightLGN,1,ax,{'Color',ax.ColorOrder(2,:)});
legend('Left Pin','Right Pin')
title('Positive Delay Right LGN')
makeFigureBig(h)

h = figure;
ax = gca;
plotVep(tA,curEegLeftPosDelayLeftLGN,1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(tA,curEegLeftPosDelayRightLGN,1,ax,{'Color',ax.ColorOrder(2,:)});
legend('Left LGN','Right LGN')
title('Positive Delay Left Pin')
makeFigureBig(h)

h = figure;
ax = gca;
plotVep(tA,curEegRightPosDelayLeftLGN,1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(tA,curEegRightPosDelayRightLGN,1,ax,{'Color',ax.ColorOrder(2,:)});
title('Positive Delay Right Pin')
legend('Left LGN','Right LGN')
makeFigureBig(h)

h = figure;
ax = gca;
plotVep(tA,curEegLeftNegDelayLeftLGN,1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(tA,curEegLeftNegDelayRightLGN,1,ax,{'Color',ax.ColorOrder(2,:)});
legend('Left LGN','Right LGN')
title('Negative Delay Left Pin')
makeFigureBig(h)

h = figure;
ax = gca;
plotVep(tA,curEegRightNegDelayLeftLGN,1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(tA,curEegRightNegDelayRightLGN,1,ax,{'Color',ax.ColorOrder(2,:)});
title('Negative Delay Right Pin')
legend('Left LGN','Right LGN')
makeFigureBig(h)

h = figure;
ax = gca;
plotVep(tA,curEegLeftZerDelayLeftLGN,1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(tA,curEegLeftZerDelayRightLGN,1,ax,{'Color',ax.ColorOrder(2,:)});
legend('Left LGN','Right LGN')
title('Zero Delay Left Pin')
makeFigureBig(h)

h = figure;
ax = gca;
plotVep(tA,curEegRightZerDelayLeftLGN,1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(tA,curEegRightZerDelayRightLGN,1,ax,{'Color',ax.ColorOrder(2,:)});
title('Zero Delay Right Pin')
legend('Left LGN','Right LGN')
makeFigureBig(h)

h = figure;
ax = gca;
plotVep(tA,[curEegRightPosDelayLeftLGN;curEegLeftPosDelayLeftLGN],1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(tA,[curEegRightPosDelayRightLGN;curEegLeftPosDelayRightLGN],1,ax,{'Color',ax.ColorOrder(2,:)});
title('Positive Delay Both Pins')
legend('Left LGN','Right LGN')
makeFigureBig(h)

h = figure;
ax = gca;
plotVep(tA,[curEegRightNegDelayLeftLGN;curEegLeftNegDelayLeftLGN],1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(tA,[curEegRightNegDelayRightLGN;curEegLeftNegDelayRightLGN],1,ax,{'Color',ax.ColorOrder(2,:)});
title('Negative Delay Both Pins')
legend('Left LGN','Right LGN')
makeFigureBig(h)

h = figure;
ax = gca;
plotVep(tA,[curEegRightZerDelayLeftLGN;curEegLeftZerDelayLeftLGN],1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(tA,[curEegRightZerDelayRightLGN;curEegLeftZerDelayRightLGN],1,ax,{'Color',ax.ColorOrder(2,:)});
plotVep(tA,[curEegRightZerDelayCtl;curEegLeftZerDelayCtl],1,ax,{'Color',ax.ColorOrder(3,:)});
title('Zero Delay Both Pins')
legend('Left LGN','Right LGN')
makeFigureBig(h)

h = figure;
ax = gca;
plotVep(tA,curEegRightZerDelayLeftLGN-curEegLeftZerDelayLeftLGN,1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(tA,curEegRightZerDelayRightLGN-curEegLeftZerDelayRightLGN,1,ax,{'Color',ax.ColorOrder(2,:)});
plotVep(tA,curEegRightZerDelayCtl-curEegLeftZerDelayCtl,1,ax,{'Color',ax.ColorOrder(3,:)});
title('Zero Delay Right Minus Left')
legend('Left LGN','Right LGN', 'Control')
makeFigureBig(h)

%% Spectra
window = [];
afterIdx = find(tA>150e-3 & tA<350e-3);
[deltaCtlA,thetaCtlA,alphaCtlA,betaCtlA,gammaCtlA,tWindow] = eegSpectra(tA(afterIdx),[curEegRightZerDelayCtl(:,afterIdx);curEegLeftZerDelayCtl(:,afterIdx)],window);
[deltaLeftLGNA,thetaLeftLGNA,alphaLeftLGNA,betaLeftLGNA,gammaLeftLGNA] = eegSpectra(tA(afterIdx),[curEegRightZerDelayLeftLGN(:,afterIdx);curEegLeftZerDelayLeftLGN(:,afterIdx)],window);
[deltaRightLGNA,thetaRightLGNA,alphaRightLGNA,betaRightLGNA,gammaRightLGNA] = eegSpectra(tA(afterIdx),[curEegRightZerDelayRightLGN(:,afterIdx);curEegLeftZerDelayRightLGN(:,afterIdx)],window);
[deltaLGNA,thetaLGNA,alphaLGNA,betaLGNA,gammaLGNA] = eegSpectra(tA(afterIdx),[curEegRightZerDelayRightLGN(:,afterIdx);curEegLeftZerDelayRightLGN(:,afterIdx);...
    curEegRightZerDelayLeftLGN(:,afterIdx);curEegLeftZerDelayLeftLGN(:,afterIdx)],window);

mdeltaCtlA = mean(deltaCtlA,'omitnan');
mthetaCtlA = mean(thetaCtlA,'omitnan');
malphaCtlA = mean(alphaCtlA,'omitnan');
mbetaCtlA = mean(betaCtlA,'omitnan');
mgammaCtlA = mean(gammaCtlA,'omitnan');

mdeltaLGNA = mean(deltaLGNA,'omitnan');
mthetaLGNA = mean(thetaLGNA,'omitnan');
malphaLGNA = mean(alphaLGNA,'omitnan');
mbetaLGNA = mean(betaLGNA,'omitnan');
mgammaLGNA = mean(gammaLGNA,'omitnan');

sdeltaCtlA = semOmitNan(deltaCtlA);
sthetaCtlA = semOmitNan(thetaCtlA);
salphaCtlA = semOmitNan(alphaCtlA);
sbetaCtlA = semOmitNan(betaCtlA);
sgammaCtlA = semOmitNan(gammaCtlA);

sdeltaLGNA = semOmitNan(deltaLGNA);
sthetaLGNA = semOmitNan(thetaLGNA);
salphaLGNA = semOmitNan(alphaLGNA);
sbetaLGNA = semOmitNan(betaLGNA);
sgammaLGNA = semOmitNan(gammaLGNA);

beforeIdx = find(tA<-250e-3 & tA>=-450e-3);
[deltaCtlB,thetaCtlB,alphaCtlB,betaCtlB,gammaCtlB,tWindowB] = eegSpectra(tA(beforeIdx),[curEegRightZerDelayCtl(:,beforeIdx);curEegLeftZerDelayCtl(:,beforeIdx)],window);
[deltaLeftLGNB,thetaLeftLGNB,alphaLeftLGNB,betaLeftLGNB,gammaLeftLGNB] = eegSpectra(tA(beforeIdx),[curEegRightZerDelayLeftLGN(:,beforeIdx);curEegLeftZerDelayLeftLGN(:,beforeIdx)],window);
[deltaRightLGNB,thetaRightLGNB,alphaRightLGNB,betaRightLGNB,gammaRightLGNB] = eegSpectra(tA(beforeIdx),[curEegRightZerDelayRightLGN(:,beforeIdx);curEegLeftZerDelayRightLGN(:,beforeIdx)],window);
[deltaLGNB,thetaLGNB,alphaLGNB,betaLGNB,gammaLGNB] = eegSpectra(tA(beforeIdx),[curEegRightZerDelayRightLGN(:,beforeIdx);curEegLeftZerDelayRightLGN(:,beforeIdx);...
    curEegRightZerDelayLeftLGN(:,beforeIdx);curEegLeftZerDelayLeftLGN(:,beforeIdx)],window);

mdeltaCtlB = mean(deltaCtlB,'omitnan');
mthetaCtlB = mean(thetaCtlB,'omitnan');
malphaCtlB = mean(alphaCtlB,'omitnan');
mbetaCtlB = mean(betaCtlB,'omitnan');
mgammaCtlB = mean(gammaCtlB,'omitnan');

mdeltaLGNB = mean(deltaLGNB,'omitnan');
mthetaLGNB = mean(thetaLGNB,'omitnan');
malphaLGNB = mean(alphaLGNB,'omitnan');
mbetaLGNB = mean(betaLGNB,'omitnan');
mgammaLGNB = mean(gammaLGNB,'omitnan');

sdeltaCtlB = semOmitNan(deltaCtlB);
sthetaCtlB = semOmitNan(thetaCtlB);
salphaCtlB = semOmitNan(alphaCtlB);
sbetaCtlB = semOmitNan(betaCtlB);
sgammaCtlB = semOmitNan(gammaCtlB);

sdeltaLGNB = semOmitNan(deltaLGNB);
sthetaLGNB = semOmitNan(thetaLGNB);
salphaLGNB = semOmitNan(alphaLGNB);
sbetaLGNB = semOmitNan(betaLGNB);
sgammaLGNB = semOmitNan(gammaLGNB);

h = figure;
b(1) = bar(1:3:14,[mdeltaCtlB,mthetaCtlB,malphaCtlB,mbetaCtlB,mgammaCtlB],1/3);
hold on
eb = errorbar(1:3:14,[mdeltaCtlB,mthetaCtlB,malphaCtlB,mbetaCtlB,mgammaCtlB],...
        [sdeltaCtlB,sthetaCtlB,salphaCtlB,sbetaCtlB,sgammaCtlB]);
set(eb,'linestyle','none','Color',[0,0,0]);

b(2) = bar(2:3:14,[mdeltaLGNB,mthetaLGNB,malphaLGNB,mbetaLGNB,mgammaLGNB],1/3);
eb = errorbar(2:3:14,[mdeltaLGNB,mthetaLGNB,malphaLGNB,mbetaLGNB,mgammaLGNB],...
        [sdeltaLGNB,sthetaLGNB,salphaLGNB,sbetaLGNB,sgammaLGNB]);
set(eb,'linestyle','none','Color',[0,0,0]);

title('Before Trial')
[~,p(1)] = ttest2(deltaCtlB,deltaLGNB);
[~,p(2)] = ttest2(thetaCtlB,thetaLGNB);
[~,p(3)] = ttest2(alphaCtlB,alphaLGNB);
[~,p(4)] = ttest2(betaCtlB,betaLGNB);
[~,p(5)] = ttest2(gammaCtlB,gammaLGNB);
intervals = {[1,2],[4,5],[7,8],[10,11],[13,14]};
intervals = intervals(p<0.05);
p = p(p<0.05);
sigstar(intervals,p)
xticks([1.5,4.5,7.5,10.5,13.5])
xticklabels({'\Delta','\Theta','\alpha','\beta','\Gamma'})
xtickangle(0)
legend(b,'No Ultrasound','Ultrasound')
makeFigureBig(h)

h = figure;
b(1) = bar(1:3:14,[mdeltaCtlA,mthetaCtlA,malphaCtlA,mbetaCtlA,mgammaCtlA],1/3);
hold on
eb = errorbar(1:3:14,[mdeltaCtlA,mthetaCtlA,malphaCtlA,mbetaCtlA,mgammaCtlA],...
        [sdeltaCtlA,sthetaCtlA,salphaCtlA,sbetaCtlA,sgammaCtlA]);
set(eb,'linestyle','none','Color',[0,0,0]);

b(2) = bar(2:3:14,[mdeltaLGNA,mthetaLGNA,malphaLGNA,mbetaLGNA,mgammaLGNA],1/3);
eb = errorbar(2:3:14,[mdeltaLGNA,mthetaLGNA,malphaLGNA,mbetaLGNA,mgammaLGNA],...
        [sdeltaLGNA,sthetaLGNA,salphaLGNA,sbetaLGNA,sgammaLGNA]);
set(eb,'linestyle','none','Color',[0,0,0]);

title('After Trial')
[~,p(1)] = ttest2(deltaCtlA,deltaLGNA);
[~,p(2)] = ttest2(thetaCtlA,thetaLGNA);
[~,p(3)] = ttest2(alphaCtlA,alphaLGNA);
[~,p(4)] = ttest2(betaCtlA,betaLGNA);
[~,p(5)] = ttest2(gammaCtlA,gammaLGNA);
intervals = {[1,2],[4,5],[7,8],[10,11],[13,14]};
intervals = intervals(p<0.05);
p = p(p<0.05);
sigstar(intervals,p)
xticks([1.5,4.5,7.5,10.5,13.5])
xticklabels({'\Delta','\Theta','\alpha','\beta','\Gamma'})
xtickangle(0)
legend(b,'No Ultrasound','Ultrasound')
makeFigureBig(h)

return
h = figure;
ax = gca;
plotVep(tA,curEegLeftNegDelay,1,ax,{'Color',ax.ColorOrder(1,:)});
plotVep(tA,curEegRightNegDelay,1,ax,{'Color',ax.ColorOrder(2,:)});
title('NegativeDelay')
makeFigureBig(h)

h = figure;
ax = gca;
plotVep(tA,curEegLeftZerDelay,1,ax,{'Color',ax.ColorOrder(1,:)})
plotVep(tA,curEegRightZerDelay,1,ax,{'Color',ax.ColorOrder(2,:)})
title('Zero Delay')
makeFigureBig(h)

h = figure;
ax = gca;
plotVep(tA,curEegLeft,1,ax,{'Color',ax.ColorOrder(1,:)})
plotVep(tA,curEegRight,1,ax,{'Color',ax.ColorOrder(2,:)})
title('All')
makeFigureBig(h)

% h = figure;
% ax = gca;
% plotVep(tA,curEegLeftPosDelay,1,ax,{'Color',ax.ColorOrder(1,:)})
% plotVep(tA,curEegRightPosDelay,1,ax,{'Color',ax.ColorOrder(2,:)})
% title('Positive Delay')
% makeFigureBig(h)
% 
% h = figure;
% ax = gca;
% plotVep(tA,curEegLeftNegDelay,1,ax,{'Color',ax.ColorOrder(1,:)})
% plotVep(tA,curEegRightNegDelay,1,ax,{'Color',ax.ColorOrder(2,:)})
% title('NegativeDelay')
% makeFigureBig(h)
% 
% h = figure;
% ax = gca;
% plotVep(tA,curEegLeftZerDelay,1,ax,{'Color',ax.ColorOrder(1,:)})
% plotVep(tA,curEegRightZerDelay,1,ax,{'Color',ax.ColorOrder(2,:)})
% title('Zero Delay')
% makeFigureBig(h)
% 
% h = figure;
% ax = gca;
% plotVep(tA,curEegLeft,1,ax,{'Color',ax.ColorOrder(1,:)})
% plotVep(tA,curEegRight,1,ax,{'Color',ax.ColorOrder(2,:)})
% title('All')
% makeFigureBig(h)