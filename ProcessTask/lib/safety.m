function [accuracy,slope,bias,downshift,scale,session,changeIdx,shortDelayIdx] = safety(tData,date)

%% Set up x-axis
found = 0;
day = zeros(size(tData));
for ii = 1:length(date)
    for jj = 1:length(date{ii})
        if ~isnan(str2double(date{ii}(jj))) && isreal(str2double(date{ii}(jj)))
            curYear = str2double(date{ii}(jj:(jj+3)));
            curMonth = str2double(date{ii}((jj+4):(jj+5)));
            curDay = str2double(date{ii}((jj+6):(jj+7)));
            found = 1;
            break;
        end
    end
    if ~found
        keyboard
    end
    found = 0;
    day(ii) = date2day(curYear,curMonth,curDay);
end
day = day-day(1);

slope = zeros(size(tData));
bias = zeros(size(tData));
downshift = zeros(size(tData));
scale = zeros(size(tData));
session = zeros(size(tData));
accuracy = zeros(size(tData));
h = figure;
ax2 = gca;
idx = 1;
notFound = 1;
notFoundTiming = 1;
for ii = 1:length(tData)
    delay = tData(ii).delay(tData(ii).lgn==0 & tData(ii).task==0);
    if notFoundTiming && min(abs(delay(abs(delay)>0))) < 10 && ii == 1
        notFoundTiming = false;
    elseif notFoundTiming && min(abs(delay(abs(delay)>0))) < 10
        notFoundTiming = false;
        shortDelayIdx = idx;
    end
    ch = tData(ii).ch(tData(ii).lgn==0 & tData(ii).task==0);
    if length(ch)<250 || max(abs(delay))>100
        accuracy(idx) = nan;
        session(idx) = nan;
        idx = idx+1;
        continue;
    end
    delay = delay(~isnan(ch));
    ch = ch(~isnan(ch));
    [slope(idx), bias(idx), downshift(idx), scale(idx)] = sigmoid_plot2(delay',ch',1:length(ch),ax2.ColorOrder(1,:),4);
    session(idx) = ii;
    
    result = tData(ii).result;
    accuracy(idx) = sum(result==1)/sum(result==1 | result==0);
    if notFound && length(unique(tData(ii).task))>1
        changeIdx = idx;
        notFound = false;
    end
    idx = idx+1;
end

slope = slope(1:idx-1);
bias = bias(1:idx-1);
downshift = downshift(1:idx-1);
scale = scale(1:idx-1);
session = session(1:idx-1);
accuracy = accuracy(1:idx-1);

if exist('day','var')
    sNumber = day;
else
    sNumber = 1:(idx-1);
end

h = figure;
subplot(411)
plot(sNumber, slope,'linewidth',2);
title('Slope')
makeFigureBig(h)

subplot(412)
plot(sNumber,bias,'linewidth',2);
title('Bias')
makeFigureBig(h)

subplot(413)
plot(sNumber,downshift,'linewidth',2);
title('Downshift')
makeFigureBig(h)

subplot(414)
plot(sNumber,scale,'linewidth',2);
xlabel('Session Number')
title('Scale')
makeFigureBig(h)

h = figure;
ax = gca;
plot(sNumber,slope,'kx','markersize',6,'linewidth',0.5);
hold on
ax.ColorOrderIndex = 1;

if exist('shortDelayIdx','var')
    lm1 = fitlm(sNumber(1:shortDelayIdx-1)',slope(1:shortDelayIdx-1)');
    p1 = coefTest(lm1);
    x1 = coefCI(lm1,1);
    x1 = x1(:,1);
    yHat1 = x1(1)+x1(2)*sNumber(1:shortDelayIdx-1);

    lm2 = fitlm(sNumber(shortDelayIdx:end)',slope(shortDelayIdx:end)');
    p2 = coefTest(lm2);
    x2 = coefCI(lm2,1);
    x2 = x2(:,1);
    yHat2 = x2(1)+x2(2)*sNumber(shortDelayIdx:end);

    plot(sNumber(1:shortDelayIdx-1),yHat1,'k--','linewidth',2)
    plot(sNumber(shortDelayIdx:end),yHat2,'k--','linewidth',2)
else
    lm = fitlm(sNumber',slope');
    p = coefTest(lm);
    x = coefCI(lm,1);
    x = x(:,1);
    yHat = x(1)+x(2)*sNumber;
    plot(sNumber,yHat,'k--','linewidth',2)
end
xlabel('Session Number')
ylabel('Slope')
axis('tight')
h.Position = [680   746   560   232];
makeFigureBig(h);

h = figure;
ax = gca;
plot(sNumber,100*accuracy,'kx','markersize',6,'linewidth',0.5);
hold on
if exist('changeIdx','var') && exist('shortDelayIdx','var')
%     plt = plot([changeIdx,changeIdx],[min(accuracy),100],'b--',[shortDelayIdx,shortDelayIdx],[min(accuracy),100],'r--');
    plt = plot([sNumber(shortDelayIdx),sNumber(shortDelayIdx)],[min(accuracy),100],'r--');
else
    changeIdx = nan;
    shortDelayIdx = nan;
end
ax.ColorOrderIndex = 1;

if exist('shortDelayIdx','var')
    lm1 = fitlm(sNumber(1:shortDelayIdx-1)',100*accuracy(1:shortDelayIdx-1)');
    p1 = coefTest(lm1);
    x1 = coefCI(lm1,1);
    x1 = x1(:,1);
    yHat1 = x1(1)+x1(2)*sNumber(1:shortDelayIdx-1);

    lm2 = fitlm(sNumber(shortDelayIdx:end)',100*accuracy(shortDelayIdx:end)');
    p2 = coefTest(lm2);
    x2 = coefCI(lm2,1);
    x2 = x2(:,1);
    yHat2 = x2(1)+x2(2)*sNumber(shortDelayIdx:end);

    plot(sNumber(1:shortDelayIdx-1),yHat1,'k--','linewidth',2)
    plot(sNumber(shortDelayIdx:end),yHat2,'k--','linewidth',2)

%     text(20,71,['p=',num2str(p1),',r=',num2str(lm1.Rsquared.Ordinary)]);
%     text(61,61,['p=',num2str(p2),',r=',num2str(lm2.Rsquared.Ordinary)]);
    disp(['P1: ', num2str(p1,2), ', R1: ', num2str(lm1.Rsquared.Ordinary)])
    disp(['P2: ', num2str(p2,2), ', R1: ', num2str(lm2.Rsquared.Ordinary)])
else
    lm = fitlm(sNumber',100*accuracy');
    [p,~,r] = coefTest(lm);
    x = coefCI(lm,1);
    x = x(:,1);
    yHat = x(1)+x(2)*sNumber;
    plot(sNumber,yHat,'k--','linewidth',2)
    text(20,81,['p=',num2str(p),',r=',num2str(lm.Rsquared.Ordinary)]);
end

xlabel('Days')
ylabel('Accuracy (%)')
axis([0,max(sNumber),75,100])
if ~isnan(changeIdx)
%     legend(plt,'Introduced Brightness','Shorter Delays');
end
h.Position = [680   746   560   232];
makeFigureBig(h);
ax.YLim = [70,100];