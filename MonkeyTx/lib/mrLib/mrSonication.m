% Runs a sonication through VSX and logs it in sys.logFile
% 
% @INPUTS
%   sys: System struct that must contain a focal spot
%   duration: Length of sonication in seconds
%   voltage: Pk voltage in volts. Cannot exceed 10
% 
% @OUTPUTS
%   sys: Updated struct with sonication logged in sys.sonication
% 
% Taylor Webb
% University of Utah

function sys = mrSonication(sys,duration,voltage)
evalin('base','save(''tmpBeforeSonication'',''sys'')')
doppler256_MR(duration,voltage,sys.focalSpot*1e-3);

evalin('base', 'clearvars -except sys')
evalin('base', 'filename = ''doppler256_MR.mat''');
evalin('base', 'VSX')

success = input('Sonication Successful? (0/1)>> ');

if success
    sonication.duration = duration;
    sonication.voltage = voltage;
    sonication.time = now;
    sonication.focus = sys.focalSpot;

    if ~isfield(sys,'sonication')
        sys.sonication = sonication;
    else
        sys.sonication(end+1) = sonication;
    end
end

save(sys.logFile,'sys');

return