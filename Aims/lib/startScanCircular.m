% continueScan uses parameters in Resource.Parameters.Axis and
% Resource.Parameters.locs to compute a step size and move the positioner
% 
% The program finds MATLAB's alias for the soniq library in
% Resource.Parameters.soniqLib
% 
% Taylor Webb
% University of Utah

function startScanCircular(RData)
keyboard

Resource = evalin('base','Resource');

% Make sure relevant fields are present
if ~isfield(Resource.Parameters,'soniqLib')
    error('You must provide a MATLAB alias to the Soniq library in Resource.Parameters.soniqLib')
end
if ~isfield(Resource.Parameters,'Axis')
    error('You must provide the scan axis in Resource.Parameters.Axis')
end
if ~isfield(Resource.Parameters,'theta')
    error('You must provide grid angles in Resource.Parameters.theta')
end
if ~isfield(Resource.Parameters,'radius')
    error('You must provide a radius in Resource.Parameters.radius')
end

theta = Resource.Parameters.theta;
radius = Resource.Parameters.radius;

% Move the positioner
movePositionerAbs(lib,Pos.Z.Axis,radius*cos(theta(1)));
movePositionerAbs(lib,rotAxis,180/pi*theta(1));
movePositionerAbs(lib,axis,radius*sin(theta(1)));
return