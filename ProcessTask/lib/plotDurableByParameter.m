ptDc = zeros(size(I));
ptV = zeros(size(I));
for ii = 1:length(I)
    ptDc(ii) = dc(idxPts{ii}(1));
    ptV(ii) = v(idxPts{ii}(1));
end

avgConv = 55.2;

% xVar = round(I/10)*10;
% xVar = round(Ispta*10)/10;
% xVar = floor(Ispta);
% xVar = round(ptDc*100)/100;
% xVar = round(ptV*10)/10;
% xVar = round(ptDc*100)/100.*(round(ptV*10)/10).^2; xVar = floor(xVar/10)*10; xVar(xVar == 20) = 10;
I_spta_ave = p2I_brain(ptV*avgConv*1e3)/1e4.*ptDc;
xVar = floor(I_spta_ave); xVar(xVar == 2) = 1;
uI = unique(xVar);
idxOfInterest = find(tm==0.0*60);

chLeft = nan(size(uI));
stdLeft = nan(size(uI));
chRight = nan(size(uI));
stdRight = nan(size(uI));
chContra = nan(size(uI));
stdContra = nan(size(uI));
chCtl = nan(size(uI));
stdCtl = nan(size(uI));
for ii = 1:length(uI)
    idxLeft = [];
    idxRight = [];
    idxCtl = [];
    for jj = 1:length(xVar)
%         if monkS(jj) == 'b'
%             continue
%         end
        if xVar(jj)==uI(ii)
            idxLeft = cat(2,idxLeft,idxPts{jj}(ss{jj}==-1));
            idxRight = cat(2,idxRight,idxPts{jj}(ss{jj}==1));
            idxCtl = cat(2,idxCtl,idxPts{jj}(ss{jj}==0));
        end
    end
    if length(idxLeft)<4 || length(idxRight)<4
        continue; % Only include data if there are at least 4 sessions per side
    end
    length(idxLeft)
    length(idxRight)
    disp(['Parameter: ', num2str(uI(ii))]);
    chLeft(ii) = mean(y(idxLeft,idxOfInterest),1,'omitnan');
    stdLeft(ii) = semOmitNan(y(idxLeft,idxOfInterest),1);

    chRight(ii) = mean(y(idxRight,idxOfInterest),1,'omitnan');
    stdRight(ii) = semOmitNan(y(idxRight,idxOfInterest),1);

    chContra(ii) = mean([y(idxRight,idxOfInterest);1-y(idxLeft,idxOfInterest)],1,'omitnan');
    stdContra(ii) = semOmitNan([y(idxRight,idxOfInterest);1-y(idxLeft,idxOfInterest)],1);

    chCtl(ii) = mean(y(idxCtl,idxOfInterest),1,'omitnan');
    stdCtl(ii) = semOmitNan(y(idxCtl,idxOfInterest),1);

    h = figure;
    ax = gca;
    yLeft = mean(y(idxLeft,:),1,'omitnan');
    yLeftSem = semOmitNan(y(idxLeft,:),1);
    yRight = mean(y(idxRight,:),1,'omitnan');
    yRightSem = semOmitNan(y(idxRight,:),1);
    shadedErrorBar(tm/60+5,100*yLeft,100*yLeftSem,'lineprops',{'Color',ax.ColorOrder(1,:),'linewidth',2})
    hold on;
    shadedErrorBar(tm/60+5,100*yRight,100*yRightSem,'lineprops',{'Color',ax.ColorOrder(2,:),'linewidth',2})
    if exist('idxCtl','var')
        yCtl = mean(y(idxCtl,:),1,'omitnan');
        yCtlSem = semOmitNan(y(idxCtl,:),1);
        shadedErrorBar(tm/60+5,100*yCtl,100*yCtlSem,'lineprops',{'Color',ax.ColorOrder(3,:),'linewidth',2})
    end
    axis([0,20,40,60])
    plot([-120,120],[1,1]*66.67,'k:')
    plot([-120,120],[1,1]*33.33,'k:')
    plot([-120,120],[1,1]*50,'k-')
    plot([-120,120],[1,1]*75,'k-.')
    plot([-120,120],[1,1]*25,'k-.')
    title(['ii=',num2str(ii)])
    makeFigureBig(h);
end
% uI = uI*100;
uI = uI(~isnan(chContra));
chLeft = chLeft(~isnan(chLeft));
chRight = chRight(~isnan(chContra));
stdContra = stdContra(~isnan(chContra));
stdLeft = stdLeft(~isnan(chContra));
stdRight = stdRight(~isnan(chContra));
chContra = chContra(~isnan(chContra));
yLims = [30,70];
h = figure;
ax = gca;
bar(uI,chContra*100,'BaseValue',50)
hold on
eb = errorbar(uI,chContra*100,stdContra*100);
set(eb,'linestyle','none','Color','k')
ylabel('Contralateral Choices (%)')
ax.YLim = yLims;
makeFigureBig(h)

h = figure;
subplot(211)
ax = gca;
bar(uI,chLeft*100,'BaseValue',50)
hold on
eb = errorbar(uI,chLeft*100,stdLeft*100);
set(eb,'linestyle','none','Color','k')
ylabel('Leftward Choices (%)')
title('Left LGN')
ax.YLim = yLims;
makeFigureBig(h)

subplot(212)
ax = gca;
bar(uI,chRight*100,'BaseValue',50)
hold on
eb = errorbar(uI,chRight*100,stdRight*100);
ax.YLim = yLims;
set(eb,'linestyle','none','Color','k')
ylabel('Leftward Choices (%)')
title('Right LGN')
makeFigureBig(h)
h.Position = [680   191   560   787];