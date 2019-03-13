clear all; close all; clc;

%% Set up path locations
srcDirectory = setPaths();

%%
NA = 4;
nFrames = 10;

% Specify system parameters
Resource.Parameters.numTransmit = 1; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 1; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.connector = 1; % trans. connector to use (V256).
Resource.Parameters.speedOfSound = 1490; % speed of sound in m/sec
Resource.Parameters.numAvg = NA;
% Resource.Parameters.simulateMode = 1; % runs script in simulate mode

% Specify media points
Media.MP(1,:) = [0,0,100,1.0]; % [x, y, z, reflectivity]

% Specify Trans structure array.
Trans.name = 'Custom';
Trans.frequency = 5; % not needed if using default center frequency
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
Trans.impedance = 50;
Trans.maxHighVoltage = 96;


% Specify Resource buffers.
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = NA*2048*4; % this allows for 1/4 maximum range
Resource.RcvBuffer(1).colsPerFrame = 1; % change to 256 for V256 system
Resource.RcvBuffer(1).numFrames = nFrames; % minimum size is 1 frame.

% Specify Transmit waveform structure.
TW(1).type = 'parametric';
TW(1).Parameters = [2.25,0.67,1,1]; % A, B, C, D
% TW(1).type = 'pulseCode';
% TW(1).PulseCode = generateImpulse(1/(4*2.25e6));
% TW(1).PulseCode = generateImpulse(3/250e6);

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
firstReceive.Apod = 1;
firstReceive.startDepth = 0;
firstReceive.endDepth = 400;
firstReceive.TGC = 1; % Use the first TGC waveform defined above
firstReceive.mode = 0;
firstReceive.bufnum = 1;
firstReceive.framenum = 1;
firstReceive.acqNum = 1;
firstReceive.sampleMode = 'NS200BW';
firstReceive.LowPassCoef = [];
firstReceive.InputFilter = [];

for ii = 1:nFrames
    for jj = 1:NA
        idx = (ii-1)*NA+jj;
        Receive(idx) = firstReceive;
        Receive(idx).acqNum = jj;
        Receive(idx).framenum = ii;
    end
end

% Specify an external processing event.
Process(1).classname = 'External';
Process(1).method = 'plotSingleElementAveraging';
Process(1).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

% Specify sequence events.
firstEvent.info = 'Acquire RF Data.';
firstEvent.tx = 1; % use 1st TX structure.
firstEvent.rcv = 1; % use 1st Rcv structure.
firstEvent.recon = 0; % no reconstruction.
firstEvent.process = 0; % no processing
firstEvent.seqControl = [1,2];

% Time between acquisitions
SeqControl(1).command = 'timeToNextAcq';
SeqControl(1).argument = 1500;

n = 1;
nsc = 2;
for ii = 1:nFrames
    for jj = 1:NA
        idx = (ii-1)*NA+jj;
        Event(n) = firstEvent;
        Event(n).rcv = idx;
        Event(n).seqControl = [1,nsc];
         SeqControl(nsc).command = 'transferToHost';
           nsc = nsc + 1;
        n = n+1;
    end
    % Wait one second to allow the Aims system time to move.
    Event(n).info = 'Wait for system to move';
    Event(n).tx = 0;
    Event(n).rcv = 0;
    Event(n).recon = 0;
    Event(n).process = 0;
    Event(n).seqControl = [nsc,nsc+1];
        SeqControl(nsc).command = 'noop';
        SeqControl(nsc).argument = 1e6;
        nsc = nsc+1;
        SeqControl(nsc).command = 'triggerOut';
        nsc = nsc+1;
        n = n+1;
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

% Event(n).info = 'Jump back to Event 1.';
% Event(n).tx = 0; % no TX structure.
% Event(n).rcv = 0; % no Rcv structure.
% Event(n).recon = 0; % no reconstruction.
% Event(n).process = 0; % no processing
% Event(n).seqControl = nsc; % jump back to Event 1
% SeqControl(nsc).command = 'jump';
% SeqControl(nsc).argument = 1;

% Save all the structures to a .mat file.
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);
