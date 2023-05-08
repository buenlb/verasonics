% doppler256_neuromodulate sets up a VSX mat file to run a neuromodulatory
% sonication.
% 
% @INPUTS
%   duration: Sonication duration in seconds.
%   volages: peak voltage applied to each element in volts
%   target: target location in mm
%   PRF: Pulse repitition frequency in Hz
%   duty: desired duty cycle (%)
%   frequency: Frequency in MHz
%   fName: Full path in which to save log file
% 
% Taylor Webb
% University of Utah
% December 2020
% 

function doppler256_neuromodulate2_drugDelivery(duration, voltage, target, PRF, duty, frequency, fName, txSn, dev, nTargets)
maxV = 51.2; % Maximum allowed voltage
%% Set up path locations
srcDirectory = setPaths();
addpath([srcDirectory,'lib\mrLib'])

%% Setup sonication properties
T = 1/(frequency*1e6);
maxCycles = 6.5e6;

%% error check
for ii = 1:length(voltage)
    if voltage(ii) > maxV
        error(['Voltage is limited to ', num2str(maxV), ' volts'])
    end
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
Resource.Parameters.voltages = voltage;
Resource.Parameters.simulateMode = 0;
Resource.Parameters.startEvent = 1;

%% Create a log struct to save results
Resource.Parameters.logFileName = fName;
Resource.Parameters.priorSonication = [];
Resource.Parameters.DutyCycle = duty;
Resource.Parameters.PulseRepFreq = PRF;
Resource.Parameters.Duration = duration;
Resource.Parameters.txSn = txSn;
Resource.Parameters.log = struct('Date',datetime,'targets',target,'voltages',voltage,'Parameters',Resource.Parameters,'frequency',frequency);
log = Resource.Parameters.log;
save(Resource.Parameters.logFileName,'log')
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
Resource.HIFU.extPwrComPortID = 'COM4';

Resource.HIFU.psType = 'QPX600DP'; % set to 'QPX600DP' to match supply being used

TPC(5).hv = voltage(1);
for ii = 1:5
    TPC(ii).maxHighVoltage = maxV;
    TPC(ii).highVoltageLimit = maxV;
    TPC(ii).xmitDuration = maxCycles;
end
%%

% Specify media points
Media.MP(1,:) = [0,0,100,1.0]; % [x, y, z, reflectivity]

% Specify Trans structure array.
Trans = transducerGeometry(0,txSn);
Trans.frequency = frequency;
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

%% Create a spotlight effect by sonicating multiple targets
if ~sum(isnan(target))
    targets = generateTargets(target,nTargets,dev);
else
    nTargets(nTargets==1) = 0;
    totTargets = sum(nTargets);
    if totTargets == 0
        totTargets = 1;
    end
    targets = nan(totTargets,3);
end
% Find phases for each target
xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

elements.x = xTx*1e-3;
elements.y = yTx*1e-3;
elements.z = zTx*1e-3;

for ii = 1:size(targets,1)
    if sum(isnan(targets(ii,:)))
        rndPhs = load('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\taskLib\randomPhases.mat');
        phases{ii} = rndPhs.phs{ii};
        disp('USING RANDOM PHASES!')
    else
        elements = steerArray(elements,targets(ii,:)*1e-3,frequency,0);
        phases{ii} = [elements.t]';
    end
end

for ii = 1:length(phases)
    % Specify TX structure array.
    TX(ii).waveform = 1; % use 1st TW structure.
    TX(ii).focus = 0;
    TX(ii).Apod = ones(1,256);
    % badElements = load('C:\Users\Verasonics\Downloads\elementsOff.mat');
    % TX(1).Apod(badElements.unconnected) = 0;
    
    TX(ii).Delay = phases{ii};
end

% Specify TGC Waveform structure.
TGC(1).CntrlPts = ones(1,8)*0;
TGC(1).rangeMax = 1;
TGC(1).Waveform = computeTGCWaveform(TGC);

%% External Function
Process(1).classname = 'External';
Process(1).method = 'closeVSX';
Process(1).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

Process(2).classname = 'External';
Process(2).method = 'waitForUser';
Process(2).Parameters = {'srcbuffer','receive',... % name of buffer to process.
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

%% Wait for user
Event(n).info = 'Wait for user in order to sync with injection';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 2;
Event(n).seqControl = nsc; % set TPC profile command.
SeqControl(nsc).command = 'sync';
nsc = nsc+1;
n = n+1;

%% Sonicate
Event(n).info = 'Sonicate.';
Event(n).tx = 1; % use 1st TX structure.
Event(n).rcv = 0; % no receive
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
Event(n).seqControl = [nsc];
    SeqControl(nsc).command = 'timeToNextAcq';
    SeqControl(nsc).argument = 1/PRF*1e6;
    nscTime2Acq = nsc;
    nsc = nsc + 1;
    firstSonicationIdx = n;
n = n+1;

for ii = 2:numTransmits
    Event(n) = Event(firstSonicationIdx);
    if mod(ii,size(targets,1))
        Event(n).tx = mod(ii,size(targets,1));
    else
        Event(n).tx = size(targets,1);
    end
    Event(n).seqControl = nscTime2Acq;
    n = n+1;
end

Event(n).info = 'Close VSX.';
Event(n).tx = 0; % use 1st TX structure.
Event(n).rcv = 0; % use 1st Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 1; % call function to close
Event(n).seqControl = nsc;
SeqControl(nsc).command = 'sync';
        SeqControl(nsc).argument = duration*1e6;
nsc = nsc+1;
n = n+1;


% Save all the structures to a .mat file.
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);