function [accuracy,slope,bias,downshift,scale,session] = safety(tData)

slope = zeros(size(tData));
bias = zeros(size(tData));
downshift = zeros(size(tData));
scale = zeros(size(tData));
session = zeros(size(tData));
accuracy = zeros(size(tData));
h = figure;
ax2 = gca;
idx = 1;
for ii = 1:length(tData)
    delay = tData(ii).delay(tData(ii).lgn==0);
    ch = tData(ii).ch(tData(ii).lgn==0);
    if length(ch)<250 || max(abs(delay))>100
        continue;
    end
    delay = delay(~isnan(ch));
    ch = ch(~isnan(ch));
    [slope(idx), bias(idx), downshift(idx), scale(idx)] = sigmoid_plot2(delay',ch',1:length(ch),ax2.ColorOrder(1,:),4);
    session(idx) = ii;
    
    result = tData(ii).result;
    accuracy(idx) = sum(result==1)/sum(result==1 | result==0);
    idx = idx+1;
end

slope = slope(1:idx-1);
bias = bias(1:idx-1);
downshift = downshift(1:idx-1);
scale = scale(1:idx-1);
session = session(1:idx-1);
accuracy = accuracy(1:idx-1);

sNumber = 1:(idx-1);

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

lm = fitlm(sNumber',slope');
p = coefTest(lm);
x = coefCI(lm,1);
x = x(:,1);
yHat = x(1)+x(2)*sNumber;

h = figure;
ax = gca;
plot(sNumber,slope,'kx','markersize',6,'linewidth',0.5);
hold on
ax.ColorOrderIndex = 1;
plot(sNumber,yHat,'k--','linewidth',2)
xlabel('Session Number')
ylabel('Slope')
axis('tight')
h.Position = [680   746   560   232];
makeFigureBig(h);

lm = fitlm(sNumber',100*accuracy');
[p,~,r] = coefTest(lm);
x = coefCI(lm,1);
x = x(:,1);
yHat = x(1)+x(2)*sNumber;

h = figure;
ax = gca;
plot(sNumber,100*accuracy,'kx','markersize',6,'linewidth',0.5);
hold on
ax.ColorOrderIndex = 1;
plot(sNumber,yHat,'k--','linewidth',2)
xlabel('Session Number')
ylabel('Accuracy (%)')
axis([1,length(accuracy),80,100])
h.Position = [680   746   560   232];
text(20,81,['p=',num2str(p),',r=',num2str(lm.Rsquared.Ordinary)]);
makeFigureBig(h);



