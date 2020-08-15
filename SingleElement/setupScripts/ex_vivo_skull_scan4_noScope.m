clear all; close all; clc;

%Iterative through-skull characterization of delay and attenuation

%% Set up path locations
srcDirectory = setPaths();

%% User Defined Variables
%TRANSMITCH = 126; %Jan's adapter
%RECEIVECH = 24; %Jan's adapter
TRANSMITCH = 97; %Tom's adapter
RECEIVECH = 1; %Tom's adapter
NA = 64; % Desired number of averages
frequency = 0.5; % Center frequency of the transducer in MHz
samplingRate = 50; % Sampling rate of the pulse/echo data in MHz (max: 50)
saveDir = 'D:\exVivo180Scans\iterative_throughtransmit\skull12522\pos_5\0.5MHz_noskull\'; % Name of the directory in which to save results
% saveDir = 'C:\Users\Verasonics\Desktop\Taylor\Data\exVivo180Scans\20200213\changeVoltageTest2\'; % Name of the directory in which to save results
saveName = 'skull'; % Base name to use when saving files. 
alpha = 5;
%angles = 0 : 1 : 360/alpha; % Vector specifying the angles to use.
angles = -1 : 1 : 20/alpha; % Vector specifying the angles to use.
%angles = 0; % Vector specifying the angles to use.
%excitations = [0,0,1,1,2,2,3,3,4,4,5,5]; % Vector specifying transmits. 0 is an impulse of lambda/8 width. A number smaller than 3 indicates the number of half cycles. 3, 4, 5 generate a chirp with 3, 4, 5 segments.
excitations = [0]; % Vector specifying transmits. 0 is an impulse of lambda/8 width. A number smaller than 3 indicates the number of half cycles. 3, 4, 5 generate a chirp with 3, 4, 5 segments.

%excitationVoltages = 7 * [1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2]; %lower voltages for templates
%excitationVoltages = [32, 96, 32, 96, 32, 96, 32, 96, 32, 96, 32, 96];
switch frequency
    case 2.25
        excitationVoltages = [32, 96, 32, 96, 32, 86, 32, 86, 32, 58, 32, 58]; %2.25MHz
    case 1.0
        excitationVoltages = [32, 75, 32, 76, 32, 39, 14, 38, 13, 26, 13, 26]; %1.0 MHz
    case 0.5
%        excitationVoltages = [20, 39, 20, 39, 20, 20, 20, 20, 14, 14, 14, 14]; %0.5 MHz
        excitationVoltages = [20, 40, 20, 40, 20, 40, 20, 40, 20, 40, 20, 40]; %0.5 MHz
end
excitationVoltages = 20;

%% Specify system parameters
ioChannel = TRANSMITCH; 
Resource.Parameters.numTransmit = 128; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 128; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.connector = 1; % trans. connector to use (V256).
Resource.Parameters.speedOfSound = 1490; % speed of sound in m/sec
Resource.Parameters.numAvg = NA;
Resource.Parameters.ioChannel = ioChannel;
Resource.Parameters.saveDir = saveDir;
Resource.Parameters.saveName = saveName;
Resource.Parameters.angles = angles;
Resource.Parameters.excitations = excitations;
Resource.Parameters.curExcitation = 1;
Resource.Parameters.logFileName = [saveDir,'logFile.mat'];
Resource.Parameters.excitationVoltages = excitationVoltages;
Resource.Parameters.scopeParamFile = {'C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\SingleElement\lib\OscopeParams_transmit1.txt',...
    'C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\SingleElement\lib\OscopeParams_transmit1.txt',...
    'C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\SingleElement\lib\OscopeParams_transmit1.txt',...
    'C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\SingleElement\lib\OscopeParams_transmit2.txt'};
Resource.Parameters.firstAngle = 1;
nTransmits = length(excitations);

% Error checking
if length(excitations) ~= length(excitationVoltages)
    error('Excitations and Excitation Voltages must be the same length!')
end

