% Returns the multiplier that can be used to project a distance from the
% transducer onto a fixed cartesian coordinate system. The cartestian
% coordinates are referenced to the array center. x is defined to go along
% the long axis of the array, y is defined along the short axis, and z is
% defined to be down (away from the transducer and normal to the center
% element). Note that, under this definition, the normal to the dlement is
% always perpindicular to the y-axis so there is no projection in that
% dimension.
% 
% @INPUTS
%   elementPos: Position vector for the element of interest. This must
%       match the Verasonics specifications for the element location
% 
% @OUTPUTS
%   xProjection: Projection of the normal to the element onto the x-axis
%   zProjection: Projection of the normal to the element onto the z-axis
% 
% Taylor Webb
% University of Utah
% Winter 2020

function [xProjection,zProjection] = signalLocation(elementPos)

theta = elementPos(4); % Angle between the transducer face and the z-axis
xProjection = sin(theta);
zProjection = cos(theta);