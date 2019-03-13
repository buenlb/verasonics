% continueScan uses parameters in Resource.Parameters.Axis and
% Resource.Parameters.locs to compute a step size and move the positioner
% 
% The program finds MATLAB's alias for the soniq library in
% Resource.Parameters.soniqLib
% 
% Taylor Webb
% University of Utah

function startScan(RData)
keyboard

Resource = evalin('base','Resource');

% Make sure relevant fields are present
if ~isfield(Resource.Parameters,'soniqLib')
    error('You must provide a MATLAB alias to the Soniq library in Resource.Parameters.soniqLib')
end
if ~isfield(Resource.Parameters,'Axis')
    error('You must provide the scan axis in Resource.Parameters.Axis')
end
if ~isfield(Resource.Parameters,'locs')
    error('You must provide grid locations in Resource.Parameters.locs')
end

% Move the positioner
movePositionerAbs(Resource.Parameters.soniqLib,...
    Resource.Parameters.Axis,Resource.Parameters.locs(1))
return