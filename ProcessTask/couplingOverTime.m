clear all; close all; clc;

taskPath = 'C:\Users\Taylor\Documents\Data\Task\';
couplingPath = 'C:\Users\Taylor\Documents\Data\Task\Coupling\';
gsCouplingFile = 'C:\Users\Taylor\Documents\Papers\MacaqueMethods\figs\gs_Euler_0925.mat';
% gsCouplingFile = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\20201014\UltrasoundData\Euler_GS_2ndReplace_20201014.mat';

files = dir([taskPath,'*.mat']);
passFinal = [];
passInitial = [];
tskIdx = 1;

gsData = load(gsCouplingFile);
gsDataRaw = gsData.fName;
for ii = 1:length(files)
    if strcmp(files(ii).name,'currentData.mat')
        continue
    end

    couplingFile = [couplingPath,files(ii).name(1:end-4), '_final.mat'];
    
    [gsRaw,crRaw,t,d] = getRawTraces(gsDataRaw,couplingFile,1);
    pw(ii,:) = max(crRaw(d>gsData.powerRange(1) & d<gsData.powerRange(2),:),[],1)./max(gsRaw(d>gsData.powerRange(1) & d<gsData.powerRange(2),:),[],1);
    sPw(ii,:) = sum(crRaw(d>gsData.powerRange(1) & d<gsData.powerRange(2),:),1)./sum(gsRaw(d>gsData.powerRange(1) & d<gsData.powerRange(2),:),1);
    
    gsSigs(ii,:,:) = gsRaw;
    crSigs(ii,:,:) = crRaw;
    [~,distErr(ii,:),~,totP(ii)] = checkCoupling(gsCouplingFile,couplingFile,1);
end

%%
h = figure;
plot(1:length(totP),mean(distErr,2),'-',[1,length(totP)],[1.15,1.15],'k--','linewidth',2)
xlabel('Session Number')
ylabel('Average Error (mm)')
legend('Error','Failure Threshold')
axis([0,50,0,3])
makeFigureBig(h)

h = figure;
plot(1:length(totP),max(distErr,[],2),'-',[1,length(totP)],[2.3,2.3],'k--','linewidth',2)
xlabel('Session Number')
ylabel('Maximum Error (mm)')
legend('Error','Failure Threshold')
axis([0,50,0,3])
makeFigureBig(h)

Trans = transducerGeometry(0);
xTx = Trans.ElementPos(:,1);
yTx = -Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);
clear elements
elements.x = xTx*1e-3;
elements.y = yTx*1e-3;
elements.z = zTx*1e-3;
xLoc = elements.x*1e3;
yLoc = elements.y*1e3;
zLoc = elements.z*1e3;
avgPw = mean(pw,1);
avgPw(avgPw>1)=1;
plotElementValues(elements.x*1e3,elements.y*1e3,elements.z*1e3,avgPw,'jet');
title('Average Echo Peak')
ax = gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
xlabel('')
ylabel('')

h = figure;
plot(1:length(totP),100*totP,[0,50],[-30,-30],'k--','linewidth',2)
ylabel('Pressure Error (%)')
xlabel('Session Number')
legend('Average Pressure Error','Failure Threshold')
makeFigureBig(h)
%%
h = figure;
elements = [67:69,75:77,83:85]+8*14;
% elements = 76+0*14;
curGs = mean(gsSigs(1,:,elements),3); 
curCr = mean(mean(crSigs(:,:,elements),3),1);
curGs = curGs(d<gsData.powerRange(2) & d>0*gsData.powerRange(1));
curCr = curCr(d<gsData.powerRange(2) & d>0*gsData.powerRange(1));
dCat = d(d<gsData.powerRange(2) & d>0*gsData.powerRange(1));
plot(dCat,curGs/max(curGs),dCat,curCr/max(curGs),'linewidth',2)
xlabel('Distance from Tx (mm)')
ylabel('Pressure [a.u.]')
legend('MR','Average Over Sessions')
makeFigureBig(h)

% h = figure;
hold on
ax = gca;
ax.ColorOrderIndex = 1;
plot(dCat,cumsum(curGs)/sum(curGs),'--',dCat,cumsum(curCr)/sum(curGs),'--','linewidth',2)
xlabel('Distance from Tx (mm)')
ylabel('Pressure [a.u.]')
legend('MR','Average Over Sessions','Cumulative Sum','Cumulative Sum')
makeFigureBig(h)

pRangeIdx = find(d<gsData.powerRange(2) & d>gsData.powerRange(1));
spotPwGs = max(mean(gsSigs(1,pRangeIdx,elements),3));
spotPwCr = max(mean(crSigs(:,pRangeIdx,elements),3),[],2);
% spotPwCr = mean(crSigs(:,pRangeIdx,elements),3);
h = figure;
plot(1:length(totP),100*(spotPwCr-spotPwGs)/spotPwGs)

clear slope
clear p
for ii = 1:256
    curEl = max(crSigs(:,pRangeIdx,ii),[],2)/max(gsSigs(1,pRangeIdx,ii));
    lm = fitlm(1:length(totP),curEl');
    p(ii) = coefTest(lm);
    x = coefCI(lm,1);
    slope(ii) = x(2);
end
slope(slope>0.05) = 0.05;
slope(slope<-0.05) = -0.05;
slope(p>0.01) = 0;
plotElementValues(xLoc,yLoc,zLoc,slope*100,'jet');
ax = gca;
ax.XTickLabel = [];
ax.YTickLabel = [];
xlabel('')
ylabel('')
ax.XAxis.Visible = 'off';
ax.YAxis.Visible = 'off';
title('% Change/Session')