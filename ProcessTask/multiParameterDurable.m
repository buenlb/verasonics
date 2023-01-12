% The purpose of this file is to examine how different parameters -
% including when the session was performed - contribute to the measured
% outcome.
close all hidden; clc
%% Bar plots as a function of power
EPP = 0;
desiredIspta = {[0,1],[1,2],[2,3]};
desiredTm = 5:5:15;
br = nan(length(desiredIspta),length(desiredTm));
x = zeros(size(desiredIspta));
legendLabels = cell(size(desiredTm));
xLabel = cell(desiredIspta);
bIdx = find(monk=='b');
eIdx = find(monk=='e');
for ii = 1:length(desiredIspta)
    xLabel{ii} = [num2str(desiredIspta{ii}(1)),'<I_{SPTA}<=',num2str(desiredIspta{ii}(2))];
    ptIdx = find(Ispta<=desiredIspta{ii}(2) & Ispta>desiredIspta{ii}(1));
    idxLeft = [];
    idxRight = [];
    idxCtl = [];
    for jj = 1:length(ptIdx)
    %     if monkS(ptIdx(jj))=='e'
    %         continue
    %     end
        idxLeft = cat(2,idxLeft,idxPts{ptIdx(jj)}(ss{ptIdx(jj)}==-1));
        idxRight = cat(2,idxRight,idxPts{ptIdx(jj)}(ss{ptIdx(jj)}==1));
        idxCtl = cat(2,idxCtl,idxPts{ptIdx(jj)}(ss{ptIdx(jj)}==0));
    end
    idx1 = [idxLeft,idxRight];
    var2plot = 100*y;
    contraVar = var2plot;
    if EPP
%         contraVar(idxRight,:) = -contraVar(idxRight,:);
    else
        contraVar(idxLeft,:) = 100-contraVar(idxLeft,:);
    end
    for jj = 1:length(desiredTm)
        tmIdx = find(desiredTm(jj)*60==tm);
        br(ii,jj) = mean(contraVar(idx1,tmIdx),1,'omitnan');
        legendLabels{jj} = ['t=',num2str(desiredTm(jj))];
    end
    x(ii) = mean(desiredIspta{ii});
    disp(['Ispta=', num2str(x(ii)), ': n=',num2str(length(idx1))])
    disp(['  Boltz: L=', num2str(length(intersect(bIdx,idxLeft))), ', R=', num2str(length(intersect(bIdx,idxRight)))])
    disp(['  Euler: L=', num2str(length(intersect(eIdx,idxLeft))), ', R=', num2str(length(intersect(eIdx,idxRight)))])


    h = figure;
    ax = gca;
    yLeft = mean(var2plot(idxLeft,:),1,'omitnan');
    yLeftSem = semOmitNan(var2plot(idxLeft,:),1);
    yRight = mean(var2plot(idxRight,:),1,'omitnan');
    yRightSem = semOmitNan(var2plot(idxRight,:),1);
    shadedErrorBar(tm/60,yLeft,yLeftSem,'lineprops',{'Color',ax.ColorOrder(1,:),'linewidth',2})
    hold on;
    shadedErrorBar(tm/60,yRight,yRightSem,'lineprops',{'Color',ax.ColorOrder(2,:),'linewidth',2})
    legend('Left','Right')
    xlabel('Time (minutes)')
    ylabel('Leftward Choices (%)')
    title(['Ispta = ', num2str(x(ii))])
    makeFigureBig(h);
    ax.XLim = [0,20];
end

h = figure;
ax = gca;
bar(x,br,'BaseValue',50);
xlabel('Ispta (W/cm^2)')
ylabel('Contralateral Choices (%)')
ax.XTick = x;
ax.XTickLabel = xLabel;
ax.XTickLabelRotation = 45;
legend(legendLabels);
makeFigureBig(h);

%% Bar plots as a function of intensity and month of the session
[day,fullDate] = getSessionDate(processedFiles);
day = day-min(day);
day = day/30;

desiredIspta = {[0,1]};
desiredTm = 5;
tmIdx = find(desiredTm == tm/60);
br = nan(max(floor(day)),length(desiredIspta));
legendLabels = cell(size(desiredIspta));
x = zeros(size(desiredIspta));
for ii = 1:floor(max(day))
    curMoIdx = find(day<ii&day>=ii-1);
    for jj = 1:length(desiredIspta)
        ptIdx = find(Ispta<=desiredIspta{jj}(2) & Ispta>desiredIspta{jj}(1));
        idxLeft = [];
        idxRight = [];
        idxCtl = [];
        for kk = 1:length(ptIdx)
            if monkS(ptIdx(kk))=='e'
                continue
            end
            idxLeft = cat(2,idxLeft,idxPts{ptIdx(kk)}(ss{ptIdx(kk)}==-1));
            idxRight = cat(2,idxRight,idxPts{ptIdx(kk)}(ss{ptIdx(kk)}==1));
            idxCtl = cat(2,idxCtl,idxPts{ptIdx(kk)}(ss{ptIdx(kk)}==0));
        end
        idxLeft = intersect(curMoIdx,idxLeft);
        idxRight= intersect(curMoIdx,idxRight);
        idx1 = [idxLeft,idxRight];
%         if length(idx1)<6
%             continue;
%         end
        var2plot = 100*y;
        contraVar = var2plot;
        if EPP
    %         contraVar(idxRight,:) = -contraVar(idxRight,:);
        else
            contraVar(idxLeft,:) = 100-contraVar(idxLeft,:);
        end
        x(jj) = mean(desiredIspta{jj});
        disp(['Month=', num2str(ii), ', Ispta=', num2str(x(jj)), ', : n=',num2str(length(idx1))])
        disp(['  Boltz: L=', num2str(length(intersect(bIdx,idxLeft))), ', R=', num2str(length(intersect(bIdx,idxRight)))])
        disp(['  Euler: L=', num2str(length(intersect(eIdx,idxLeft))), ', R=', num2str(length(intersect(eIdx,idxRight)))])
        br(ii,jj) = mean(contraVar(idx1,tmIdx),1,'omitnan');
        legendLabels{jj} = ['Ispta=', num2str(x(jj))];
    end
end

h = figure;
bar(1:max(floor(day)),br,'BaseValue',50)
legend(legendLabels);
xlabel('Month')
ylabel('Contralateral Choices (%)')
makeFigureBig(h)