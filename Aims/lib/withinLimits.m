% withinLimits(axis) returns true if the location, loc, on axis, axis, is
% within software limits for the positioner. Note that Soniq does not allow
% you to go equal to the limit - you have to be a bit short of it.
% 
% @INPUTS
%   axis: axis to check
%   loc: location to check
% 
% @OUTPUTS
%   inside: true if within limts, false otherwise
% 
% Taylor Webb
% University of Utah

function inside = withinLimits(lib,axis,loc)
lowLimit = calllib(lib,'GetPositionerLowLimit',axis);
highLimit = calllib(lib,'GetPositionerHighLimit',axis);

if loc <= lowLimit || loc >= highLimit
    inside = false;
else
    inside = true;
end