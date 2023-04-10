function [tBands,hAll,hDuring] = multiGammaResults(pth,fNameBase,bands,bandLabels)
[t,eeg,dig] = concatIntan(pth,fNameBase);
digUs = dig(1,:)';
eeg = mean(eeg,1)';

clear tBands;
for hh = 1:size(bands,1)
    bnd = plotGamma_lstim(t,eeg,digUs,bands(hh,:),'windowSize',3.5,'fftWindow',0.25,'verbose',0,'plotResults',0);
    
    divider = mean(bnd.bndBefore)/100;
    subtractor = 100;
%     close all hidden
    if hh == 1
        hAll = figure;
    else
        figure(hAll);
    end
    ax = gca;
    bf = shadedErrorBar(bnd.tBefore,bnd.bndBefore/divider-subtractor,bnd.semBndBefore/divider,'lineprops',{'Color',ax.ColorOrder(hh,:)});
    hold on
    if size(bnd.tDuring,2)>1
        for ii = 1:size(bnd.tDuring,1)
            dr = shadedErrorBar(bnd.tDuring(ii,:),bnd.bndDuring(ii,:)/divider-subtractor,bnd.semBndDuring(ii,:)/divider,'lineprops',{'Color',ax.ColorOrder(hh,:)});
        end
    else
        dr = shadedErrorBar(bnd.tDuring,bnd.bndDuring/divider-subtractor,bnd.semBndDuring/divider,'lineprops',{'Color',ax.ColorOrder(hh,:)});
    end
    ar = shadedErrorBar(bnd.tPost,bnd.bndPost/divider-subtractor,bnd.semBndPost/divider,'lineprops',{'Color',ax.ColorOrder(hh,:)});
    plot(bnd.tDuring(1)*ones(1,2),[-100,100],'k--')
    plot(bnd.tPost(1)*ones(1,2),[-100,100],'k--')

    lgPlts(hh) = bf.mainLine;

    tBands(hh) = bnd;

    duringBnd = plotGamma_lstim(t,eeg,digUs,bands(hh,:),'windowSize',0.5,'fftWindow',0.25,'verbose',0,'plotResults',0);
    if hh == 1
        hDuring = figure;
        hold on;
        ax = gca;
    else
        figure(hDuring);
    end
    pltDuring = shadedErrorBar(duringBnd.tDuring(1,:)-duringBnd.tDuring(1,1),mean(duringBnd.bndDuring,1)/mean(duringBnd.bndDuring(:,1)),semOmitNan(duringBnd.bndDuring,1)/mean(duringBnd.bndDuring(:,1)),'lineprops',{'Color',ax.ColorOrder(hh,:)});
    lgPltsDuring(hh) = pltDuring.mainLine;
end
figure(hAll)
xlabel('time (s)')
ylabel('% change')
legend(lgPlts,bandLabels)
makeFigureBig(hAll);

figure(hDuring)
xlabel('time (s)')
ylabel('Normalized Magnitude')
legend(lgPltsDuring,bandLabels)
makeFigureBig(hDuring);