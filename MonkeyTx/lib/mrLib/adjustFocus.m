function adjustFocus(sys,newFocus)
focalSpotIdx = newFocus;
focalSpot = ([x(focalSpotIdx(1)),y(focalSpotIdx(2)),z(focalSpotIdx(3))])*1e3;

sys.focalSpot = focalSpot;
sys.focalSpotIdx = focalSpotIdx;
sys.focalSpotMr = [sys.ax(focalSpotIdx(1)), sys.ay(focalSpotIdx(2)), sys.az(focalSpotIdx(3))]*1e3;

%% Print result in both Tx and MR coordinates
displayFocalCoordinates(sys);