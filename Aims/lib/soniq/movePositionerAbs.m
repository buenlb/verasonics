% movePositioner(axis,distance) moves the positioner distance mm along the
% selected axis (0:left/right, 1:front/back, 2:up/down)
% 
% @INPUTS
%   lib: MATLAB alias of dll
%   axis: Desired axis along which to move(0:left/right, 1:front/back, 2:up/down)
%   distance: distance to move in mm
%
% @OUTPUTS
%   None
% 
% Taylor Webb
% University of Utah

function movePositionerAbs(lib,axis,loc)

if withinLimits(lib,axis,loc)
    calllib(lib,'PositionerMoveAbs',axis,loc)
else
    error('Cannot Move outside of limits!')
end