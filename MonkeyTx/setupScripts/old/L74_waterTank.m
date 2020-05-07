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

function [Trans,TW] = L74_waterTank(delays,savePath,saveName)
if nargin == 1 || nargin == 2
    error('If you supply delays you must also supply a savePath and saveName!')
end
%% Set up path locations
srcDirectory = setPaths();

%%
NA = 1;
ioChannel = 1;

% Specify system parameters
Resource.Parameters.numTransmit = 128; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 128; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.speedOfSound = 1490; % speed of sound in m/sec
Resource.Parameters.numAvg = NA;
Resource.Parameters.ioChannel = ioChannel;
Resource.Parameters.gridInfoFile = 'C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\setupScripts\gridInfo.mat';
if nargin > 1
    Resource.Parameters.saveDir = savePath;
    Resource.Parameters.saveName = saveName;
end
% Resource.Parameters.simulateMode = 1; % runs script in simulate mode

% Specify media points
Media.MP(1,:) = [0,0,100,1.0]; % [x, y, z, reflectivity]

% Specify Trans structure array.
Trans.name = 'L7-4';
Trans = computeTrans(Trans);
frequency = Trans.frequency;

% Specify Resource buffers.
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = NA*4096; % this allows for 1/4 maximum range
Resource.RcvBuffer(1).colsPerFrame = 1; % change to 256 for V256 system
Resource.RcvBuffer(1).numFrames = 1; % minimum size is 1 frame.

% Specify Transmit waveform structure.
TW(1).type = 'parametric';
numberHalfCycles = 2;
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
TX(1).Apod = ones(1,128);
TX(1).Delay = delays;

TPC(1).hv = 30;

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
SeqControl(nsc).argument = 0.1e6;
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
SeqControl(nsc).argument = 2;

% Save all the structures to a .mat file.
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);

