[time,p50,zDel] = behaviorOverTime(tData,0,'Both',50,45);
[timeLeft,p50Left,zDelLeft] = behaviorOverTime(tData,-1,'Both',10,8);
[timeRight,p50Right,zDelRight] = behaviorOverTime(tData,1,'Both',10,8);
%%

passed = true(size(tData));
validDelays = 0;
threshold = 20;
task = 0;

desiredDuty = 10;
desiredFreq = 0.65;
desiredVoltage = 15;
idx10 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,desiredDuty,desiredFreq,desiredVoltage,passed,task);

desiredDuty = 100;
idx100 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,desiredDuty,desiredFreq,desiredVoltage,passed,task);

matSize = zeros(size(p50));
matSizeLeft = zeros(size(p50Left));
matSizeRight = zeros(size(p50Left));
for ii = 1:length(p50Left)
    matSizeLeft(ii) = length(p50Left{ii});
    matSizeRight(ii) = length(p50Right{ii});
    matSize(ii) = length(p50{ii});
end
p50LeftMat = nan(length(p50Left),max(matSizeLeft));
p50RightMat = nan(length(p50Right),max(matSizeRight));
p50Mat = nan(length(p50),max(matSize));

[~,maxIdxLeft] = max(matSizeLeft);
[~,maxIdxRight] = max(matSizeRight);
[~,maxIdx] = max(matSize);
for ii = 1:length(p50Left)
    p50LeftMat(ii,1:length(p50Left{ii})) = p50Left{ii};
    p50RightMat(ii,1:length(p50Right{ii})) = p50Right{ii};
    p50Mat(ii,1:length(p50{ii})) = p50{ii};
end

h = figure;
plot(timeLeft{maxIdxLeft}/60,smooth(mean(p50LeftMat(idx10,:),1,'omitnan'),5),'linewidth',2);
hold on
plot(timeRight{maxIdxRight}/60,smooth(mean(p50RightMat(idx10,:),1,'omitnan'),5),'linewidth',2);
plot(time{maxIdx}/60,smooth(mean(p50Mat(idx10,:),1,'omitnan'),5),'linewidth',2);
xlabel('time (minutes)')
ylabel('Delay of equal probability (ms)')
legend('Left LGN','Right LGN','No US')
title('10% Duty')
% axis([0,100,0,1])
axis([0,100,-10,50])
makeFigureBig(h);

h = figure;
plot(timeLeft{maxIdxLeft}/60,smooth(mean(p50LeftMat(idx100,:),1,'omitnan'),5),'linewidth',2);
hold on
plot(timeRight{maxIdxRight}/60,smooth(mean(p50RightMat(idx100,:),1,'omitnan'),5),'linewidth',2);
plot(time{maxIdx}/60,smooth(mean(p50Mat(idx100,:),1,'omitnan'),5),'linewidth',2);
xlabel('time (minutes)')
ylabel('Delay of equal probability (ms)')
legend('Left LGN','Right LGN','No US')
title('100% Duty')
% axis([0,100,0,1])
axis([0,100,-10,50])
makeFigureBig(h);

%% Individual Sessions
h1 = figure;
hold on

h2 = figure;
hold on
for ii = 1:length(time)
    if ~length(tData(ii).delayVector)<5        
        figure(h1);
        plot(time{ii}/60,p50{ii},'linewidth',2)
    else
        disp(['Skipping ', num2str(ii)])
    end
    
    figure(h2);
    plot(time{ii}/60,zDel{ii},'linewidth',2)
end

figure(h1)
title('Equal Delay Point')
ylabel('Point of Equal Delay (ms)')
xlabel('Time (minutes)')
axis([0,80,-50,50])
makeFigureBig(h2)

figure(h2)
title('0 Delay')
ylabel('Leftward Choices (%)')
xlabel('Time (minutes)')
makeFigureBig(h2)