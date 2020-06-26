%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Convert phase phase difference image into temperature
%  
%  usage:   phase2temp(phaseimage, initial temp, TE in ms, B0)
%  output:  temperature image
%
%  Rachelle Bitton
%  04/12/2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tempimage = phase2temp(phaseimage, initemp, TE, B0)

gamma_bar = 42.575*10^(6);        % gyromagnetic ratio in MHz/T
alpha = -0.01*10^(-6);			% thermal coefficient in ppm/degC

B = B0;
TE = TE*10^(-3);
init=ones(size(phaseimage))*initemp;
dphidT=2*pi*gamma_bar*alpha*B*TE;%-0.2*pi/180
tempimage=phaseimage./dphidT;
tempimage=tempimage+init;

