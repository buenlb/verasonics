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
if sys.focalSpot(3)<0
    error('Z component of focus must be greater than 0!')
elseif sys.focalSpot(3)<30
    warning('Z component of focus is less than 30 mm')
end
evalin('base','save(''tmpBeforeSonication'',''sys'')')
% doppler256_MR(duration,voltage,sys.focalSpot*1e-3);

% evalin('base', 'clearvars -except sys')
% evalin('base', 'filename = ''doppler256_MR.mat''');
% evalin('base', 'VSX')

success = input('Sonication Successful? (0/1)>> ');

if success
    sonication.duration = duration;
    sonication.voltage = voltage;
    sonication.time = now;
    sonication.focalSpot = sys.focalSpot;
    sonication.focalSpotIdx = sys.focalSpotIdx;
    sonication.focalSpotMr = sys.focalSpotMr;
    sonication.description = input('Describe this sonication: ', 's');
    userInput = input('Press enter when files are ready (input s to skip).','s');
    if ~strcmp(userInput, 's')
        [img,header,seriesNo] = sortDicoms(sys.incomingDcms, sys.mrPath);
        sonication.phaseSeriesNo = seriesNo(2);
        sonication.magSeriesNo = seriesNo(1);
        
        sys.tImg = img{2};
        sys.tMagImg = img{1};
        sys.tHeader = header(2,:);
    end

    if ~isfield(sys,'sonication')
        sys.sonication = sonication;
    else
        sys.sonication(end+1) = sonication;
    end
end
try
    save(sys.logFile,'sys');
catch
    keyboard
end

return