header = struct('averages',NA,'frequency',frequency,'samplingRate',samplingRate,...
    'saveName',saveName,'angles',angles,'nTransmits',nTransmits,...
    'transmitsComplete',zeros(1,nTransmits),'excitations',excitations);
if exist(Resource.Parameters.logFileName, 'file')
    ovw = input('Overwrite (this action is irreversible)? (0/1)>> ');
    if ovw
        rmdir(saveDir, 's');
    else
        error('Already Exists')
    end
end
mkdir(saveDir);
save(Resource.Parameters.logFileName, 'header')
writeLogFile_exVivoScan(header,[saveDir,'readme.txt']);
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
%Trans.maxHighVoltage = 96;
Trans.maxHighVoltage = min(max(excitationVoltages), 96);


% Specify Resource buffers.
Resource.RcvBuffer(1).datatype = 'int16';
% Resource.RcvBuffer(1).rowsPerFrame = NA*4096*2; % this allows for 1/4 maximum range
Resource.RcvBuffer(1).rowsPerFrame = ceil(samplingRate*2*500/2.25*2*NA)+1; % this allows for 1/4 maximum range
Resource.RcvBuffer(1).colsPerFrame = 1; % change to 256 for V256 system
Resource.RcvBuffer(1).numFrames = 1; % minimum size is 1 frame.

% RcvProfile.AntiAliasCutoff = 50;

%% Specify Transmit waveform structure.
if excitations(1) == 0
    TW(1).type = 'pulseCode';
    TW(1).PulseCode = generateImpulse(1/(8*frequency*1e6));
else %half-waves
    TW(1).type = 'parametric';
    TW(1).Parameters = [frequency,0.67,excitations(1),1]; % A, B, C, D
end
if excitations(1) >= 3 %chirps
    TW(1).type = 'pulseCode';
    TW(1).PulseCode = generateChirp(frequency*1e6, excitations(1));    
end

TW(1).equalize = 0; %remove the DC compensation (this is supposed to help TGC not to overflow through potential DC component)

%% Specify TX structure array.
TX(1).waveform = 1; % use 1st TW structure.
TX(1).focus = 0;
TX(1).Apod = zeros(1,128);
TX(1).Apod(Resource.Parameters.ioChannel) = 1; %receive element
TX(1).Delay = zeros(1,128);

TPC(1).hv = excitationVoltages(1);
% TPC(2).hv = 96;

%% Specify TGC Waveform structure.
TGC(1).CntrlPts = zeros(1,8);
TGC(1).rangeMax = 250;
TGC(1).Waveform = computeTGCWaveform(TGC);

%% Specify Receive structure array -
Receive(1).Apod = zeros(1,128);
Receive(1).Apod([Resource.Parameters.ioChannel, RECEIVECH]) = 1;
Receive(1).startDepth = 0;
Receive(1).endDepth = 500 * frequency/2.25;
Receive(1).TGC = 1; % Use the first TGC waveform defined above
Receive(1).mode = 0;
Receive(1).bufnum = 1;
Receive(1).framenum = 1;
Receive(1).acqNum = 1;
Receive(1).sampleMode = 'custom';
Receive(1).decimSampleRate = samplingRate;
% Receive(1).sampleMode = 'NS200BW';
Receive(1).LowPassCoef = [];
Receive(1).InputFilter = [];

for n = 2:NA
    Receive(n) = Receive(1);
    Receive(n).acqNum = n;
end

RcvProfile.LnaGain = 15;

%% External Processing
Process(1).classname = 'External';
Process(1).method = 'getWaveform_exVivoScan';
Process(1).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

Process(2).classname = 'External';
Process(2).method = 'rotateSkull2';
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

Process(4).classname = 'External';
Process(4).method = 'saveRfDataNoScope_exVivoScan';
Process(4).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

