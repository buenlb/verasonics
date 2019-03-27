% setFgBurstMode(fg, frequency, amplitude, period, nCycles) sets the 
% function generator to burst mode with the specified parameters.
% 
% @INPUTS
%   fg: function generator object generated with Visa
%   frequency: frequency in MHz
%   amplitude: amplitude in mVpp
%   period: burst period in ms
%   nCycles: number of cycles
% 
% @OUTPUTS
%   none
% 
% Taylor Webb
% Stanford University and University of Utah

function setFgBurstMode(fg, frequency, amplitude, period, nCycles)
%% Sinusoid properties
% Make sure amplitude is reasonable
if amplitude > 750
    error('Amplitude is too high for amplifier! Please select an amplitude less than or equal to 750 mVpp')
end

% Set frequency and amplitude
command = [':APPLy:SINusoid ', num2str(frequency*1e6), ', ' num2str(amplitude*1e-3)];
fprintf(fg,command);

%% Burst Properties
% Set up the mode
fprintf(fg,':BURS:MODE TRIG');

% Number of cycles
command = [':BURS:NCYC ', num2str(nCycles)];
fprintf(fg,command);

command = [':BURS:INT:PER ', num2str(period*1e-3)];
fprintf(fg,command);

% Make sure phase is zero, set to internal triggering, enable burst mode,
% and turn on the output trigger
fprintf(fg,':OUTP:TRIG:SLOP POS');
fprintf(fg,':OUTP:TRIG ON');
fprintf(fg,':BURS:PHAS 0');
fprintf(fg,':TRIG:SOUR IMM');
fprintf(fg,':BURS:STAT ON');