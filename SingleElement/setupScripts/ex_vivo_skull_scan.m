clear all; close all; clc;

%% Set up path locations
srcDirectory = setPaths();

%% User Defined Variables
NA = 32; % Desired number of averages
frequency = 2.25; % Center frequency of the transducer in MHz
samplingRate = 50; % Sampling rate of the pulse/echo data in MHz (max: 50)
saveDir = 'C:\Users\Verasonics\Desktop\Taylor\Data\exVivo180Scans\20200205\test\'; % Name of the directory in which to save results
saveName = 'noSkull'; % Base name to use when saving files. 
angles = linspace(-95,-94,2); % Vector specifying the angles to use.

%% Specify system parameters
ioChannel = 97;
Resource.Parameters.numTransmit = 1; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 1; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.connector = 1; % trans. connector to use (V256).
Resource.Parameters.speedOfSound = 1490; % speed of sound in m/sec
Resource.Parameters.numAvg = NA;
Resource.Parameters.ioChannel = ioChannel;
Resource.Parameters.saveDir = saveDir;
Resource.Parameters.saveName = saveName;
Resource.Parameters.angles = angles;
% Resource.Parameters.simulateMode = 1; % runs script in simulate mode

% Create Dir if it doesn't exist
if isempty(ls(Resource.Parameters.saveDir))
    create = input('Directory doesn''t exist, creat it? (0/1) >>');
    if create
        mkdir(Resource.Parameters.saveDir)
    else
        error('Directory Doesn''t Exist')
    end
end

% Specify media points
Media.MP(1,:) = [0,0,100,1.0]; % [x, y, z, reflectivity]

% Specify Trans structure array.
Trans.name = 'Custom';
Trans.frequency = frequency;
Trans.units = 'mm';
Trans.lensCorrection = 1;
Trans.Bandwidth = [1.5,3];
Trans.type = 0;
Trans.numelements = 128;
Trans.elementWidth = 24;
Trans.ElementPos = ones(128,5);
Trans.ElementSens = ones(101,1);
Trans.connType = 1;
Trans.Connector = (1:128)';
Trans.impedance = 50;
Trans.maxHighVoltage = 96;


% Specify Resource buffers.
Resource.RcvBuffer(1).datatype = 'int16';
% Resource.RcvBuffer(1).rowsPerFrame = NA*4096*2; % this allows for 1/4 maximum range
Resource.RcvBuffer(1).rowsPerFrame = ceil(4*700*NA*samplingRate/frequency); % this allows for 1/4 maximum range
Resource.RcvBuffer(1).colsPerFrame = 1; % change to 256 for V256 system
Resource.RcvBuffer(1).numFrames = 1; % minimum size is 1 frame.

%% Specify Transmit waveform structure.
TW(1).type = 'parametric';
numberHalfCycles = 2;
TW(1).Parameters = [frequency,0.67,numberHalfCycles,1]; % A, B, C, D

TW(2).type = 'parametric';
numberHalfCycles = 500;
TW(2).Parameters = [frequency,0.67,numberHalfCycles,1]; % A, B, C, D

%% Specify TX structure array.
TX(1).waveform = 1; % use 1st TW structure.
TX(1).focus = 0;
TX(1).Apod = zeros(1,128);
TX(1).Apod(Resource.Parameters.ioChannel) = 1;
TX(1).Delay = zeros(1,128);

% Specify TX structure array.
TX(2).waveform = 2; % use 1st TW structure.
TX(2).focus = 0;
TX(2).Apod = zeros(1,128);
TX(2).Apod(Resource.Parameters.ioChannel) = 1;
TX(2).Delay = zeros(1,128);

TPC(1).hv = 10;

%% Specify TGC Waveform structure.
TGC(1).CntrlPts = zeros(1,8);
TGC(1).rangeMax = 250;
TGC(1).Waveform = computeTGCWaveform(TGC);

