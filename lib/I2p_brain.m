% I2p_brain converts the intensity, I (w/m^2) to a pressure in pascals. It
% assumes IT'IS foundation values for the speed of sound and density in
% bone.
% 
% @INPUTS
%   I: Intensity (w/m^2)
% 
% @OUTPUTS
%   p: Pressure (pascals)
% 
% Taylor Webb
% University of Utah

function p = I2p_brain(I)
c = 1546; % speed of sound in m/s from IT'IS foundation
rho = 1046; % density in kg/m^3 from IT'IS foundation

p = sqrt(I*c*rho*2);