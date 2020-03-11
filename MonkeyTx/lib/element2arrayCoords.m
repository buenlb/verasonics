% Convert from element coordinates to array coordinates
% 
% @INPUTS
%   XE: x coordinates referenced to the element
%   YE: y coordinates referenced to the element
%   ZE: z coordinates referenced to the element
%   elementPos: Position vector for the element of interest. This must
%       match the Verasonics specifications for the element location
% 
% @OUTPUTS
%   XA: x coordinates referenced to the array
%   YA: y coordinates referenced to the array
%   ZA: z coordinates referenced to the array
% 
% Taylor Webb
% University of Utah
% Winter 2020

function [XA,YA,ZA] = element2arrayCoords(XE,YE,ZE,elementPos)
% Rotate
theta = elementPos(4);

XA = XE*cos(theta)+ZE*sin(theta);
ZA = ZE*cos(theta)-XE*sin(theta);

% Translate
% You have to be careful with this translation since the axes are no longer
% in the plane of the matrix indices. Thus, simply adding a constant shifts
% along the original array axis and not the element axis.
XA = XA+(elementPos(1));
YA = YE+elementPos(2);
ZA = ZA+(elementPos(3));