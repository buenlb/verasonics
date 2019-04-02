function findCenter(lib,Tx,Grid)

Pos = getPositionerSettings(lib);

%% Find focal length (or approximate if flat Tx)
lambda = 1490000/(Tx.frequency*1e6); % wavelength in mm/s
if Tx.focalLength <= 0
    focus = Tx.diameter^2/(4*lambda);
else
    focus = Tx.focalLength;
end

movePositionerAbs(lib,Pos.Z.Axis,focus);

%% Use a rough 2-d scan to get in the right area
centered = 0;
count = 1;
while ~centered
    if count > 3
        disp('After three tries I haven''t found the center. Try again?')
        dec = input('(y/n)>','s');
        if dec ~= 'y'
            error('Terminated by user. Couldn''t find the center.')
        end
    end
    soniq2dScan(lib,[Pos.X.Axis,Pos.Y.Axis],[-10,-10],[10,10],ones(1,2)*ceil(21/lambda)+1)
    
    calllib(lib,'MoveTo2DScanPeak');

    if abs(getPosition(lib,Pos.X.Axis)) < 9 && abs(getPosition(lib,Pos.Y.Axis)) < 9
        centered = 1;
    end
    
    setPosition(lib,Pos.X.Axis,0);
    setPosition(lib,Pos.Y.Axis,0);
end

%% Find peak with finer 1D scans. Do it twice so that each is done at the others' max
for ii = 1:2
    % x
    soniq1dScan(lib,Pos.X.Axis,-5,5,4*ceil(11/lambda)+1,100);
    calllib(lib,'MoveTo1DScanPeak');

    % Make this the new zero position
    setPosition(lib,Pos.X.Axis,0);
    
    % y
    soniq1dScan(lib,Pos.Y.Axis,-5,5,4*ceil(11/lambda)+1,100);
    calllib(lib,'MoveTo1DScanPeak');

    % Make this the new zero position
    setPosition(lib,Pos.Y.Axis,0);
end

%% Find z-axis peak
% 1D scan with at leaset 2 points/wavelength
soniq1dScan(lib,Pos.Z.Axis,Grid.zStart,Grid.zEnd,4*ceil((Grid.zEnd-Grid.zStart)/lambda)+1,100);
calllib(lib,'MoveTo1DScanLAM');