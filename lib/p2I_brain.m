function I = p2I_brain(p)
c = 1546; % speed of sound in m/s from IT'IS foundation
rho = 1046; % density in kg/m^3 from IT'IS foundation

I = (p)^2/(c*rho*2);