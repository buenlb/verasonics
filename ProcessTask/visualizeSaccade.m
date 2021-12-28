%% Plot Average Sacades
% Set parameters for sessions and trials to include
passed = true(size(tData));
validDelays = 0;
threshold = 20;
task = 0;

desiredDuty = 100;
desiredFreq = 0.65;
desiredVoltage = 10.3;

dIdx = selectSessions(tData,threshold,validDelays,dc,freq,voltage,desiredDuty,desiredFreq,desiredVoltage,passed,task);


tData10 = combineSessions(dIdx,tData);
idxLeft = find(tData10.lgn==-1 & ~isnan(tData10.ch));
tData10 = selectTrials(tData10,idxLeft);
tData10.fpWindow = 3;
[tm,xLeft,yLeft] = plotEyeMovement(tData10,0);

tData10 = combineSessions(dIdx,tData);
idxRight = find(tData10.lgn==1 & ~isnan(tData10.ch));
tData10 = selectTrials(tData10,idxRight);
tData10.fpWindow = 3;
[~,xRight,yRight] = plotEyeMovement(tData10,0);

tData10 = combineSessions(dIdx,tData);
idx = find(tData10.lgn==0 & ~isnan(tData10.ch));
tData10 = selectTrials(tData10,idx);
tData10.fpWindow = 3;
[~,x,y] = plotEyeMovement(tData10,0);

%% Plot averages
xLeftA = mean(xLeft,2,'omitnan');
yLeftA = mean(yLeft,2,'omitnan');

xRightA = mean(xRight,2,'omitnan');
yRightA = mean(yRight,2,'omitnan');

xA = mean(x,2,'omitnan');
yA = mean(y,2,'omitnan');

h = figure;
makeFigureBig(h)
ax = gca;
wSize = 10;
for ii = 1:length(tm)
    ax.ColorOrderIndex = 1;
    plot(xLeftA(ii),yLeftA(ii),'^','markersize',12,'linewidth',2);
    hold on
    plot(xRightA(ii),yRightA(ii),'^','markersize',12,'linewidth',2);
    plot(xA(ii),yA(ii),'o','markersize',12,'linewidth',2);
    
    ax.ColorOrderIndex = 1;
    plot(xLeftA(1:ii),yLeftA(1:ii),'-','markersize',12,'linewidth',2);
    plot(xRightA(1:ii),yRightA(1:ii),'-','markersize',12,'linewidth',2);
    plot(xA(1:ii),yA(1:ii),'--','markersize',12,'linewidth',2);
    viscircles([0,0],tData10.fpWindow,'Color',[0,0,0])
    axis('equal')
    axis([-1,1,-1,1]*wSize);
    hold off
    title(['time = ',num2str(tm(ii)), 's'])
    legend('Left LGN','Right LGN','No US')
    drawnow;
    pause(0.1);
    frm(ii) = getframe(gca);
end

if exist('svName','var')
    writerObj = VideoWriter(svName);
    writerObj.FrameRate = 5;
    % set the seconds per image
    % open the video writer
    open(writerObj);
    % write the frames to the video
    for i=1:length(frm)
        % convert the image to a frame
        frame = frm(i) ;    
        writeVideo(writerObj, frame);
    end
    % close the writer object
    close(writerObj);
end
    