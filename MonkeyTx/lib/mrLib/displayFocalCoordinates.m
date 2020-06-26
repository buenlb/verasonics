function displayFocalCoordinates(sys)
focalSpot = sys.focalSpot;
disp(['Selected Focal Spot (Tx Coordinates): <', num2str(focalSpot(1),2), ', ',...
    num2str(focalSpot(2),2), ', ', num2str(focalSpot(3),2), '>'])

if sys.focalSpotMr(1) > 0
    xLabel = 'left';
else
    xLabel = 'right';
end

if sys.focalSpotMr(2) > 0
    yLabel = 'head';
else
    yLabel = 'foot';
end

if sys.focalSpotMr(1) > 0
    zLabel = 'posterior';
else
    zLabel = 'anterior';
end

disp(['Selected Focal Spot (Mr Coordinates): <' num2str(sys.focalSpotMr(1),3), 'mm ', xLabel,...
    ', ', num2str(sys.focalSpotMr(2),3), 'mm ', yLabel,...
    ', ', num2str(sys.focalSpotMr(3),3), 'mm ', zLabel])