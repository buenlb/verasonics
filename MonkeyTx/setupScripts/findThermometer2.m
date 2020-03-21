%% Parameters
f = 0.5;

xFoci = -20:0.5:20;
yFoci = -15:1:15;
zFoci = 20:1:70;

%% Set up path locations
srcDirectory = setPaths();

%%
% frequency = 0.65; % Frequency in MHz
nCycles = 1; % number of cycles with which to excite Tx (can integer multiples of 1/2)
ioChannel = 229;
NA = 1;

% Specify system parameters
Resource.Parameters.numTransmit = 256; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 256; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.connector = 0; % trans. connector to use (V256).
Resource.Parameters.speedOfSound = 1490; % speed of sound in m/sec
Resource.Parameters.numAvg = NA;
Resource.Parameters.ioChannel = ioChannel;
Resource.Parameters.saveDir = 'C:\Users\Verasonics\Desktop\Taylor\Code\findElementNumbers\recordings_take2\'; 
Resource.Parameters.saveName = 'pt3_';
Resource.Parameters.xFoci = xFoci;
Resource.Parameters.yFoci = yFoci;
Resource.Parameters.zFoci = zFoci;


% Resource.Parameters.simulateMode = 1; % runs script in simulate mode

% Specify media points
Media.MP(1,:) = [0,0,100,1.0]; % [x, y, z, reflectivity]

% Specify Trans structure array.
Trans = transducerGeometry(0);
Trans.units = 'mm';
Trans.maxHighVoltage = 10;
% Trans.frequency = 0.65*3;

TPC(1).hv = 10;

% Specify an external processing event.
Process(1).classname = 'External';
Process(1).method = 'findThermometer';
Process(1).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

% Specify Resource buffers.
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = 256*2048*4; % this allows for 1/4 maximum range
Resource.RcvBuffer(1).colsPerFrame = 1; % change to 256 for V256 system
Resource.RcvBuffer(1).numFrames = 1; % minimum size is 1 frame.

% Specify Transmit waveform structure.
TW(1).type = 'parametric';
TW(1).Parameters = [Trans.frequency,0.67,nCycles*2,1]; % A, B, C, D
% TW(1).type = 'pulseCode';
% TW(1).PulseCode = generateImpulse(1/(4*2.25e6));
% TW(1).PulseCode = generateImpulse(3/250e6);

% Specify TX structure array.
TX(1).waveform = 1; % use 1st TW structure.
TX(1).focus = 0;
TX(1).Apod = ones(1,256);

% Find center elements
% pins;
% % Assume matA is Tx and matB maps to pins on system
% centerIdx = matB(matA(15:17,:));
% 
% nonZeroChannels = 1:2:255;

xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

elements.x = xTx*1e-3;
elements.y = yTx*1e-3;
elements.z = zTx*1e-3;

elements = steerArray(elements,[xFoci(1),yFoci(1),zFoci(1)]*1e-3,Trans.frequency,0);
delays = [elements.t]';
TX(idx) = TX(1);
TX(idx).Delay = delays;

elements = selectElementBlocks(5);


% Specify TGC Waveform structure.
TGC(1).CntrlPts = ones(1,8)*0;
TGC(1).rangeMax = 1;
TGC(1).Waveform = computeTGCWaveform(TGC);

% Specify Receive structure array -
Receive(1).Apod = ones(1,256);
Receive(1).startDepth = 0;
Receive(1).endDepth = 30;
Receive(1).TGC = 1; % Use the first TGC waveform defined above
Receive(1).mode = 0;
Receive(1).bufnum = 1;
Receive(1).framenum = 1;
Receive(1).acqNum = 1;
Receive(1).sampleMode = 'custom';
Receive(1).decimSampleRate = 20*Trans.frequency;
Receive(1).LowPassCoef = [];
Receive(1).InputFilter = [];

n = 1;
nsc = 1;

% Specify sequence events.
Event(n).info = 'Acquire RF Data.';
Event(n).tx = 1; % use 1st TX structure.
Event(n).rcv = 1; % use 1st Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
Event(n).seqControl = [nsc,nsc+1,nsc+2];
SeqControl(nsc).command = 'timeToNextAcq';
    SeqControl(nsc).argument = 1e4;
    nscTime2Aq = nsc;
    nsc = nsc + 1;
    SeqControl(nsc).command = 'transferToHost';
    nsc = nsc + 1;
    SeqControl(nsc).command = 'triggerOut';
    nscTrig = nsc;
    nsc = nsc + 1;
n = n+1;

Event(n).info = 'Process Data';