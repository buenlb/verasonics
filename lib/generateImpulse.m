% Generates an impulse of duration duration using the arbitrary waveform
% generator. My experience is that the impulse won't be successfully set to
% be less han 3 cycles of the 250 MHz clock.
% 
% @INPUTS
%   duration: Desired duration of impulse function in seconds
% 
% @OUTPUTS
%   pc: Pulse Code matrix with values assigned according to the structure 
%     of the arbitrary waveform generator. See Verasonics documentation for
%     details of this structure. TW.PulseCode should be set to this
%     returned value
% 
% Taylor Webb (taylorwebb85@gmail.com)
% University of Utah
% February 2019

function pc = generateImpulse(duration)
% Figure out how many samples to turn output to high
T = 1/250e6;
nSamples = ceil(duration/(T));

% Generate pulse code matrix
Z1 = 0;
P1 = nSamples;
Z2 = 0;
P2 = 0;
R = 1;

% Return
pc = [Z1, P1, Z2, P2, R; 0, 0, 0, 0, 0];