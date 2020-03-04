% This script acquires an image by using a 3x3 grid to steer around and
% image several focal spots. It iterates through all possible 3x3 grids on
% the monkey transducer. The half power beam width with that grid size is
% roughly 5 mm so that is the spacing of the beams in the axial dimension.
% The depth dimension is primarily a function of the pulse width which is
% also around 5 mm so the we acquire a uniform grid.
% 
% Taylor Webb
% University of Utah
% March 2020

clear all; close all; clc;
%% Set up path locations
srcDirectory = setPaths();
addpath([srcDirectory,'lib\griddedImage']); % Adds library functions specific to this script

%% User Defined Variables
frequency = 0.65; % Frequency in MHz
nCycles = 1/2; % number of cycles with which to excite Tx (can integer multiples of 1/2). If zero an impulse (1/8 of the period) will be used.
focalSpotsXY = -12.5:5:12.5; % The x,y locations relative to the center of the grid that should be scanned by each grid.
focalSpotsZ = 30:5:40; % The z locations relative to the center of the grid that should be scanned by each grid.

%% Specify system parameters
Resource.Parameters.numTransmit = 256; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 256; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.connector = 0; % trans. connector to use (V256).
Resource.Parameters.speedOfSound = 1490; % speed of sound in m/sec

blocks = selectElementBlocks(3);
% blocks = blocks(87);

% Specify media points
Media.MP(1,:) = [0,0,100,1.0]; % [x, y, z, reflectivity]

%% Specify Trans structure array.
Trans = transducerGeometry(0);
Trans.units = 'mm';
Trans.maxHighVoltage = 10;
Trans.frequency = frequency;

TPC(1).hv = 10;

%% Specify Resource buffers.
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = length(focalSpotsXY)^2*length(focalSpotsZ)*2048*4; % this allows for 1/4 maximum range
Resource.RcvBuffer(1).colsPerFrame = 256; % change to 256 for V256 system
Resource.RcvBuffer(1).numFrames = 1; % minimum size is 1 frame.

%% Specify Transmit waveform structure
if nCycles
    TW(1).type = 'parametric';
    TW(1).Parameters = [Trans.frequency,0.67,nCycles*2,1]; % A, B, C, D
else
    TW(1).type = 'pulseCode';
    TW(1).PulseCode = generateImpulse(1/(8*frequency*1e6));
end

% Specify TX structure array.
TX(1).waveform = 1; % use 1st TW structure.
TX(1).focus = 0;
TX(1).Apod = zeros(1,256);
delays = zeros(1,256);
TX(1).Delay = delays;

idx = 1;
for ii = 1:length(focalSpotsXY)
    for jj = 1:length(focalSpotsXY)
        for kk = 1:length(focalSpotsZ)
            TX(idx) = TX(1);
            TX(idx).Apod = zeros(1,256);
            TX(idx).Apod(blocks{1}) = 1;

            xTx = Trans.ElementPos(blocks{1},1);
            yTx = Trans.ElementPos(blocks{1},2);
            zTx = Trans.ElementPos(blocks{1},3);

            elements.x = xTx*1e-3;
            elements.y = yTx*1e-3;
            elements.z = zTx*1e-3;

            elements = steerArray(elements,...
                [focalSpotsXY(ii),focalSpotsXY(jj),focalSpotsZ(kk)]*1e-3,...
                frequency,0);

            delays(blocks{1}) = [elements.t]';
            TX(idx).Delay = delays;

            idx = idx+1;
        end
    end
end

%% Specify TGC Waveform structure.
TGC(1).CntrlPts = ones(1,8)*0;
TGC(1).rangeMax = 1;
TGC(1).Waveform = computeTGCWaveform(TGC);

%% Specify Receive structure array -
Receive(1).Apod = ones(1,256);
Receive(1).startDepth = 0;
Receive(1).endDepth = 20;
Receive(1).TGC = 1; % Use the first TGC waveform defined above
Receive(1).mode = 0;
Receive(1).bufnum = 1;
Receive(1).framenum = 1;
Receive(1).acqNum = 1;
Receive(1).sampleMode = 'custom';
Receive(1).decimSampleRate = 20*Trans.frequency;
Receive(1).LowPassCoef = [];
Receive(1).InputFilter = [];

for ii = 1:length(focalSpotsXY)^2*length(focalSpotsZ)
    Receive(ii) = Receive(1);
    Receive(ii).acqNum = ii;
end

% Specify an external processing event.
% Specify an external processing event.
Process(1).classname = 'External';
Process(1).method = 'updateTransmit_elementGrids';
Process(1).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

% Specify an external processing event.
% Specify an external processing event.
Process(2).classname = 'External';
Process(2).method = 'processImage_elementGrids';
Process(2).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

%% Specify sequence events.
n = 1;
nsc = 1;

% Acquire Data
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

for ii = 2:length(TX)
    Event(n) = Event(1);
    Event(n).rcv = ii;
    Event(n).tx = ii;
    Event(n).seqControl = [nscTime2Aq,nscTrig,nsc];
     SeqControl(nsc).command = 'transferToHost';
       nsc = nsc + 1;
    n = n+1;
end

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

% Save all the structures to a .mat file.
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);