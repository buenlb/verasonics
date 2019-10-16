% Estimates the arrival time of the signal, v.
% 
% @INPUTS
%   t: sample times in microseconds
%   v: waveform data
% 
% @OUTPUTS
%   tau: estimated arrival time in microseconds
%   dist: estimated distance between the hydrophone and transducer in mm
% 
% University of Utah
% May, 2019

function [tau,dist] = arrivalTime(t,v)

a=(max(v));
b=find(abs(v)>0.05*a);

if a < 1e-3
%    error('Failed to find a waveform!')
end

tau=t(b(1));

dist = tau*1492e-3; % 1492e-3 is estimated speed of sound in mm/microsecond


