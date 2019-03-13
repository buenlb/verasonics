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

function movePositioner(lib,axis,distance)

%% Ensure the requested move is within software limits
curLoc = calllib(lib,'GetPosition',axis);

if withinLimits(lib,axis,curLoc+distance)
    calllib(lib,'PositionerMoveRel',axis,distance)
else
    error('Cannot move beyond software limits!')
end