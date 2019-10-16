    clear all; close all; clc;

%% Set up path locations
srcDirectory = setPaths();


%%
NA = 1;
frequency = 1;
ioChannel = 1;

% Specify system parameters
Resource.Parameters.numTransmit = 1; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 1; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.connector = 1; % trans. connector to use (V256).
Resource.Parameters.speedOfSound = 1490; % speed of sound in m/sec
Resource.Parameters.numAvg = NA;
Resource.Parameters.ioChannel = ioChannel;

% Resource.Parameters.simulateMode = 1; % runs script in simulate mode

% Specify media points
Media.MP(1,:) = [0,0,100,1.0]; % [x, y, z, reflectivity]

% Specify Trans structure array.
Trans.name = 'L7-4';
Trans = computeTrans(Trans);
frequency = Trans.frequency;

xTx = Trans.ElementPos(:,2);
yTx = Trans.ElementPos(:,1);
zTx = Trans.ElementPos(:,3);

elements.x = xTx*1e-3;
elements.y = yTx*1e-3;
elements.z = zTx*1e-3;
            
elements = steerArray(elements,[0,0,20]*1e-3,frequency*1e6);
delays = [elements.t]';
% Specify Resource buffers.
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = NA*4096; % this allows for 1/4 maximum range
Resource.RcvBuffer(1).colsPerFrame = 128; % change to 256 for V256 system
Resource.RcvBuffer(1).numFrames = 1; % minimum size is 1 frame.

% Specify Transmit waveform structure.
TW(1).type = 'parametric';
numberHalfCycles = 2;
TW(1).Parameters = [frequency,0.67,numberHalfCycles,1]; % A, B, C, D
% TW(1).type = 'pulseCode';
% TW(1).PulseCode = generateImpulse(1/(4*2.25e6));
% TW(1).PulseCode = generateImpulse(3/250e6);

% Specify TX structure array.
TX(1).waveform = 1; % use 1st TW structure.
TX(1).focus = 0;
TX(1).Apod = ones(1,128);
TX(1).Delay = delays;

% Specify TGC Waveform structure.
TGC(1).CntrlPts = zeros(1,8);
TGC(1).rangeMax = 250;
TGC(1).Waveform = computeTGCWaveform(TGC);

% Specify Receive structure array -
Receive(1).Apod = ones(1,128);
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
Process(1).method = 'plotSingleElementAveraging';
Process(1).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

% Specify sequence events.
Event(1).info = 'Acquire RF Data.';
Event(1).tx = 1; % use 1st TX structure.
Event(1).rcv = 1; % use 1st Rcv structure.
Event(1).recon = 0; % no reconstruction.
Event(1).process = 0; % no processing
Event(1).seqControl = [1,2,3];
SeqControl(1).command = 'timeToNextAcq';
SeqControl(1).argument = 3e4;
SeqControl(2).command = 'transferToHost';
SeqControl(3).command = 'triggerOut';
n = 2;


nsc = 4;
for ii = 2:NA
    Event(n) = Event(1);
    Event(n).rcv = ii;
    Event(n).seqControl = [1,3,nsc];
     SeqControl(nsc).command = 'transferToHost';
	   nsc = nsc + 1;
    n = n+1;
%     Event(n) = Event(2);
%     n = n+1;
end

Event(n).info = 'Call external Processing function.';
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 1; % no processing function
Event(n).seqControl = [nsc,nsc+1,nsc+2]; % wait for data to be transferred
SeqControl(nsc).command = 'waitForTransferComplete';
SeqControl(nsc).argument = 2;
SeqControl(nsc+1).command = 'markTransferProcessed';
SeqControl(nsc+1).argument = 2;
SeqControl(nsc+2).command = 'sync';
SeqControl(nsc+2).argument = 25e6;
nsc = nsc+3;
n = n+1;

% Event(n).info = 'Call external Processing function.';
% Event(n).tx = 0; % no TX structure.
% Event(n).rcv = 0; % no Rcv structure.
% Event(n).recon = 0; % no reconstruction.
% Event(n).process = 1; % call processing function
% Event(n).seqControl = [3,4,5]; % wait for data to be transferred
% SeqControl(3).command = 'waitForTransferComplete';
% SeqControl(3).argument = 2;
% SeqControl(4).command = 'markTransferProcessed';
% SeqControl(4).argument = 2;
% SeqControl(5).command = 'sync';
% n = n+1;

Event(n).info = 'Jump back to Event 1.';
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
Event(n).seqControl = nsc; % jump back to Event 1
SeqControl(nsc).command = 'jump';
SeqControl(nsc).argument = 1;

% Save all the structures to a .mat file.
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);
