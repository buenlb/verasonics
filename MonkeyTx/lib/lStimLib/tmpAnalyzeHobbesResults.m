%% Inside the bore
p = [1,1,1.5,1.5,1.5,2,1.5];
dc = [50,100,50,50,100,50,100];
lightsOff = [0,0,0,1,1,1];
prefix = {'testSonication_1_230221_','gamma_1MPa_100dc_230221_','gamma_1_230221_',...
    'gamma_1p5Mpa_50dc_inside_lightsOff_230221','gamma_1p5MPa_100dc_inside_lightsOff_230221_',...
    'gamma_2MPa_50dc_inside_lightsOff_230221','bbb_opening_noNPs_1p5Mpa_inside_lightsOff_230221_'};

for ii = 1:length(prefix)
    sys.EEGSystem = 'INTAN';
    if strcmp(sys.EEGSystem,'BCI')
        fName = 'C:\Users\Verasonics\Documents\OpenBCI_GUI\Recordings\OpenBCISession_gamma1_boltzmann20230131\OpenBCI-RAW-2023-01-31_13-18-46.txt';
        [t,eeg,digUs] = loadEegBci(fName,16);
        t = t-t(1);
    elseif strcmp(sys.EEGSystem,'INTAN')
        pth = 'D:\LStim\hobbes20230221\EEG\';
        fNameBase = prefix{ii};
        [t,eeg,dig] = concatIntan(pth,fNameBase);
        digUs = dig(1,:)';
        eeg = mean(eeg,1)';
    end
    gammaBnd(ii) = plotGamma_lstim(t,eeg,digUs,[30,70],'windowSize',2.5,'verbose',0);
    betaBnd(ii) = plotGamma_lstim(t,eeg,digUs,[14,30],'windowSize',2.5,'verbose',0);
    alphaBnd(ii) = plotGamma_lstim(t,eeg,digUs,[8,14],'windowSize',2.5,'verbose',0);
end

%% Plot
close all hidden
hg = figure;
ax = gca;

hb = figure;

ha = figure;

idx = find(dc==100);
idx = 1:length(dc);
pGamma = nan(size(idx));
pBeta = pGamma;
pAlpha = pGamma;
for ii = 1:length(idx)
    curIdx = idx(ii);
    c = mean(gammaBnd(curIdx).bndBefore);
    semMultiplier = 1;
    figure(hg);
    clf
    ax = gca;
    shadedErrorBar(gammaBnd(curIdx).tBefore-gammaBnd(curIdx).tBefore(1),100*gammaBnd(curIdx).bndBefore/c-100,semMultiplier*100*gammaBnd(curIdx).semBndBefore/c,'lineprops',{'Color',ax.ColorOrder(1,:)})
    shadedErrorBar(gammaBnd(curIdx).tDuring-gammaBnd(curIdx).tBefore(1),100*gammaBnd(curIdx).bndDuring/c-100,semMultiplier*100*gammaBnd(curIdx).semBndDuring/c,'lineprops',{'Color',ax.ColorOrder(2,:)})
    shadedErrorBar(gammaBnd(curIdx).tPost-gammaBnd(curIdx).tBefore(1),100*gammaBnd(curIdx).bndPost/c-100,semMultiplier*100*gammaBnd(curIdx).semBndPost/c,'lineprops',{'LineStyle','--','Color',ax.ColorOrder(3,:)})
    axis([0,300,-40,40])
    
    figure(hb)
    clf
    c = mean(betaBnd(curIdx).bndBefore);
    shadedErrorBar(betaBnd(curIdx).tBefore-betaBnd(curIdx).tBefore(1),100*betaBnd(curIdx).bndBefore/c-100,semMultiplier*100*betaBnd(curIdx).semBndBefore/c,'lineprops',{'Color',ax.ColorOrder(1,:)})
    shadedErrorBar(betaBnd(curIdx).tDuring-betaBnd(curIdx).tBefore(1),100*betaBnd(curIdx).bndDuring/c-100,semMultiplier*100*betaBnd(curIdx).semBndDuring/c,'lineprops',{'Color',ax.ColorOrder(2,:)})
    shadedErrorBar(betaBnd(curIdx).tPost-betaBnd(curIdx).tBefore(1),100*betaBnd(curIdx).bndPost/c-100,semMultiplier*100*betaBnd(curIdx).semBndPost/c,'lineprops',{'LineStyle','--','Color',ax.ColorOrder(3,:)})
    axis([0,300,-40,40])
    
    figure(ha)
    clf
    c = mean(alphaBnd(curIdx).bndBefore);
    shadedErrorBar(alphaBnd(curIdx).tBefore-alphaBnd(curIdx).tBefore(1),100*alphaBnd(curIdx).bndBefore/c-100,semMultiplier*100*alphaBnd(curIdx).semBndBefore/c,'lineprops',{'Color',ax.ColorOrder(1,:)})
    shadedErrorBar(alphaBnd(curIdx).tDuring-alphaBnd(curIdx).tBefore(1),100*alphaBnd(curIdx).bndDuring/c-100,semMultiplier*100*alphaBnd(curIdx).semBndDuring/c,'lineprops',{'Color',ax.ColorOrder(2,:)})
    shadedErrorBar(alphaBnd(curIdx).tPost-alphaBnd(curIdx).tBefore(1),100*alphaBnd(curIdx).bndPost/c-100,semMultiplier*100*alphaBnd(curIdx).semBndPost/c,'lineprops',{'LineStyle','--','Color',ax.ColorOrder(3,:)})
    axis([0,300,-40,40])

    ttestWindow = 60;
    idxBefore = find(gammaBnd(curIdx).tBefore>=gammaBnd(curIdx).tBefore(end)-ttestWindow);
    idxAfter = find(gammaBnd(curIdx).tPost<=gammaBnd(curIdx).tPost(1)+ttestWindow);

    [~,pGamma(ii)] = ttest2(gammaBnd(curIdx).bndBefore(idxBefore),gammaBnd(curIdx).bndPost(idxAfter));
    [~,pBeta(ii)] = ttest2(betaBnd(curIdx).bndBefore(idxBefore),betaBnd(curIdx).bndPost(idxAfter));
    [~,pAlpha(ii)] = ttest2(alphaBnd(curIdx).bndBefore(idxBefore),alphaBnd(curIdx).bndPost(idxAfter));

    diffGamma(ii) = mean(gammaBnd(curIdx).bndBefore(idxBefore))-mean(gammaBnd(curIdx).bndPost(idxAfter));
    diffBeta(ii) = mean(betaBnd(curIdx).bndBefore(idxBefore))-mean(betaBnd(curIdx).bndPost(idxAfter));
    diffAlpha(ii) = mean(alphaBnd(curIdx).bndBefore(idxBefore))-mean(alphaBnd(curIdx).bndPost(idxAfter));

    title(num2str(ii))
    drawnow
    
    if pGamma(ii)<0.06 || pBeta(ii) < 0.06 || pAlpha(ii) < 0.06
%         keyboard
    end
    
%     waitforbuttonpress
end