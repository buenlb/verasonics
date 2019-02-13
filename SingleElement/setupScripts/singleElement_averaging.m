clear all

% Specify system parameters
Resource.Parameters.numTransmit = 128; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 128; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.connector = 1; % trans. connector to use (V256).
Resource.Parameters.speedOfSound = 1540; % speed of sound in m/sec
% Resource.Parameters.simulateMode = 1; % runs script in simulate mode

% Specify media points
Media.MP(1,:) = [0,0,100,1.0]; % [x, y, z, reflectivity]

% Specify Trans structure array.
Trans.name = 'Custom';
Trans.frequency = 2.25; % not needed if using default center frequency
Trans.units = 'mm';
Trans.lensCorrection = 1;
Trans.Bandwidth = [1.5,3];
Trans.type = 0;
Trans.numelements = 1;
Trans.elementWidth = 24;
Trans.ElementPos = ones(1,5);
Trans.ElementSens = ones(101,1);
Trans.connType = 1;
Trans.Connector = 1;


% Specify Resource buffers.
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = 2048; % this allows for 1/4 maximum range
Resource.RcvBuffer(1).colsPerFrame = 1; % change to 256 for V256 system
Resource.RcvBuffer(1).numFrames = 1; % minimum size is 1 frame.

% Specify Transmit waveform structure.
% TW(1).type = 'parametric';
% TW(1).Parameters = [2.25,0.67,2,1]; % A, B, C, D
TW(1).type = 'pulseCode';
% TW(1).PulseCode = generateImpulse(1/(4*2.25e6));
TW(1).PulseCode = generateImpulse(3/250e6);

% Specify TX structure array.
TX(1).waveform = 1; % use 1st TW structure.
TX(1).focus = 0;
TX(1).Apod = 1;
TX(1).Delay = 0;

% Specify TGC Waveform structure.
TGC(1).CntrlPts = [500,590,650,710,770,830,890,950];
TGC(1).rangeMax = 250;
TGC(1).Waveform = computeTGCWaveform(TGC);

% Specify Receive structure array -
Receive(1).Apod = 1;
Receive(1).startDepth = 0;
Receive(1).endDepth = 250;
Receive(1).TGC = 1; % Use the first TGC waveform defined above
Receive(1).mode = 0;
Receive(1).bufnum = 1;
Receive(1).framenum = 1;
Receive(1).acqNum = 1;
Receive(1).sampleMode = 'NS200BW';
Receive(1).LowPassCoef = [];
Receive(1).InputFilter = [];

Receive(2) = Receive(1);
Receive(2).mode = 1;

% Specify an external processing event.
Process(1).classname = 'External';
Process(1).method = 'plotSingleElement';
Process(1).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};
n = 1;
% Specify sequence events.
Event(n).info = 'Acquire RF Data.';
Event(n).tx = 1; % use 1st TX structure.
Event(n).rcv = 1; % use 1st Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
Event(n).seqControl = 1;
SeqControl(1).command = 'timeToNextAcq';
SeqControl(1).argument = 50000;
n = n+1;

Event(n).info = 'Set loop count for number of accumulates.';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = 7; % command = 'loopCnt', argument = numAccum-1
SeqControl(7).command = 'loopCnt';
SeqControl(7).argument = 32-2;
n = n+1;

Event(n).info = 'Acquire RF Data.';
Event(n).tx = 1; % use 1st TX structure.
Event(n).rcv = 2; % use 1st Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
n = n+1;

Event(n).info = 'Test loop count - if nz, jmp back to start of accumulates.';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = 8;
SeqControl(8).command = 'loopTst';
SeqControl(8).argument = n-1;
n = n+1;

Event(n).info = 'Transfer to host.';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = 2;
SeqControl(2).command = 'transferToHost';
n = n+1;

Event(n).info = 'Call external Processing function.';
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 1; % call processing function
Event(n).seqControl = [3,4,5]; % wait for data to be transferred
SeqControl(3).command = 'waitForTransferComplete';
SeqControl(3).argument = 2;
SeqControl(4).command = 'markTransferProcessed';
SeqControl(4).argument = 2;
SeqControl(5).command = 'sync';
n = n+1;

Event(n).info = 'Jump back to Event 1.';
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
Event(n).seqControl = 6; % jump back to Event 1
SeqControl(6).command = 'jump';
SeqControl(6).argument = 1;

% Save all the structures to a .mat file.
save('C:\Users\Verasonics\Desktop\Taylor\MatFiles\singleElement_averaging');
