h = figure;
requiredTimes = [0,300];
tmIdx = nan(size(requiredTimes));
for ii = 1:length(requiredTimes)
    tmIdx(ii) = find(tm==requiredTimes(ii));
end
sesIdx = idxLeft;
dVectorsNew = repmat([-120;-60;0;60;120],[1,size(dVectors,2),size(dVectors,3)]);
for ii = 1:length(sesIdx)
    hold on
    ax = gca;
    legendText = cell(1,length(tmIdx));
    pl = nan(1,length(tmIdx));
    include = false(size(tmIdx));
    for jj = 1:length(tmIdx)
        if sum(isnan(dVectorsNew(:,tmIdx(jj),sesIdx(ii))))
            continue;
        end
        ax.ColorOrderIndex = jj;
        plot(dVectorsNew(:,tmIdx(jj),sesIdx(ii)), 100*chVectors(:,tmIdx(jj),sesIdx(ii)),'*','LineWidth',3,'MarkerSize',8)
        [slope,bias,downshift,scale] = fitSigmoid(squeeze(dVectorsNew(:,tmIdx(jj),sesIdx(ii))),squeeze(chVectors(:,tmIdx(jj),sesIdx(ii))));
        ax.ColorOrderIndex = jj;
        y1 = sigmoid_ext(x,slope,bias,downshift,scale);
        if tm(tmIdx(jj)) == 0
            pl(jj) = plot(x,100*y1,':','LineWidth',2);
        elseif tm(tmIdx(jj))<0
            pl(jj) = plot(x,100*y1,'--','LineWidth',2);
        else
            pl(jj) = plot(x,100*y1,'LineWidth',2);
        end
        title(['Idx: ', num2str(sesIdx(ii)),', ',processedFiles{sesIdx(ii)}])
        legendText{jj} = ['t=',num2str(tm(tmIdx(jj))/60)];
        include(jj) = 1;
        disp(['Time=', num2str(tm(tmIdx(jj)))]);
        disp(['  Slope: ', num2str(slope,2)])
        disp(['  Bias: ', num2str(bias,2)])
        disp(['  Shift: ', num2str(downshift,2)])
        disp(['  Scale: ', num2str(scale,2)])
    end

    ax.ColorOrderIndex = 1;
%     plot(p0(sesIdx(ii)),50,'^','MarkerSize',8,'linewidth',2);
    for jj = 1:length(tmIdx)
        plot(p0(sesIdx(ii)),100*y(sesIdx(ii),tmIdx(jj)),'^','MarkerSize',8,'linewidth',2);
    end
    text(p0(sesIdx(ii))+10,100*y(sesIdx(ii),tmIdx(end)),num2str(y(sesIdx(ii),tmIdx(end)),2))

    plot([1,1]*p0(sesIdx(ii)), [0,100], 'k--')
    plot([-100,100], [50,50], 'k--')

    pl = pl(include);
    legendText = legendText(include);
    legend(pl,legendText,'location','southeast');
    xlabel('Delays (ms)')
    ylabel('Leftward Choices (%)')
    makeFigureBig(h);
    waitforbuttonpress
    clf;
end
close

h = figure;
ax = gca;
hold on
legendText = cell(1,length(tmIdx));
pl = nan(1,length(tmIdx));
for ii = 1:length(tmIdx)
    ax.ColorOrderIndex = ii;
    d = dVectorsNew(:,tmIdx(ii),sesIdx(1));
    c = mean(chVectors(:,tmIdx(ii),sesIdx),3,'omitnan');
    plot(d,100*c,'*','LineWidth',3,'MarkerSize',8)
    [slope,bias,downshift,scale] = fitSigmoid(d,c);
    ax.ColorOrderIndex = ii;
    y1 = sigmoid_ext(x,slope,bias,downshift,scale);
    pl(ii) = plot(x,100*y1,'LineWidth',2);
    title('All Sessions')
    legendText{ii} = ['t=',num2str(tm(tmIdx(ii))/60)];
    include(ii) = 1;
end
legend(pl,legendText,'location','southeast')
xlabel('Delays (ms)')
ylabel('Leftward Choices (%)')
makeFigureBig(h);