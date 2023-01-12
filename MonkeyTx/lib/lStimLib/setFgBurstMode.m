% setFgBurstMode(fg, ch, nCycles, phase, period) sets the 
% function generator to burst mode with the specified parameters.
% Currently this assumes that it is triggered burst mode and that the phase
% is 0
% 
% @INPUTS
%   fg: function generator object generated with Visa
%   ch: channel
%   nCycles: number of cycles
%   phase: phase in which burst mode starts. Defaults to 0
%   period: burst period in ms. Optional, only has an effect if trigger
%       mode is immediate (set with setFgTriggerMode). Currently untested.
% 
% @OUTPUTS
%   none
% 
% Taylor Webb
% taylorwebb85@gmail.com

function setFgBurstMode(fg, ch, nCycles, phase, period)
% Set up the mode
fprintf(fg,['SOUR',num2str(ch),':BURS:MODE TRIG']);

% Number of cycles
command = ['SOUR',num2str(ch),':BURS:NCYC ', num2str(nCycles)];
fprintf(fg,command);

if ~exist('phase','var')
    phase = 0;
end
fprintf(fg,'UNIT:ANGLE DEG');
command = ['SOUR',num2str(ch),':BURS:PHAS ',num2str(phase)];
fprintf(fg,command);

if exist('period','var')
    command = ['SOUR',num2str(ch),':BURS:INT:PER ', num2str(period*1e-3)];
    fprintf(fg,command);
end

fprintf(fg,['SOUR',num2str(ch),':BURS:STAT ON']);

err = checkFgError(fg);
if err
    ii = 1;
    nextErr = 1;
    while nextErr
        nextErr = checkFgError(fg);
        ii = ii+1;
    end
    error([num2str(ii), ' remote errors. First error: ', err])
end