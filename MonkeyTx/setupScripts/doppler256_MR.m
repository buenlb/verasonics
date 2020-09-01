% doppler256_MR(duration,voltage,focus)
% Creates the VSX mat file to sonicate with the desired duration and
% voltage.
% 
% @INPUTS
%   duration: duration in seconds. There is no maximum but if a duration of
%       more than 10 seconds is requested then the system will use multiple
%       back-to-back pulses to achieve the desired result.
%   voltage: voltage in Vp. Maximum is 20 Vp
%   focus: Desired focal location in mm (x,y,z)
% 
% @OUTPUTS
%   Trans: Struct describing transducer
% 
% Taylor Webb
% University of Utah

function Trans = doppler256_MR(duration, voltage, focus)
maxV = 20; % Maximum allowed voltage
%% Set up path locations
srcDirectory = setPaths();
%% Return Trans struct if no parameters specified.
if nargin == 0
    Trans = transducerGeometry(0);
    Trans.units = 'mm';
    Trans.maxHighVoltage = maxV;
    return
end

%% Setup sonication properties
frequency = 0.65; % Frequency in MHz
T = 1/(frequency*1e6);

% If the pulse duration is greater than 10 seconds then create multiple
% events such that the total duration equals the requested value.
if duration <= 10
    nCycles = round(duration/T); % number of cycles with which to excite Tx (can integer multiples of 1/2)
else
    nCycles(1:floor(duration/10)) = round(10/T);
    nCycles(ceil(duration/10)) = round((duration-floor(duration/10)*10)/T);
end

%% error check
if voltage > maxV
    error(['Voltage is limited to ', num2str(maxV), ' volts'])
end

% Specify system parameters
Resource.Parameters.numTransmit = 256; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 256; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.connector = 0; % trans. connector to use (V256).
Resource.Parameters.speedOfSound = 1490; % speed of sound in m/sec

%% Set up longer pulses
% HIFU % The Resource.HIFU.externalHifuPwr parameter must be specified in a
% script using TPC Profile 5 with the HIFU option, to inform the system
% that the script intends to use the external power supply.  This is also
% to make sure that the script was explicitly written by the user for this
% purpose, and to prevent a script intended only for an Extended Transmit
% system from accidentally being used on the HIFU system.
Resource.HIFU.externalHifuPwr = 1;

% HIFU % The string value assigned to the variable below is used to set the
% port ID for the virtual serial port used to control the external HIFU
% power supply.  The port ID was assigned by the Windows OS when it
% installed the SW driver for the power supply; the value assigned here may
% have to be modified to match.  To find the value to use, open the Windows
% Device Manager and select the serial/ COM port heading.  If you have
% installed the driver for the external power supply, and it is connected
% to the host computer and turned on, you should see it listed along with
% the COM port ID number assigned to it.
Resource.HIFU.extPwrComPortID = 'COM5';

Resource.HIFU.psType = 'QPX600DP'; % set to 'QPX600DP' to match supply being used

TPC(5).hv = voltage;
TPC(5).maxHighVoltage = maxV;
TPC(5).highVoltageLimit = maxV;
TPC(5).xmitDuration = 1e7;

%%
Process(1).classname = 'External';
Process(1).method = 'waitForMatlab';
Process(1).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

%%

% Specify media points
Media.MP(1,:) = [0,0,100,1.0]; % [x, y, z, reflectivity]

% Specify Trans structure array.
Trans = transducerGeometry(0);
Trans.units = 'mm';
Trans.maxHighVoltage = maxV;

% Specify Resource buffers.
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = 2048; % this allows for 1/4 maximum range
Resource.RcvBuffer(1).colsPerFrame = 1; % change to 256 for V256 system
Resource.RcvBuffer(1).numFrames = 1; % minimum size is 1 frame.

% Specify Transmit waveform structure.
TW(1).type = 'parametric';
TW(1).Parameters = [Trans.frequency,0.67,nCycles(1)*2,1]; % A, B, C, D
if length(nCycles) > 1
    TW(2).type = 'parametric';
    TW(2).Parameters = [Trans.frequency,0.67,nCycles(end)*2,1]; % A, B, C, D
end

% Specify TX structure array.
TX(1).waveform = 1; % use 1st TW structure.
TX(1).focus = 0;
TX(1).Apod = ones(1,256);
% badElements = load('C:\Users\Verasonics\Downloads\elementsOff.mat');
% TX(1).Apod(badElements.unconnected) = 0;

xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

elements.x = xTx*1e-3;
elements.y = yTx*1e-3;
elements.z = zTx*1e-3;
            
elements = steerArray(elements,focus,frequency);
delays = [elements.t]';
% delays = zeros(size(delays));
TX(1).Delay = delays;

if length(nCycles)>1
    TX(2) = TX(1);
    TX(2).waveform = 2; % This is the final pulse (the one that is not 10 seconds long)
end

% Specify TGC Waveform structure.
TGC(1).CntrlPts = ones(1,8)*0;
TGC(1).rangeMax = 1;
TGC(1).Waveform = computeTGCWaveform(TGC);

% Specify an external processing event.
n = 1;
nsc = 1;
Event(n).info = 'select TPC profile 5';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = nsc; % set TPC profile command.
n = n+1;
SeqControl(nsc).command = 'setTPCProfile';
SeqControl(nsc).argument = 5;
SeqControl(nsc).condition = 'immediate';
nsc = nsc + 1;


Event(n).info = 'Wait until user unfreezes';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = nsc; % set TPC profile command.
n = n+1;
SeqControl(nsc).command = 'sync';
nsc = nsc + 1;

Event(n).info = 'Wait until user unfreezes';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = [nsc,nsc+1]; % set TPC profile command.
n = n+1;
SeqControl(nsc).command = 'returnToMatlab';
nsc = nsc + 1;
SeqControl(nsc).command = 'sync';
nsc = nsc + 1;


for ii = 1:length(nCycles)
    % Specify sequence events.
    Event(n).info = 'Sonicate.';
    if ii < length(nCycles) || length(nCycles) == 1
        Event(n).tx = 1; % use 1st TX structure.
    else
        Event(n).tx = 2;
    end
    Event(n).rcv = 0; % use 1st Rcv structure.
    Event(n).recon = 0; % no reconstruction.
    Event(n).process = 0; % no processing
    if ii == 1
        Event(n).seqControl = nsc;
        SeqControl(nsc).command = 'triggerOut';
        nscTrig = nsc;
        nsc = nsc + 1;
    else
        Event(n).seqControl = nscTrig;
    end
    n = n+1;
end


% Save all the structures to a .mat file.
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);