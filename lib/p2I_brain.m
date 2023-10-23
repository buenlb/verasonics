% p2I_brain converts the pressure, p (pascals) to intensity in w/m^2. It
% assumes IT'IS foundation values for the speed of sound and density in
% bone.
% 
% @INPUTS
%   p: Pressure (pascals)
% 
% @OUTPUTS
%   I: Intensity (w/m^2)
% 
% Taylor Webb
% University of Utah

function I = p2I_brain(p)
c = 1546; % speed of sound in m/s from IT'IS foundation
rho = 1046; % density in kg/m^3 from IT'IS foundation

I = (p).^2/(c*rho*2);