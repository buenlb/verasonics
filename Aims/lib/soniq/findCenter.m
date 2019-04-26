function Grid = findCenter(lib,Tx,Grid)

Pos = getPositionerSettings(lib);

%% Find focal length (or approximate if flat Tx)
lambda = 1490000/(Tx.frequency*1e6); % wavelength in mm
if Tx.focalLength <= 0
    focus = Tx.diameter^2/(2*lambda);
else
    focus = Tx.focalLength;
end

if withinLimits(lib,Pos.Z.Axis,focus)
    movePositionerAbs(lib,Pos.Z.Axis,focus);
else
    movePositionerAbs(lib,Pos.Z.Axis,Pos.Z.lowLimit+0.1)
end

%% Use a rough 2-d scan to get in the right area
centered = 1;
count = 1;
while ~centered
    if count > 3
        disp('After three tries I haven''t found the center. Try again?')
        dec = input('(y/n)>','s');
        if dec ~= 'y'
            error('Terminated by user. Couldn''t find the center.')
        end
    end
    soniq2dScan(lib,[Pos.X.Axis,Pos.Y.Axis],[-5,-5],[5,5],0.5*ones(1,2)*ceil(11/lambda)+1,{'parameter',Grid.parameters})
    
    calllib(lib,'MoveTo2DScanPeak');

    if abs(getPosition(lib,Pos.X.Axis)) < 9 && abs(getPosition(lib,Pos.Y.Axis)) < 9
        centered = 1;
    end
    
    setPosition(lib,Pos.X.Axis,0);
    setPosition(lib,Pos.Y.Axis,0);
end

%% Find peak with finer 1D scans. Do it twice so that each is done at the others' max
for ii = 1:3
    % x
    limit = 10*lambda;
    if limit > 5
        limit = 5;
    end
    soniq1dScan(lib,Pos.X.Axis,-limit,limit,4*ceil(2*limit/lambda)+1,{'parameter',Grid.parameters,...
        'pause',100});
    calllib(lib,'MoveTo1DScanPeak');

    % Make this the new zero position
    setPosition(lib,Pos.X.Axis,0);
    
    % y
    soniq1dScan(lib,Pos.Y.Axis,-limit,limit,4*ceil(2*limit/lambda)+1,{'parameter',Grid.parameters,...
        'pause',100});
    calllib(lib,'MoveTo1DScanPeak');

    % Make this the new zero position
    setPosition(lib,Pos.Y.Axis,0);
end

%% Find z-axis peak
% 1D scan with at least 2 points/wavelength
soniq1dScan(lib,Pos.Z.Axis,Grid.zStart,Grid.zEnd,4*ceil((Grid.zEnd-Grid.zStart)/lambda)+1,...
    {'parameter',Grid.parameters,'pause',100});
calllib(lib,'MoveTo1DScanPeak');