% Returns the estimated Ispta and V^2 of an lstim sonication.
% 
% @INPUTS
%   dc: duty cycle (percent)
%   isi: Inter sonication interval (ms)
%   p: pressure (MPa)
%   duration: duration of individual pulses (ms)
%   totDuration: total duration (s)

function [ispta,vss,ispta_skull] = lStimEnergy(dc,isi,p,duration,totDuration)

% convert units
dc = dc/100;
isi = isi*1e-3;
duration = duration*1e-3;

dc2 = duration/isi;
isppa = p2I_brain(p)/1e4;
ispta = isppa*dc*dc2;
ispta_skull = ispta*2;
vss = (p*1e-3*0.6133/55.2)^2*dc*dc2*totDuration*2; % 0.6133 converts from V^2s at 480 kHz to 650 kHz
