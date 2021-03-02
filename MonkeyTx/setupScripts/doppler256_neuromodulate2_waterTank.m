% doppler256_neuromodulate sets up a VSX mat file to run a neuromodulatory
% sonication.
% 
% @INPUTS
%   duration: Sonication duration in seconds.
%   volages: peak voltage applied to each element in volts
%   PRF: Pulse repitition frequency in Hz
%   duty: desired duty cycle (%)
%   fName: Full path in which to save log file
% 
% Taylor Webb
% University of Utah
% December 2020
% 

function doppler256_neuromodulate2_waterTank(duration, voltages, phases, PRF, duty, fName)
maxV = 20; % Maximum allowed voltage
%% Set up path locations
srcDirectory = setPaths();
addpath([srcDirectory,'lib\mrLib'])

%% Setup sonication properties
frequency = 0.65; % Frequency in MHz
T = 1/(frequency*1e6);
nCycles = round(duration/T); % number of cycles with which to excite Tx (can integer multiples of 1/2)

%% error check
for ii = 1:length(voltages)
    if voltages(ii) > maxV
        error(['Voltage is limited to ', num2str(maxV), ' volts'])
    end
end

%% Set up multiple pulses if duration is greater than maxCycles cycles
maxCycles = 6.5e6;
if nCycles > maxCycles
    error('I haven''t yet implemented pulses this long.')
end

%% Set up pulsing
if duty < 100
    numTransmits = duration*PRF;
    pulseDuration = 1/PRF*duty/100;
else
    numTransmits = 1;
    pulseDuration = duration;
end
nHalfCycles = ceil(2*pulseDuration/T);

%% Specify system parameters
Resource.Parameters.numTransmit = 256; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 256; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.connector = 0; % trans. connector to use (V256).
Resource.Parameters.speedOfSound = 1490; % speed of sound in m/sec
Resource.Parameters.verbose = 1;
Resource.Parameters.phases = phases;
Resource.Parameters.voltages = voltages;
Resource.Parameters.simulateMode = 0;
Resource.Parameters.startEvent = 1;

%% Create a log struct to save results
Resource.Parameters.logFileName = fName;
Resource.Parameters.priorSonication = [];
Resource.Parameters.log = struct('Date',date,'rightSonications',0,...
    'leftSonications',0,'totalSonications',0,'priorSonication',[],'Parameters',Resource.Parameters);

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

TPC(5).hv = voltages(1);
for ii = 1:5
    TPC(ii).maxHighVoltage = maxV;
    TPC(ii).highVoltageLimit = maxV;
    TPC(ii).xmitDuration = maxCycles;
end
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

TW.type = 'parametric';
TW.Parameters = [Trans.frequency,0.67,nHalfCycles,1]; % A, B, C, D

% Specify TX structure array.
TX(1).waveform = 1; % use 1st TW structure.
TX(1).focus = 0;
TX(1).Apod = ones(1,256);
% badElements = load('C:\Users\Verasonics\Downloads\elementsOff.mat');
% TX(1).Apod(badElements.unconnected) = 0;

% delays = zeros(size(delays));
TX(1).Delay = phases{1};

% Specify TGC Waveform structure.
TGC(1).CntrlPts = ones(1,8)*0;
TGC(1).rangeMax = 1;
TGC(1).Waveform = computeTGCWaveform(TGC);

%% External Function
Process(1).classname = 'External';
Process(1).method = 'waitForServer';
Process(1).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

%% Set TPC 5
n = 1;
nsc = 1;
Event(n).info = 'select TPC profile 5';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = nsc; % set TPC profile command.
SeqControl(nsc).command = 'setTPCProfile';
SeqControl(nsc).argument = 5;
SeqControl(nsc).condition = 'immediate';
nsc = nsc + 1;
% Resource.Parameters.startEvent = n;
n = n+1;

%% Listen to server
Event(n).info = 'Listen to server';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 1;
Event(n).seqControl = 0;
% SeqControl(nsc).command = 'sync';
% nsc = nsc+1;
serverEvent = n;
n = n+1;

%% Sonicate
Event(n).info = 'Sonicate.';
Event(n).tx = 1; % use 1st TX structure.
Event(n).rcv = 0; % no receive
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
Event(n).seqControl = [nsc,nsc+1];
    SeqControl(nsc).command = 'pause';
    SeqControl(nsc).condition = 'extTrigger';
    SeqControl(nsc).argument = 17;
    nsc = nsc + 1;
    SeqControl(nsc).command = 'timeToNextAcq';
    SeqControl(nsc).argument = 1/PRF*1e6;
    nscTime2Acq = nsc;
    nsc = nsc + 1;
    firstSonicationIdx = n;
n = n+1;

for ii = 2:numTransmits
    Event(n) = Event(firstSonicationIdx);
    Event(n).seqControl = nscTime2Acq;
    n = n+1;
end

Event(n).info = 'Return to beginning';
Event(n).tx = 0; % use 1st TX structure.
Event(n).rcv = 0; % no receive
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
Event(n).seqControl = nsc;
    SeqControl(nsc).command = 'jump';
    SeqControl(nsc).argument = serverEvent;
    SeqControl(nsc).condition = 'exitAfterJump';
    nsc = nsc + 1;
%     SeqControl(nsc).command = 'sync';
%     SeqControl(nsc).argument = 2.1e9;
%     nsc = nsc + 1;
n = n+1;


% Save all the structures to a .mat file.
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);