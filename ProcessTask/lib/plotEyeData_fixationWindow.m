% Plots the fixation window
% 
% I HAVEN"T USED THIS IN A WHILE. MAY BE OUT OF DATE. DON"T TRUST UNLESS
% YOU HAVE CAREFULLY REVIEWD

function ax = plotEyeData_fixationWindow(tData,ax)

if nargin<2
    figure;
    ax = gca;
end
axes(ax);
hold on;

viscircles([0,0],tData.fpWindow);

lgn = tData.lgn;
for ii = 1:length(tData.timing)
    time1 = tData.timing(ii).eventTimes(2);
    time2 = tData.timing(ii).eventTimes(6);
    
    if isnan(time1) || isnan(time2)
        continue
    end
    
    ax.ColorOrderIndex = 1;
    tm = tData.timing(ii).eyeTm;
    fxIdx = find(tm>time1 & tm < time2);
    chIdx1 = fxIdx(end);
    fxIdx = fxIdx(1:end-1);
    if isnan(chIdx1)
        keyboard
    end
    chIdx = find(tm >= time2);
    if lgn(ii)==1
        clr = ax.ColorOrder(2,:);
    else
        clr = ax.ColorOrder(1,:);
    end
    
    plot(tData.timing(ii).eyePos(chIdx1,1),tData.timing(ii).eyePos(chIdx1,2),'*',...
        tData.timing(ii).eyePos(chIdx,1),tData.timing(ii).eyePos(chIdx,2),'^','Color',clr)
    axis([-10,10,-10,10])
end
