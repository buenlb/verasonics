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
nCycles = round(duration/T) % number of cycles with which to excite Tx (can integer multiples of 1/2)

%% error check
if nCycles > 1e7
    error(['Duration must be shorter than ', num2str(1e7*T), ' seconds.']);
end
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
TW(1).Parameters = [Trans.frequency,0.67,nCycles*2,1]; % A, B, C, D

% Specify TX structure array.
TX(1).waveform = 1; % use 1st TW structure.
TX(1).focus = 0;
TX(1).Apod = ones(1,256);
badElements = load('C:\Users\Verasonics\Downloads\elementsOff.mat');
TX(1).Apod(badElements.unconnected) = 0;

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

% Specify sequence events.
Event(n).info = 'Sonicate.';
Event(n).tx = 1; % use 1st TX structure.
Event(n).rcv = 0; % use 1st Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
Event(n).seqControl = nsc;
SeqControl(nsc).command = 'triggerOut';
nscTrig = nsc;
nsc = nsc + 1;
n = n+1;


% Save all the structures to a .mat file.
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);