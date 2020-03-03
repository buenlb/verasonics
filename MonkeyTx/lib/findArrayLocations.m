% Find the locations of the signal for a given element in the array
% coordinate system. This is done by rotating and translating the element
% coordinates based on the values in elementPos
% 
% @INPUTS
%   XE: x location of signal referenced to the element
%   YE: y location of signal referenced to the element
%   ZE: z location of signal referenced to the element
%   elementPos: Position vector for the element of interest. This must
%       match the Verasonics specifications for the element location
% 
% @OUTPUTS
%   XA: x location of signal referenced to the array
%   YA: y location of signal referenced to the array
%   ZA: z location of signal referenced to the array
% 
% Taylor Webb
% University of Utah
% Winter 2020

function [XA,YA,ZA] = findArrayLocations(XE,YE,ZE,elementPos)
% Rotate
theta = elementPos(4);

XA = XE*cos(theta)-ZE*sin(theta);
ZA = ZE*cos(theta)+XE*sin(theta);

% Translate
XA = XA+elementPos(1);
YA = YE+elementPos(2);
ZA = ZA+elementPos(3);