% getPosition(axis) returns the current position of axis, axis.
% (0:left/right, 1:front/back, 2:up/down)
% 
% @INPUTS
%   lib: MATLAB alias of dll
%   axis: Desired axis along which to move(0:left/right, 1:front/back, 2:up/down)
%
% @OUTPUTS
%   position: current position of the axis
% 
% Taylor Webb
% University of Utah

function position = getPosition(lib,axis)

position = calllib(lib,'GetPosition',axis);