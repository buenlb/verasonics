function plt = plotSigmoid(tData,idx,h)

if ~exist('h','var')
    h = figure;
else
    figure(h);
end

delay = tData.delay(idx);
delays = unique(delay);
ch = tData.ch(idx);

[slope, bias, downshift, scale] = fitSigmoid(delay,ch);

x = linspace(min(delay),max(delay),1e2);
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