% Convert from array coordinates to element coordinates
% 
% @INPUTS
%   XA: x coordinates referenced to the array
%   YA: y coordinates referenced to the array
%   ZA: z coordinates referenced to the array
%   elementPos: Position vector for the element of interest. This must
%       match the Verasonics specifications for the element location
% 
% @OUTPUTS
%   XE: x coordinates referenced to the element
%   YE: y coordinates referenced to the element
%   ZE: z coordinates referenced to the element
% 
% Taylor Webb
% University of Utah
% Winter 2020

function [XE,YE,ZE] = array2elementCoords(XA,YA,ZA,elementPos)
% Rotate
theta = elementPos(4);

XE = XA*cos(theta)-ZA*sin(theta);
ZE = ZA*cos(theta)+XA*sin(theta);

% Translate
% You have to be careful with this translation since the axes are no longer
% in the plane of the matrix indices. Thus, simply adding a constant shifts
% along the original array axis and not the element axis.
XE = XE-(elementPos(1)*cos(theta)-elementPos(3)*sin(theta));
YE = YA-elementPos(2);
ZE = ZE-(elementPos(3)*cos(theta)+elementPos(1)*sin(theta));