%% Specify Receive structure array -
Receive(1).Apod = zeros(1,128);
Receive(1).Apod(Resource.Parameters.ioChannel) = 1;
Receive(1).startDepth = 0;
Receive(1).endDepth = 800;
Receive(1).TGC = 1; % Use the first TGC waveform defined above
Receive(1).mode = 0;
Receive(1).bufnum = 1;
Receive(1).framenum = 1;
Receive(1).acqNum = 1;
Receive(1).sampleMode = 'custom';
Receive(1).decimSampleRate = samplingRate;
Receive(1).LowPassCoef = [];
Receive(1).InputFilter = [];

for n = 2:NA
    Receive(n) = Receive(1);
    Receive(n).acqNum = n;
end

%% External Processing
Process(1).classname = 'External';
Process(1).method = 'getWaveform_exVivoScan';
Process(1).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

Process(2).classname = 'External';
Process(2).method = 'rotateSkull';
Process(2).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

Process(3).classname = 'External';
Process(3).method = 'initializeSkullRotation';
Process(3).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

%% Initial event to make sure triggers are being received
% Specify sequence events.
n = 1;
nsc = 1;

Event(n).info = 'Move to initial position.';
Event(n).tx = 0; % use 1st TX structure.
Event(n).rcv = 0; % use 1st Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 3; % no processing
Event(n).seqControl = 0;
n = n+1;

%% Make sure enough time has passed for the move to complete
Event(n).info = 'Wait';
Event(n).tx = 0; 
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = nsc;
    SeqControl(nsc).command = 'noop';
    SeqControl(nsc).argument = (2)/200e-9;
    SeqControl(nsc).condition = 'Hw&Sw';
    nsc = nsc+1;
n = n+1;

%% Acquire echoes (with all averages)
Event(n).info = 'Acquire RF Data.';
Event(n).tx = 1; % use 1st TX structure.
Event(n).rcv = 1; % use 1st Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
Event(n).seqControl = [nsc,nsc+1];
SeqControl(nsc).command = 'timeToNextAcq';
SeqControl(nsc).argument = 1e3;
nscTime2Aq = nsc;
nsc = nsc+1;
SeqControl(nsc).command = 'transferToHost';
nsc = nsc+1;
SeqControl(nsc).command = 'triggerOut';
nscTrig = nsc;
nsc = nsc+1;
n = n+1;
for ii = 2:NA
    Event(n) = Event(2);
    Event(n).rcv = ii;
    Event(n).tx = 1;
    Event(n).seqControl = [nscTime2Aq,nsc];
     SeqControl(nsc).command = 'transferToHost';
       nsc = nsc + 1;
    n = n+1;
end

%% Acquire a waveform with the hydrophone
Event(n).info = 'Acquire a waveform with the hydrophone';
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 1; 
Event(n).seqControl = nsc;
    SeqControl(nsc).command = 'waitForTransferComplete';
    SeqControl(nsc).argument = nsc-1;
    nsc = nsc+1;
n = n+1;

%% Send the 2nd waveform to hydrophone and also listen to echo
Event(n) = Event(2);
Event(n).info = 'Hydrophone Measurement Transmit.';
Event(n).rcv = 0;
Event(n).tx = 2;
Event(n).process = 0;
% if ii == 1
%     timeToNextAcqContinuous = nsc;
%     nsc = nsc+1;
% end
Event(n).seqControl = [nscTrig];
% SeqControl(timeToNextAcqContinuous).command = 'timeToNextAcq';
% SeqControl(timeToNextAcqContinuous).argument = 0.1e6;
n = n+1;

%% Rotate Skull
Event(n) = Event(2);
Event(n).info = 'Rotate the skull';
Event(n).rcv = 0;
Event(n).tx = 0;
Event(n).process = 2;
Event(n).seqControl = 0;
n = n+1;    
    
%% Go back to the beginning
Event(n).info = 'Jump back to Event 1.';
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
Event(n).seqControl = nsc; % jump back to Event 1
SeqControl(nsc).command = 'jump';
SeqControl(nsc).condition = 'exitAfterJump';
SeqControl(nsc).argument = 2;

% Save all the structures to a .mat file.
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);