Process(5).classname = 'External';
Process(5).method = 'setExcitationNoScope_exVivoScan2';
Process(5).Parameters = {'srcbuffer','receive',... % name of buffer to process.
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

%% Acquire echoes (with all averages)
for ii = 1:NA
%     Event(n).info = 'Hydrophone';
%     Event(n).tx = 0; % no TX structure.
%     Event(n).rcv = 0; % no Rcv structure.
%     Event(n).recon = 0; % no reconstruction.
%     Event(n).process = 1; 
%     if ii > 1
%         Event(n).seqControl = [nsc,nsc+1];
%             SeqControl(nsc).command = 'waitForTransferComplete';
%                 SeqControl(nsc).argument = nsc-1;
%                 nsc = nsc+1;
%             SeqControl(nsc).command = 'markTransferProcessed';
%                 SeqControl(nsc).argument = nsc-2;
%                 nsc = nsc+1;
%     else
%         Event(n).seqControl = 0;
%     end
%     n = n+1;
%     
%     Event(n).info = 'Wait';
%     Event(n).tx = 0; 
%     Event(n).rcv = 0;
%     Event(n).recon = 0;
%     Event(n).process = 0;
%     Event(n).seqControl = nsc;
%         SeqControl(nsc).command = 'noop';
%         SeqControl(nsc).argument = (1)/200e-9;
%         nsc = nsc+1;
%     n = n+1;
    
    Event(n).info = 'Transmit 1';
    Event(n).rcv = ii;
    Event(n).tx = 1;
    Event(n).recon = 0; % no reconstruction.
    Event(n).process = 0;
    if ii == 1
        Event(n).seqControl = [nsc,nsc+1,nsc+2];
            SeqControl(nsc).command = 'timeToNextAcq';
            SeqControl(nsc).argument = 0.5e3;
                nscTime2Aq = nsc;
                nsc = nsc+1;
            SeqControl(nsc).command = 'triggerOut';
                nscTrig = nsc;
                nsc = nsc+1;
            SeqControl(nsc).command = 'transferToHost';
            nsc = nsc+1;
    else
        Event(n).seqControl = [nscTime2Aq,nscTrig,nsc];
             SeqControl(nsc).command = 'transferToHost';
               nsc = nsc + 1;
    end
    n = n+1;
end
%% Save data from transmit 1
Event(n).info = 'Save RF Data';
Event(n).rcv = 0;
Event(n).tx = 0;
Event(n).recon = 0; % no reconstruction.
Event(n).process = 4;
Event(n).seqControl = [nsc,nsc+1];
    SeqControl(nsc).command = 'waitForTransferComplete';
        SeqControl(nsc).argument = nsc-1;
        nsc = nsc+1;
    SeqControl(nsc).command = 'markTransferProcessed';
        SeqControl(nsc).argument = nsc-2;
        nsc = nsc+1;
n = n+1;    

Event(n).info = 'Set Excitation';
Event(n).tx = 0; % use 1st TX structure.
Event(n).rcv = 0; % use 1st Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 5; 
Event(n).seqControl = nsc;
   SeqControl(nsc).command = 'noop';
        SeqControl(nsc).argument = (1)/200e-9;
        nsc = nsc+1;
n = n+1;

Event(n).info = 'Changing TPC';
Event(n).tx = 0;
Event(n).rcv = 0; % use 1st Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
Event(n).seqControl = nsc;
    SeqControl(nsc).command = 'setTPCProfile';
        SeqControl(nsc).condition = 'immediate';
        SeqControl(nsc).argument = 1;
        nsc = nsc+1;
n = n+1;

%% Make sure enough time has passed for the move to complete
Event(n).info = 'Wait';
Event(n).tx = 0; 
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = [nsc];
    SeqControl(nsc).command = 'noop';
        SeqControl(nsc).argument = (2)/200e-9;
        nsc = nsc+1;
n = n+1;

%% Go back to the beginning
Event(n).info = 'Jump back to Event 2.';
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
Event(n).seqControl = nsc; % jump back to Event 1
SeqControl(nsc).command = 'jump';
SeqControl(nsc).condition = 'exitAfterJump';
SeqControl(nsc).argument = 1;

% Save all the structures to a .mat file.
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);
