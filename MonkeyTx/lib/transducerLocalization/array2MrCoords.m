% Convert from array coordinates to MR coordinates
% 
% @INPUTS
%   XA: x coordinates referenced to the array
%   YA: y coordinates referenced to the array
%   ZA: z coordinates referenced to the array
%   txPos: Position vector for the transducer in the MR coordinate
%       system. Should have the form [xCenter,yCenter,zCenter,theta] where
%       x, y, and zCenter are the MR coordinates of the center of the array
%       and theta is the angle between the transducer's x-axis and the MR
%       x-axis
% 
% @OUTPUTS
%   XMr: x coordinates referenced to the MR image
%   YMr: y coordinates referenced to the MR image
%   ZMr: z coordinates referenced to the MR image
% 
% Taylor Webb
% University of Utah
% Winter 2020

function [XMr,YMr,ZMr] = array2MrCoords(XA,YA,ZA,txPos)
% Rotate
theta = txPos(4);

XMr = XA*cos(theta)-YA*sin(theta);
YMr = YA*cos(theta)+XA*sin(theta);

% Translate
% You have to be careful with this translation since the axes are no longer
% in the plane of the matrix indices. Thus, simply adding a constant shifts
% along the original array axis and not the element axis.
XMr = XMr-(txPos(1)*cos(theta)-txPos(2)*sin(theta));
YMr = YMr-(txPos(2)*cos(theta)+txPos(1)*sin(theta));
ZMr = ZA-txPos(2);