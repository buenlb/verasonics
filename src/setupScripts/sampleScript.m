clear all
% Specify system parameters
Resource.Parameters.numTransmit = 128; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 128; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.connector = 1; % trans. connector to use (V256).
Resource.Parameters.speedOfSound = 1540; % speed of sound in m/sec
Resource.Parameters.simulateMode = 1; % runs script in simulate mode
% Specify media points
Media.MP(1,:) = [0,0,100,1.0]; % [x, y, z, reflectivity]
% Specify Trans structure array.
Trans.name = 'L11-4v';
Trans.frequency = 6.25; % not needed if using default center frequency
Trans = computeTrans(Trans); % L7-4 transducer is 'known' transducer.
% Specify Resource buffers.
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = 2048; % this allows for 1/4 maximum range
Resource.RcvBuffer(1).colsPerFrame = 128; % change to 256 for V256 system
Resource.RcvBuffer(1).numFrames = 1; % minimum size is 1 frame.
% Specify Transmit waveform structure.
TW(1).type = 'parametric';
TW(1).Parameters = [6.25,0.67,2,1]; % A, B, C, D
% Specify TX structure array.
TX(1).waveform = 1; % use 1st TW structure.
TX(1).focus = 0;
TX(1).Apod = ones(1,Trans.numelements);
TX(1).Delay = computeTXDelays(TX(1));
% Specify TGC Waveform structure.
TGC(1).CntrlPts = [500,590,650,710,770,830,890,950];
TGC(1).rangeMax = 200;
TGC(1).Waveform = computeTGCWaveform(TGC);
% Specify Receive structure array -
Receive(1).Apod = ones(1,128); %V64, ones(1,64); V64LE [ones(1,64) zeros(1,64)];
Receive(1).startDepth = 0;
Receive(1).endDepth = 200;
Receive(1).TGC = 1; % Use the first TGC waveform defined above
Receive(1).mode = 0;
Receive(1).bufnum = 1;
Receive(1).framenum = 1;
Receive(1).acqNum = 1;
Receive(1).sampleMode = 'NS200BW';
Receive(1).LowPassCoef = [];
Receive(1).InputFilter = [];
% Specify sequence events.
Event(1).info = 'Acquire RF Data.';
Event(1).tx = 1; % use 1st TX structure.
Event(1).rcv = 1; % use 1st Rcv structure.
Event(1).recon = 0; % no reconstruction.
Event(1).process = 0; % no processing
Event(1).seqControl = 1; % transfer data to host
SeqControl(1).command = 'transferToHost';
% Save all the structures to a .mat file.
save('C:\Users\Taylor\Documents\Projects\MonkeyTx\sampleScript.mat');