% When argument are passed to L74_waterTank generates the MAT file required
% to run VSX. If no arguments are passed then it simply initates and
% returns the Trans struct.
% 
% @INPUTS
%   delays: 1XN array of delays where N is the number of elements in the
%       array
%   savePath: Location to save the measured waveforms. This is passed to
%      external functions via Resource.Paramaters.savePath
%   saveName: Base name with which to save the measured waveforms. This is 
%      passed to external functions via Resource.Paramaters.savePath
% 
% @OUTPUTS
%   Trans: Structure representing the transducer. Contains element
%      locations and frequency.
% 
% Taylor Webb
% Fall 2019

function [Trans,TW] = doppler256_waterTank_HIFU(delays,savePath,saveName)
if nargin == 1 || nargin == 2
    error('If you supply delays you must also supply a savePath and saveName!')
end
%% Set up path locations
srcDirectory = setPaths();

%%
NA = 1;
ioChannel = 1;

% Specify system parameters
Resource.Parameters.numTransmit = 256; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 256; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.speedOfSound = 1490; % speed of sound in m/sec
Resource.Parameters.connector = 0; % trans. connector to use (V256).
Resource.Parameters.numAvg = NA;
Resource.Parameters.ioChannel = ioChannel;
Resource.Parameters.gridInfoFile = 'C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\setupScripts\gridInfo.mat';
if nargin > 1
    Resource.Parameters.saveDir = savePath;
    Resource.Parameters.saveName = saveName;
end

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

TPC(5).hv = 1.6;
TPC(5).maxHighVoltage = 20;
TPC(5).highVoltageLimit = 20;
TPC(5).xmitDuration = 1e7;

%%

% Specify media points
Media.MP(1,:) = [0,0,100,1.0]; % [x, y, z, reflectivity]

% Specify Trans structure array.
Trans = transducerGeometry(0);
Trans.units = 'mm';
Trans.maxHighVoltage = 20;
frequency = Trans.frequency;

% Specify Resource buffers.
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = NA*4096; % this allows for 1/4 maximum range
Resource.RcvBuffer(1).colsPerFrame = 1; % change to 256 for V256 system
Resource.RcvBuffer(1).numFrames = 1; % minimum size is 1 frame.

% Specify Transmit waveform structure.
TW(1).type = 'parametric';
numberHalfCycles = 100;
TW(1).Parameters = [frequency,0.67,numberHalfCycles,1]; % A, B, C, D

if nargin < 1
    return;
end

% TW(1).type = 'pulseCode';
% TW(1).PulseCode = generateImpulse(1/(4*2.25e6));
% TW(1).PulseCode = generateImpulse(3/250e6);

% Specify TX structure array.
TX(1).waveform = 1; % use 1st TW structure.
TX(1).focus = 0;
TX(1).Apod = ones(1,256);
TX(1).Delay = delays;

TPC(1).hv = 1.6;

% Specify TGC Waveform structure.
TGC(1).CntrlPts = zeros(1,8);
TGC(1).rangeMax = 1;
TGC(1).Waveform = computeTGCWaveform(TGC);

% Specify Receive structure array -
Receive(1).Apod = ones(1,256);
Receive(1).startDepth = 0;
Receive(1).endDepth = 80;
Receive(1).TGC = 1; % Use the first TGC waveform defined above
Receive(1).mode = 0;
Receive(1).bufnum = 1;
Receive(1).framenum = 1;
Receive(1).acqNum = 1;
Receive(1).sampleMode = 'NS200BW';
Receive(1).LowPassCoef = [];
Receive(1).InputFilter = [];

for n = 2:NA
    Receive(n) = Receive(1);
    Receive(n).acqNum = n;
end

% Specify an external processing event.
Process(1).classname = 'External';
Process(1).method = 'getWaveform';
Process(1).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

Process(2).classname = 'External';
Process(2).method = 'movePositionerVerasonics';
Process(2).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

Process(3).classname = 'External';
Process(3).method = 'startGridVerasonics';
Process(3).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

Process(4).classname = 'External';
Process(4).method = 'displayResults';
Process(4).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

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

Event(n).info = 'Move Positioner';
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 3; 
Event(n).seqControl = [nsc]; % wait for data to be transferred
SeqControl(nsc).command = 'sync';
SeqControl(nsc).argument = 2e9;
nsc = nsc+1;
n = n+1;

% Specify sequence events.
Event(n).info = 'Acquire RF Data.';
Event(n).tx = 1; % use 1st TX structure.
Event(n).rcv = 1; % use 1st Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
Event(n).seqControl = [2,3,4];
SeqControl(nsc).command = 'timeToNextAcq';
SeqControl(nsc).argument = numberHalfCycles*2/frequency*1000;
nsc = nsc+1;
SeqControl(nsc).command = 'transferToHost';
nsc = nsc+1;
SeqControl(nsc).command = 'triggerOut';
nsc = nsc+1;
n = n+1;

nsc = 4;
for ii = 2:NA
    Event(n) = Event(2);
    Event(n).rcv = ii;
    Event(n).seqControl = [2,4,nsc];
     SeqControl(nsc).command = 'transferToHost';
	   nsc = nsc + 1;
    n = n+1;
%     Event(n) = Event(2);
%     n = n+1;
end

Event(n).info = 'Acquire a waveform';
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 1; 
n = n+1;

Event(n).info = 'Move Positioner';
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 2; 
% Event(n).seqControl = [nsc]; % wait for data to be transferred
% SeqControl(nsc).command = 'sync';
% SeqControl(nsc).argument = 2e9;
nsc = nsc+1;
n = n+1;

Event(n).info = 'Wait and diplay';
    Event(n).tx = 0; 
    Event(n).rcv = 0;
    Event(n).recon = 0;
    Event(n).process = 4;
    Event(n).seqControl = nsc;
        SeqControl(nsc).command = 'noop';
        SeqControl(nsc).argument = (10*1e-3)/200e-9;
%         SeqControl(nsc).condition = 'Hw&Sw';
        nsc = nsc+1;
    n = n+1;
    
Event(n).info = 'Jump back to Event 2.';
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
Event(n).seqControl = nsc; % jump back to Event 1
SeqControl(nsc).command = 'jump';
SeqControl(nsc).condition = 'exitAfterJump';
SeqControl(nsc).argument = 3;

% Save all the structures to a .mat file.
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);
VSX
% keyboard
