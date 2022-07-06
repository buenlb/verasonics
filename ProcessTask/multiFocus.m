clear; close all; clc;
%% Process sessions with multiple focal spots
tData(1) = processTaskData('D:\Task\Boltz\multiFocus\boltzmann20220406.mat');
tData(2) = processTaskData('D:\Task\Boltz\multiFocus\boltzmann20220411.mat');
tData(3) = processTaskData('D:\Task\Boltz\multiFocus\boltzmann20220413.mat');

tData(4) = processTaskData('D:\Task\Boltz\multiFocus\boltzmann20220405.mat');

%% Find sigmoids
clear yImgLeft pImgLeft yImgRight pImgRight

for hh = 1:length(tData)
    % Control
    targIdx = [tData(hh).targIdx];
    lgn = [tData(hh).lgn];

    h = figure;
    ax = gca;
    idx = find(lgn == 0);
    idx = idx(~isnan(tData(hh).ch(idx)));
    [plt,slope,bias,downshift,scale] = plotSigmoid(tData(hh),idx,h);
    x0 = equalProbabilityPoint(slope,bias,downshift,scale);
    length(idx)
    
    % Left
    zIdx = unique(tData(hh).leftLocation(1,:,3));
    yIdx = unique(tData(hh).leftLocation(1,:,2));
    xIdx = unique(tData(hh).leftLocation(1,:,1));
    yImgLeft{hh} = zeros(length(xIdx),length(yIdx),length(zIdx));
    pImgLeft{hh} = yImgLeft{hh};
    zeroChLeft{hh} = yImgLeft{hh};
    
    yLeft = zeros(1,length(unique(targIdx)));
    pLeft = yLeft;
    for ii = 1:size(tData(hh).leftLocation,2)
        idx = find(targIdx==ii & lgn < 0);
        idx = idx(~isnan(tData(hh).ch(idx)));
        ax.ColorOrderIndex = 2;
        [plt,slope,bias,downshift,scale] = plotSigmoid(tData(hh),idx,h);
        yLeft(ii) = sigmoid_ext(x0,slope,bias,downshift,scale);
        pLeft(ii) = equalProbabilityPoint(slope,bias,downshift,scale);
        a = find(xIdx == sort(squeeze(tData(hh).leftLocation(1,ii,1))));
        b = find(yIdx == sort(squeeze(tData(hh).leftLocation(1,ii,2))));
        c = find(zIdx == sort(squeeze(tData(hh).leftLocation(1,ii,3))));
        yImgLeft{hh}(a,b,c) = yLeft(ii);
        pImgLeft{hh}(a,b,c) = pLeft(ii);
        zDelayIdx = idx(tData(hh).delay(idx)==0);
        zeroChLeft{hh}(a,b,c) = mean(tData(hh).ch(zDelayIdx),'omitnan');
        title('Left')
        nTrialsLeft(ii) = length(idx);
    end
    
    % Right
    zIdx = unique(tData(hh).rightLocation(1,:,3));
    yIdx = unique(tData(hh).rightLocation(1,:,2));
    xIdx = unique(tData(hh).rightLocation(1,:,1));
    yImgRight{hh} = zeros(length(xIdx),length(yIdx),length(zIdx));
    pImgRight{hh} = yImgRight{hh};
    zeroChRight{hh} = yImgRight{hh};
    
    yRight = zeros(1,length(unique(targIdx)));
    pRight = yRight;
    for ii = 1:size(tData(hh).rightLocation,2)
        idx = find(targIdx==ii & lgn > 0);
        idx = idx(~isnan(tData(hh).ch(idx)));
        ax.ColorOrderIndex = 3;
        [plt,slope,bias,downshift,scale] = plotSigmoid(tData(hh),idx,h);
        yRight(ii) = sigmoid_ext(x0,slope,bias,downshift,scale);
        pRight(ii) = equalProbabilityPoint(slope,bias,downshift,scale);
        a = find(xIdx == sort(squeeze(tData(hh).rightLocation(1,ii,1))));
        b = find(yIdx == sort(squeeze(tData(hh).rightLocation(1,ii,2))));
        c = find(zIdx == sort(squeeze(tData(hh).rightLocation(1,ii,3))));
        if a == 1 && b == 1 && c == 1
            keyboard
        end
        yImgRight{hh}(a,b,c) = yRight(ii);
        pImgRight{hh}(a,b,c) = pRight(ii);
        zDelayIdx = idx(tData(hh).delay(idx)==0);
        zeroChRight{hh}(a,b,c) = mean(tData(hh).ch(zDelayIdx),'omitnan');
        title('Right')
        nTrialsRight(ii) = length(idx);
    end
    rng = [0.45 0.55];
    h2 = figure;
    subplot(221)
    imagesc(squeeze(yImgLeft{hh})',rng)
    title('Left Y');
    colorbar
    
    subplot(223)
    imagesc(squeeze(pImgLeft{hh})',[min(tData(hh).delay),max(tData(hh).delay)])
    title('Left P0');
    colorbar
    
    subplot(222)
    imagesc(squeeze(yImgRight{hh})',rng)
    title('Right Y');
    colorbar
    
    subplot(224)
    imagesc(squeeze(pImgRight{hh})',[min(tData(hh).delay),max(tData(hh).delay)])
    title('Right P0');
    colorbar
end
%%
yLeft = zeros(cat(2,size(yImgLeft{1}),length(tData)));
yRight = zeros(cat(2,size(yImgRight{1}),length(tData)));
for ii = 1:length(yImgLeft)
    yLeft(:,:,:,ii) = yImgLeft{ii};
    yRight(:,:,:,ii) = yImgRight{ii};
end

yLeftM = mean(squeeze(yLeft),3);
yRightM = mean(squeeze(yRight),3);

yLeftM(yLeftM==0) = nan;
yRightM(yRightM==0) = nan;

yLeftStd = std(squeeze(yLeft),[],3);
yRightStd = std(squeeze(yRight),[],3);

rng = [0 1];
h2 = figure;
subplot(211)
imagesc(squeeze(yLeftM)',rng)
title('Left Y');
colorbar

subplot(212)
imagesc(squeeze(yRightM)',rng)
title('Right Y');
colorbar

yLeft = squeeze(yLeft);
yRight = squeeze(yRight);

for ii = 1:size(yLeft,1)
    for jj = 1:size(yLeft,2)
        [~,p(ii,jj)] = ttest2(yLeft(ii,jj,:),yRight(ii,jj,:));
    end
end

[~,leftIdx] = max(yLeftM(:));
[~,rightIdx] = min(yRightM(:));

h = figure;
ax = gca;
bar(1,100*yLeftM(leftIdx),'BaseValue',50);
hold on
bar(2,100*yRightM(rightIdx),'BaseValue',50);
ax.ColorOrderIndex = 1;
eb = errorbar(1,100*yLeftM(leftIdx),100*yLeftStd(leftIdx)/sqrt(length(tData)));
set(eb,'LineStyle','none','LineWidth',2)
eb = errorbar(2,100*yRightM(rightIdx),100*yRightStd(rightIdx)/sqrt(length(tData)));
set(eb,'LineStyle','none','LineWidth',2)
xticks(1:2);
xticklabels({'Left','Right'})
xtickangle(90)
ylabel('Leftward Choices (%)')
makeFigureBig(h)

h = figure;
ax = gca;
bar(1,100*mean(yLeftM(:),'omitnan'),'BaseValue',50);
hold on
bar(2,100*mean(yRightM(:),'omitnan'),'BaseValue',50);
ax.ColorOrderIndex = 1;
xticks(1:2);
xticklabels({'Left','Right'})
xtickangle(90)
ylabel('Leftward Choices (%)')
axis([0,3,25,75])
makeFigureBig(h)