% closest Skull Interface plots the location of the closest skull interface
% based on the arrival time of an echo for each element. Broken elements
% are grayed out and if the difference in arrival times for adjoining
% elements suggests more than a 1 mm difference a the channel is shown in
% red.
% 
% @INPUTS
%   tArr: 256 element vector of arrival times. NaN indicates a broken
%       element. Times should be in microseconds.
% 
% @OUTPUTS
%   None, data is displayed graphically.
% 
% Taylor Webb
% University of Utah
% February 2020

function closestSkullInterface(tArr)

dist = tArr*1.492/2;

nSubplots = 4;
chPerPlot = 256/nSubplots;

if mod(256,nSubplots)
    error('256/nSubplots must be an integer')
end

% Create an element ordering such that the elements are always adjacent
elementOrder = zeros(1,256);
for ii = 1:32
    if mod(ii,2)
        elementOrder(((ii-1)*8+1):ii*8) = ((ii-1)*8+1):ii*8;
    else
        elementOrder(((ii-1)*8+1):ii*8) = ii*8:-1:((ii-1)*8+1);
    end
end

dist = dist(elementOrder);
deltaDist = diff(dist);

h = figure;
set(h,'Position', [1, 41, 1920, 1083]);
label = cell(1,chPerPlot);
for ii = 1:nSubplots
    subplot(1,nSubplots,ii)
    hold on;
    ax = gca;
    yTick = ((ii-1)*chPerPlot+1):(ii*chPerPlot);
    for jj = 1:chPerPlot
        curIdx = jj+(ii-1)*chPerPlot;
        plot([dist(curIdx),dist(curIdx)],[curIdx+0.5,curIdx-0.5],...
            '-', 'linewidth', 2)
        ax.ColorOrderIndex = 1;
        
        if isnan(dist(curIdx))
            X = [min(dist(yTick)),min(dist(yTick)),max(dist(yTick)),max(dist(yTick))];
            Y = [curIdx+0.5,curIdx-0.5,curIdx-0.5,curIdx+0.5];
            sqr = fill(X,Y,[0.94,0.94,0.94]);
            ax.ColorOrderIndex = 1;
            sqr.FaceAlpha = 1;
            sqr.EdgeAlpha = 0;
        end
        maxDistance = 2;
        if curIdx == 256
            if abs(deltaDist(curIdx-1))>maxDistance
                X = [min(dist(yTick)),min(dist(yTick)),max(dist(yTick)),max(dist(yTick))];
                Y = [curIdx+0.5,curIdx-0.5,curIdx-0.5,curIdx+0.5];
                sqr = fill(X,Y,'r');
                sqr.FaceAlpha = 0.25;
                sqr.EdgeAlpha = 0;
            end
        elseif curIdx == 1
            if abs(deltaDist(curIdx))>maxDistance
                X = [min(dist(yTick)),min(dist(yTick)),max(dist(yTick)),max(dist(yTick))];
                Y = [curIdx+0.5,curIdx-0.5,curIdx-0.5,curIdx+0.5];
                sqr = fill(X,Y,'r');
                sqr.FaceAlpha = 0.25;
                sqr.EdgeAlpha = 0;
            end
        else
            if abs(deltaDist(curIdx))>maxDistance || abs(deltaDist(curIdx-1))>maxDistance
                X = [min(dist(yTick)),min(dist(yTick)),max(dist(yTick)),max(dist(yTick))];
                Y = [curIdx+0.5,curIdx-0.5,curIdx-0.5,curIdx+0.5];
                sqr = fill(X,Y,'r');
                sqr.FaceAlpha = 0.25;
                sqr.EdgeAlpha = 0;
            end
        end
        
        label{jj} = ['Channel ', num2str(elementOrder(curIdx))];
    end
    ax.YTick = yTick;
    axis([min(dist(ax.YTick))-0.5,max(dist(ax.YTick))+0.5,((ii-1)*chPerPlot+1),(ii*chPerPlot+1)])
    ax.YTickLabel = label;
end    