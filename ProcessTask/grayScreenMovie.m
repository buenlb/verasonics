for ii = 1:length(xRight{1})
    for jj = 1:length(xRight)
        try
            xR(ii,jj) = xRight{jj}(ii);
            yR(ii,jj) = yRight{jj}(ii);
        catch
            xR(ii,jj) = nan;
            yR(ii,jj) = nan;
        end
    end
end

%%
% h = figure;
% clf
% for ii = 1:size(x,1)
%     curX = mean(x,2,'omitnan');
%     curY = mean(y,2,'omitnan');
%     
%     plot(curX(ii),curY(ii),'*')
%     axis([-5,5,-5,5])
%     drawnow
%     pause(0.2)
% 
% end
%%
for ii = 1:length(xLeft{1})
    for jj = 1:length(xLeft)
        try
            x(ii,jj) = xLeft{jj}(ii);
            y(ii,jj) = yLeft{jj}(ii);
        catch
            x(ii,jj) = nan;
            y(ii,jj) = nan;
        end
    end
end

%%
h = figure;
clf
t = eyeTmAll{8};
for ii = 1:min([size(x,1),size(xR,1)])
%     curXL = mean(x,2,'omitnan');
%     curYL = mean(y,2,'omitnan');
%     
%     curXR = mean(xR,2,'omitnan');
%     curYR = mean(yR,2,'omitnan');
figure(h)
clf
    
    curXL = x(ii,:);
    curYL = y(ii,:);
    
    curXR = xR(ii,:);
    curYR = yR(ii,:);

    plot(curXL,curYL,'b*',curXR,curYR,'r*','markersize',4,'linewidth',1)
    hold on
    plot(mean(curXL,'omitnan'),mean(curYL,'omitnan'),'b^',mean(curXR,'omitnan'),mean(curYR,'omitnan'),'r^','markersize',8,'linewidth',6)
    if t(ii) < 0.15
        fill([4.5,8.5,8.5,4.5],[-8,-8,-9,-9],'r')
        text(5,-8.5,'US ON')
        
        fill([4.5,8.5,8.5,4.5],[-9,-9,-10,-10],'g')
        text(5,-9.5,'FP ON')
    elseif t(ii) < 0.3
        fill([4.5,8.5,8.5,4.5],[-8,-8,-9,-9],'r')
        text(5,-8.5,'US ON')
    end
    
    text(-4,-8,['t=',num2str(1e3*t(ii),3),'ms'])
    
    axis([-1,1,-1,1]*20)
    legend('Left','Right');
    grid on
    makeFigureBig(h);
    f(ii) = getframe(gca);
    drawnow
    pause(0.2)    
end

%%
writerObj = VideoWriter('myVideo.avi');
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