function p = I2p_brain(I)
c = 1546; % speed of sound in m/s from IT'IS foundation
rho = 1046; % density in kg/m^3 from IT'IS foundation

p = sqrt(I*c*rho*2);