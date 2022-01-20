function plt = plotSigmoid(tData,idx,h)

if length(tData)>1
    delay = [];
    ch = [];
    for ii = 1:length(tData)
        try
            delay = cat(1,delay,tData(ii).delay(idx));
            ch = cat(1,ch,tData(ii).ch(idx));
        catch
            delay = cat(1,delay,nan(size(idx)));
            ch= cat(1,ch,nan(size(idx)));
        end
    end
else
    delay = tData.delay(idx);
    ch = tData.ch(idx);
end

delays = unique(delay(~isnan(delay)));

if isempty(delays)
    return;
end

if ~exist('h','var')
    h = figure;
else
    figure(h);
end

[slope, bias, downshift, scale] = fitSigmoid(delay,ch);
x = linspace(min(delays),max(delays),1e2);
y = sigmoid_ext(x,slope,bias,downshift,scale);

yD = zeros(size(delays));
yStd = zeros(size(delays));
for ii = 1:length(delays)
    yD(ii) = mean(ch(delay==delays(ii)));
    yStd(ii) = std(ch(delay==delays(ii)))/sqrt(sum(delay==delays(ii)));
end

ax = gca;
c = ax.ColorOrderIndex;
plt(1) = plot(x,y,'linewidth',2);
hold on
ax.ColorOrderIndex = c;
plt(2) = errorbar(delays,yD,yStd,'.','MarkerSize',28,'LineWidth',2);
xlabel('Delays (ms)')
ylabel('Fraction Leftward Choices')
axis([min(delays),max(delays),0,1])
makeFigureBig(h);