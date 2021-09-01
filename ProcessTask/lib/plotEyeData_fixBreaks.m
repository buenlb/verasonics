% Plots the fixation window

function ax = plotEyeData_fixBreaks(tData,ax)

if nargin<2
    figure;
    ax = gca;
end
axes(ax);
hold on;

viscircles([0,0],tData.fpWindow);
for ii = 1:length(tData.timing)
    time1 = tData.timing(ii).eventTimes(2);
    result = tData.result(ii);
    if isnan(time1) || result < 2
        continue
    end
    
    ax.ColorOrderIndex = 1;
    tm = tData.timing(ii).eyeTm;
    fxIdx = find(tm<time1);
    postBreakIdx = find(tm>=time1);
    plot(tData.timing(ii).eyePos(fxIdx,1),tData.timing(ii).eyePos(fxIdx,2),'*',...
        tData.timing(ii).eyePos(postBreakIdx,1),tData.timing(ii).eyePos(postBreakIdx,2),'*')
    axis([-10,10,-10,10])
end
