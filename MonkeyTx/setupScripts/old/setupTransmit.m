clear; close all; clc;

srcDirectory = setPaths();

%% Setup the transducer
setupVerasonicsStruct;

%% Verasonics Resource Struct
Resource.Parameters.numTransmit = 256;      % number of transmit channels.
Resource.Parameters.numRcvChannels = 256;    % number of receive channels.
Resource.Parameters.speedOfSound = 1540;    % set speed of sound in m/sec before calling computeTrans
Resource.Parameters.verbose = 2;
Resource.Parameters.initializeOnly = 1;
Resource.Parameters.simulateMode = 1;

%% Setup the transmitted waveform
TW(1).type = 'parametric';
waveform = [Trans.frequency,0.667,2,1];
TW(1).Parameters = waveform;

%% Create the Transmit event
TX(1).waveform = 1;
TX(1).Apod = ones(1,Trans.numelements);

%% I have had trouble getting the default Verasonics function to work so this is ignored - I left it here in case it is useful in the future.
if 1
% This is the origin from which you want to steer. Generally this will be
% just the origin of the Tx but if you want to do something fancy (ex: wide
% beam imaging with the focus behind the Tx) setting it to something
% non-zero may be useful.
TX(1).Origin = [0,0,0]; 
TX(1).focus = r/lambda; % The radius of the transducer. r is defined in setupVerasonicsStruct
TX(1).steer = [0*pi/180,0];
TX(1).Delay = computeTXDelays(TX);
end

%% Compute delays with custom function
TX(1).Delay = computeTXDelays_monkey([0,0,r],Trans,Resource);

%% Set up PData in order to visualize transmit
PData.PDelta = ones(1,3);
PData.Size = ceil(2*r/lambda)*ones(1,3);
PData.Origin = [-PData.Size(1)/2,PData.Size(2)/2,0];

%% Receive structure
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

%% Events
% Specify sequence events.
Event(1).info = 'Acquire RF Data.';
Event(1).tx = 1; % use 1st TX structure.
Event(1).rcv = 1; % use 1st Rcv structure.
Event(1).recon = 0; % no reconstruction.
Event(1).process = 0; % no processing
Event(1).seqControl = 1; % transfer data to host
SeqControl(1).command = 'transferToHost';


%% Output resulting MAT file that will be passed to VSX
% Save all the structures to a .mat file.
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);

% showTXPD