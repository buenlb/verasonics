% This script does a series of focused transmit receives in order to form
% an image of the scanned grid. The image will be L x M x N where L, M, and
% N are the length of the vectors x, y, and, z which define the desired
% transmit focal spots.
% 
% @USER DEFINED VARIABLES
%   x: x locations to include in the image in mm
%   y: y locations to include in the image in mm
%   z: z locations to include in the image in mm
%   frequency: Transmit frequency (f0=0.65 MHs, half pressure bandwidth 
%       ~0.35-0.95 MHz)
%   nCycles: Number of cycles to use on excitation. Can be integer multiple
%       of 1/2
%   initialV: Initial peak voltage (only voltage between 1.6 and 20 V is 
%       allowed)
%   imageSaveName: Full path to the place in which to save the image data.
%       This gets used by displayResults_focalImage.m
% 
% Taylor Webb
% University of Utah
% February 2020

%% Start Fresh
% clear all; close all; clc; %#ok<CLALL>

%% User Defined Variables
% x = -8:0.25:-2;
% y = -0.25:0.25:0;
% z = 41:0.25:48;
% imageSaveName = 'C:\Users\Verasonics\Desktop\Taylor\Data\FocalImages\20200205\testImage1.mat';
frequency = 0.65; 
nCycles = 5;
initialV = 16;

%% Set up path locations
srcDirectory = setPaths();

%% Resource Struct
Resource.Parameters.numTransmit = 256; % no. of xmit chnls
Resource.Parameters.numRcvChannels = 256; 
Resource.Parameters.connector = 0; % trans. connector to use (V256).
Resource.Parameters.speedOfSound = 1490; % speed of sound in m/sec
Resource.Parameters.x = x;
Resource.Parameters.y = y;
Resource.Parameters.z = z;
Resource.Parameters.curIdx = 1;
Resource.Parameters.imageSaveName = imageSaveName;
Resource.Parameters.img = zeros(length(x),length(y),length(z));

%% Transducer Struct
Trans = transducerGeometry(0);
Trans.frequency = frequency;
Trans.units = 'mm';
Trans.maxHighVoltage = 32;

%% Transmit
% Waveform
TW(1).type = 'parametric';
TW(1).Parameters = [Trans.frequency,0.67,nCycles*2,1]; % A, B, C, D

% Transmit
TX(1).waveform = 1; % use 1st TW structure.
TX(1).focus = 0;
TX(1).Apod = ones(1,256);

%Find Element positions for delays
xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

elements.x = xTx*1e-3;
elements.y = yTx*1e-3;
elements.z = zTx*1e-3;

% Populate transmit events for first row of each y-plane
idx = 1;
for ii = 1:length(x)
    for jj = 1:length(y)
        TX(idx) = TX(1);
        elements = steerArray(elements,[x(ii),y(jj),z(1)]*1e-3,frequency,0);
        delays = [elements.t]';
        TX(idx).Delay = delays;
        idx = idx+1;
    end
end

% Initial voltage
TPC(1).hv = initialV;
TPC(1).highVoltageLimit = 33;

%% Receive
% Buffers
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = length(x)*length(y)*1350; % this allows for 1/4 maximum range
Resource.RcvBuffer(1).colsPerFrame = 1; % change to 256 for V256 system
Resource.RcvBuffer(1).numFrames = 1; % minimum size is 1 frame.

% Time Gain Control
TGC(1).CntrlPts = ones(1,8)*1023;
TGC(1).rangeMax = 200;
TGC(1).Waveform = computeTGCWaveform(TGC);

% Revceive Details
Receive(1).Apod = ones(1,256);
Receive(1).startDepth = 0;
Receive(1).endDepth = 33;
Receive(1).TGC = 1; % Use the first TGC waveform defined above
Receive(1).mode = 0;
Receive(1).bufnum = 1;
Receive(1).framenum = 1;
Receive(1).acqNum = 1;
Receive(1).sampleMode = 'NS200BW';
Receive(1).LowPassCoef = [];
Receive(1).InputFilter = [];

% Populate out Receives for the first row of each y-plane
for ii = 1:length(x)*length(y)
    Receive(ii) = Receive(1);
    Receive(ii).acqNum = ii;
end

%% External Function
Process(1).classname = 'External';
Process(1).method = 'setDelays_focalImage';
Process(1).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

Process(2).classname = 'External';
Process(2).method = 'displayResults_focalImage';
Process(2).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

%% Events
n = 1;
nsc = 1;
SeqControl(nsc).command = 'timeToNextAcq';
    SeqControl(nsc).argument = 160;
    nscTime2Aq = nsc;
    nsc = nsc + 1;
SeqControl(nsc).command = 'triggerOut';
    nscTrig = nsc;
    nsc = nsc + 1;
for ii = 1:length(x)*length(y)
    Event(n).info = 'Transmit/Receive Voxel';
    Event(n).tx = ii; 
    Event(n).rcv = ii;
    Event(n).recon = 0;
    Event(n).process = 0;
    if ii > 1
        Event(n).seqControl = [nscTime2Aq,nscTrig,nsc,nsc+1,nsc+2];
            SeqControl(nsc).command = 'waitForTransferComplete';
                SeqControl(nsc).argument = nsc-1;
                nsc = nsc+1;
            SeqControl(nsc).command = 'markTransferProcessed';
                SeqControl(nsc).argument = nsc-2;
                nsc = nsc+1;
            SeqControl(nsc).command = 'transferToHost';
                nsc = nsc + 1;
    else
        Event(n).seqControl = [nscTime2Aq,nscTrig,nsc];
            SeqControl(nsc).command = 'transferToHost';
                nsc = nsc + 1;
    end
    n = n+1;
end

Event(n).info = 'Record and Display Result.';
Event(n).tx = 0; 
Event(n).rcv = 0; 
Event(n).recon = 0;
Event(n).process = 2;
Event(n).seqControl = 0; % wait for data to be transferred
SeqControl(nsc).command = 'waitForTransferComplete';
    SeqControl(nsc).argument = nsc-1;
    nsc = nsc+1;
n = n+1;

Event(n).info = 'Set Delays';
Event(n).tx = 0; % use 1st TX structure.
Event(n).rcv = 0; % use 1st Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 1; % no processing
Event(n).seqControl = 0;
    SeqControl(nsc).command = 'markTransferProcessed';
    SeqControl(nsc).argument = nsc-2;
    nsc = nsc+1;
n = n+1;
    
Event(n).info = 'Jump back to Event 1.';
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
Event(n).seqControl = [nsc, nsc+1]; % jump back to Event 1
    SeqControl(nsc).command = 'jump';
        SeqControl(nsc).condition = 'exitAfterJump';
        SeqControl(nsc).argument = 1;
        nsc = nsc+1;
    SeqControl(nsc).command = 'sync';
        nsc = nsc+1;
n = n+1;

%% Save Results
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);