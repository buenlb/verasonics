function makeEyeMovementAnimation(tData,svName)
%% Interpolate onto a uniform time sampling grid
fs = 1/10e-3;
tm1 = 0:1/fs:1;

tm = nan(length(tm1),length(tData.timing));

x = tm;
y = tm;
for ii = 1:length(tData.timing)
    curT = tData.timing(ii).eyeTm;
    curX = tData.timing(ii).eyePos(:,1);
    curY = tData.timing(ii).eyePos(:,2);
    
    curX = curX(curT>=tData.timing(ii).eventTimes(3));
    curY = curY(curT>=tData.timing(ii).eventTimes(3));
    curT = curT(curT>=tData.timing(ii).eventTimes(3));
    if length(curT)<10 || sum(isnan(curX)) == length(curX)
        continue
    end
    
    curT = curT-curT(1);

    tm(1:length(curT),ii) = curT;
    tx = interp1(curT,curX,tm1,'spline',curX(end));
    ty = interp1(curT,curY,tm1,'spline',curY(end));
    x(1:length(tx),ii) = tx;
    y(1:length(ty),ii) = ty;
end
%% Make Movie
lgn = tData.lgn;
h = figure;
wSize = 10;
for ii = 1:size(x,1)
    clf;
    ax = gca;
    plot(x(ii,lgn==-1),y(ii,lgn==-1),'*','markersize',8,'linewidth',2,'Color',ax.ColorOrder(1,:));
    hold on
    plot(x(ii,lgn==1),y(ii,lgn==1),'*','markersize',8,'linewidth',2,'Color',ax.ColorOrder(2,:));
    plot(mean(x(ii,lgn==-1),'omitnan'),mean(y(ii,lgn==-1),'omitnan'),'^','markersize',12,'linewidth',3,'Color',ax.ColorOrder(1,:));
    plot(mean(x(ii,lgn==1),'omitnan'),mean(y(ii,lgn==1),'omitnan'),'^','markersize',12,'linewidth',3,'Color',ax.ColorOrder(2,:));
    viscircles([0,0],tData.fpWindow,'Color',[0,0,0])
    axis('equal')
    axis([-1,1,-1,1]*wSize);
    text(-wSize+1,-wSize+1,['t=',num2str(tm1(ii))],'fontsize',18)
%     text(wSize-4,wSize-1,['right: ',num2str(sum(~isnan(x(ii,lgn==1))))])
%     text(wSize-4,wSize-3,['left: ',num2str(sum(~isnan(x(ii,lgn==-1))))])
    
     if tm1(ii) < 0.15
        fill([wSize/2,wSize/2+0.25*wSize,wSize/2+0.25*wSize,wSize/2],[-wSize+0.2*wSize,-wSize+0.2*wSize,-wSize+0.3*wSize,-wSize+0.3*wSize],'r')
        text(wSize/2,-wSize+0.25*wSize,'US ON')
        
        fill([wSize/2,wSize/2+0.25*wSize,wSize/2+0.25*wSize,wSize/2],[-wSize+0.1*wSize,-wSize+0.1*wSize,-wSize+0.2*wSize,-wSize+0.2*wSize],'g')
        text(wSize/2,-wSize+0.15*wSize,'FP ON')
    elseif tm1(ii) < 0.3
        fill([wSize/2,wSize/2+0.25*wSize,wSize/2+0.25*wSize,wSize/2],[-wSize+0.2*wSize,-wSize+0.2*wSize,-wSize+0.3*wSize,-wSize+0.3*wSize],'r')
        text(wSize/2,-wSize+0.25*wSize,'US ON')
     end
    drawnow
    if exist('svName','var')
        f(ii) = getframe(gca);
    end
end
if exist('svName','var')
    writerObj = VideoWriter(svName);
    writerObj.FrameRate = 5;
    % set the seconds per image
    % open the video writer
    open(writerObj);
    % write the frames to the video
    for i=1:length(f)
        % convert the image to a frame
        frame = f(i) ;    
        writeVideo(writerObj, frame);
    end
    % close the writer object
    close(writerObj);
end