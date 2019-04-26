% circularScan does a soniq acquisition using the angular position in a
% circle. The center of the circle is always assumed to be the origin since
% it is assumed that this is where the hydrophone is located.
% 
% IMPORTANT: The code assumes that the angular positioner has been placed
% such that the angular arm sweeps along the left/right axis.
% 
% @INPUTS
%   lib: alias for soniq DLL
%   axis: the linear axes on which the scan is to be performed (the second
%       axis is always assumed to be the z-axis).
%   radius: radius of the desired circle
%   range: angular range to cover (in radians). Currently, range is always
%       centered around the z axis.
%   steps: number of steps to take
%   pauseLength: length to wait after motion before acquiring data (ms)
% 
% @OUTPUTS
%   pnv: peak negative voltage at each theta
%   theta: angles that were scanned
% 
% Taylor Webb
% University of Utah

function [pnv, theta] = circularScan(lib,axis,radius,range,steps,saveLocation,pauseLength)

if nargin < 7
    pauseLength = 10;
end

if ~isSoniqConnected(lib)
    error('There isn''t a current connection to the Soniq software!')
end

Pos = getPositionerSettings(lib);

if axis == 0
    error('Haven''t implemented a circle along this axis yet!')
    rotAxis = 3;
else
    rotAxis = 4; % Rotational axis to use for the circle
end

sTheta = -range/2;
eTheta = range/2;

theta = linspace(sTheta,eTheta,steps);

if Pos.X.Axis == axis
    axis1Label = 'X';
    axis1 = Pos.X;
elseif Pos.Y.Axis == axis
    axis1Label = 'Z';
    axis1 = Pos.Y;
else
    error('axis cannot be the Z-axis!')
end

% Check edges
if ~withinLimits(lib,axis,radius*sin(theta(1))) || ~withinLimits(lib,Pos.Z.Axis,radius*cos(theta(1)))...
        || ~withinLimits(lib,axis,radius*sin(theta(end))) || ~withinLimits(lib,Pos.Z.Axis,radius*cos(theta(end)))
    error(['Scan goes outside of limits! ', axis1Label,...
        ' limits: [',num2str(axis1.lowLimit),',',num2str(axis1.highLimit),...
        ']; Z limits: [', num2str(Pos.Z.lowLimit),',',num2str(Pos.Z.highLimit),']. ',...
        'Requested Scan Edges: ['...
        ,num2str(radius*sin(theta(1))),',',num2str(radius*sin(theta(end))),']; [',...
        num2str(radius*cos(theta(1))),',',num2str(radius*cos(theta(end))),'].'])
end

mkdir(saveLocation);

pnv = zeros(size(theta));
for ii = 1:length(theta)
    movePositionerAbs(lib,axis,radius*sin(theta(ii)));
    movePositionerAbs(lib,Pos.Z.Axis,radius*cos(theta(ii)));
    movePositionerAbs(lib,rotAxis,180/pi*theta(ii))
    pause(pauseLength*1e-3)
    
    wv = getSoniqWaveform(lib,[saveLocation,'wv_theta',num2str(180/pi*theta(ii),3),'.snq']);
    pnv(ii) = -min(wv);
end