function [xProjection,zProjection] = signalLocation(elementPos)

theta = elementPos(4);
xProjection = sin(theta);
zProjection = cos(theta);