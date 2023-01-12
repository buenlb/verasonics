% doppler256_functionalImaging sets up the necessary structs to run
% continuous imaging of the desired target (set by input target). It also
% runs LEDs to provide visual stimulus during the imaging
% 
% @INPUTS
%   nCycles: number of cycles for each individual imaging pulse
%   imagingTime: time to spend imaging each target. The code will
%     automatically cycle through each target spending imagingTime on each
%     one before moving to the next. It will repeat each target until it
%     has filled the current on or off time correspondin to the LED
%     stimulus (seconds)
%   targets: locations to which to steer imaging pulses. 
%   prf: imaging pulse repitition frequency
%   voltage: voltage at which to image (v)
%   frequency: center frequency for imaging (MHz)
%   ledParams: Struct containing information about the LED stimulus
%     @FIELDS:
%       onTime: length of period in which LEDs are on (seconds)
%       offTime: length of period in which LEDs are off (seconds)
%       prf: pulse repitition frequency of LEDs (Hz)
%       dc: duty cycle of LEDs during on time only (percent)
%       nCycles: number of on/off cycles to perfrom. If set to one there
%           will be one off cycle then one on cycle etc...
%   txSn: Serial number of transducer (defaults to JAB800)

function doppler256_functionalImaging(nCycles, imagingTime, targets, prf, voltage, frequency, ledParams, txSn)

%% Set up path locations
srcDirectory = setPaths();
addpath([srcDirectory,'lib\mrLib'])

%% error check
maxV = 45;
if voltage > maxV
    error(['Voltage is limited to ', num2str(maxV), ' volts'])
end

if ~exist('txSn','var')
    warning('You did not provide a serial number. Assuming JAB800')
    txSn = 'JAB800';
end

% For now, require on and off time to be the same
if ledParams.offTime ~= ledParams.onTime
    error('I have not yet implemented the ability to have on and off time be different')
end

%% Set up imaging parameters
timePerSave = 0.05;
% Require imaging time to be an integer multiple of timePerSave
if mod(imagingTime,timePerSave)
    error(['imagingTime must be an integer multiple of ', num2str(timePerSave)]);
end
nTransmits = prf*timePerSave;
depth = 60e-3;
sampleRate = 20*frequency*1e6; % 10 times nyquist
nSamplesPerPulse = ceil(depth/1540*sampleRate*2); % # of samples acquired during each pulse
lengthOfFrame = 0.05;
nFrames = timePerSave/lengthOfFrame;
nLoops = prf*ledParams.onTime*ledParams.nCycles*2/nTransmits;

%% Specify system parameters
Resource.Parameters.numTransmit = 256; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 256; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.connector = 0; % trans. connector to use (V256).
Resource.Parameters.speedOfSound = 1490; % speed of sound in m/sec

Resource.Parameters.fileIdx = 1;
Resource.Parameters.savePth = 'C:\Users\Verasonics\Desktop\Taylor\Data\functionalImaging\test\';
Resource.Parameters.saveName = 'test1_';
Resource.Parameters.nLoops = nLoops;
Resource.Parameters.imagingTime = imagingTime;
Resource.Parameters.timePerSave = timePerSave;
Resource.Parameters.vIdx = 1;
Resource.Parameters.frequency = frequency;
Resource.Parameters.beamsPerImagingTime = imagingTime/timePerSave;

% Resource.Parameters.verbose = 1;
% Resource.Parameters.simulateMode = 1;

%% Set up longer pulses
% HIFU % The Resource.HIFU.externalHifuPwr parameter must be specified in a
% script using TPC Profile 5 with the HIFU option, to inform the system
% that the script intends to use the external power supply.  This is also
% to make sure that the script was explicitly written by the user for this
% purpose, and to prevent a script intended only for an Extended Transmit
% system from accidentally being used on the HIFU system.
Resource.HIFU.externalHifuPwr = 1;

% HIFU % The string value assigned to the variable below is used to set the
% port ID for the virtual serial port used to control the external HIFU
% power supply.  The port ID was assigned by the Windows OS when it
% installed the SW driver for the power supply; the value assigned here may
% have to be modified to match.  To find the value to use, open the Windows
% Device Manager and select the serial/ COM port heading.  If you have
% installed the driver for the external power supply, and it is connected
% to the host computer and turned on, you should see it listed along with
% the COM port ID number assigned to it.
Resource.HIFU.extPwrComPortID = 'COM5';

Resource.HIFU.psType = 'QPX600DP'; % set to 'QPX600DP' to match supply being used

TPC(5).hv = voltage;
for ii = 1:5
    TPC(ii).maxHighVoltage = maxV;
    TPC(ii).highVoltageLimit = maxV;
    TPC(ii).xmitDuration = 200;
end
%%

% Specify media points
Media.MP(1,:) = [0,0,100,1.0]; % [x, y, z, reflectivity]

% Specify Trans structure array.
Trans = transducerGeometry(0,txSn);
Trans.units = 'mm';
Trans.maxHighVoltage = maxV;
Trans.frequency = frequency;

% Specify Resource buffers.
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = nSamplesPerPulse*2*lengthOfFrame*5e3; % This holds 100 ms of data at a refresh rate of 5kHz. We will only store 50 ms (this has to be set to be too big)
Resource.RcvBuffer(1).colsPerFrame = 256; % change to 256 for V256 system
Resource.RcvBuffer(1).numFrames = nFrames; % minimum size is 1 frame.

nColsPerFrame = ceil(0.05*5e3);

% Specify Transmit waveform structure.
TW.type = 'parametric';
TW.Parameters = [Trans.frequency,0.67,nCycles*2,1]; % A, B, C, D

%% TX struct
xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

elements.x = xTx*1e-3;
elements.y = yTx*1e-3;
elements.z = zTx*1e-3;
            
if size(targets,2)~=3
    error('Targets must be an Nx3 vector');
end
for ii = 1:size(targets,1)
    elements = steerArray(elements,targets(ii,:),frequency,0);
    delays{ii} = [elements.t]';
    TX(ii).waveform = 1; % use 1st TW structure.
    TX(ii).focus = 0;
    TX(ii).Apod = ones(1,256);
    TX(ii).Delay = delays{ii};
end
Resource.Parameters.delays = delays;
%% Specify TGC Waveform structure.
TGC(1).CntrlPts = ones(1,8)*0;
TGC(1).rangeMax = 1;
TGC(1).Waveform = computeTGCWaveform(TGC);

%% Receive
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

acqNum = 1;
for ii = 1:nFrames
    for jj = 1:nColsPerFrame
        Receive(acqNum) = Receive(1);
        Receive(acqNum).acqNum = jj;
        Receive(acqNum).framenum = ii;
        acqNum = acqNum+1;
    end
end

%% External Function
Process(1).classname = 'External';
Process(1).method = 'closeVSX';
Process(1).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

Process(2).classname = 'External';
Process(2).method = 'setLEDs';
Process(2).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

Process(3).classname = 'External';
Process(3).method = 'receiveBeamform';
Process(3).Parameters = {'srcbuffer','receive',... % name of buffer to process.
'srcbufnum',1,...
'srcframenum',1,...
'dstbuffer','none'};

%% Set HIFU TPC
n = 1;
nsc = 1;
Event(n).info = 'select TPC profile 5';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = nsc; % set TPC profile command.
n = n+1;
SeqControl(nsc).command = 'setTPCProfile';
SeqControl(nsc).argument = 5;
SeqControl(nsc).condition = 'immediate';
nsc = nsc + 1;

Event(n).info = 'Sync so that LEDs/Data acquisitino are synchronized';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 2;
Event(n).seqControl = nsc; % set TPC profile command.
SeqControl(nsc).command = 'sync';
nsc = nsc+1;
n = n+1;

for ii = 1:nTransmits
    % Specify sequence events.
    Event(n).info = 'Image.';
    Event(n).tx = 1; % use 1st TX structure.
    Event(n).rcv = ii; % no receive
    Event(n).recon = 0; % no reconstruction.
    Event(n).process = 0; % no processing
    if ii == 1
        Event(n).seqControl = [nsc,nsc+1];
            SeqControl(nsc).command = 'timeToNextAcq';
                SeqControl(nsc).argument = 1/prf*1e6;
                nscTime2Aq = nsc;
                nsc = nsc + 1;
            SeqControl(nsc).command = 'triggerOut';
                nscTrig = nsc;
                nsc = nsc + 1;
        n = n+1;
    elseif ii<nTransmits
        Event(n).seqControl = [nscTime2Aq,nsc];
            SeqControl(nsc).command = 'triggerOut';
                nscTrig = nsc;
                nsc = nsc + 1;
        n = n+1;
    else
        Event(n).seqControl = [nscTime2Aq,nsc,nsc+1];
            SeqControl(nsc).command = 'triggerOut';
                nscTrig = nsc;
                nsc = nsc + 1;
        SeqControl(nsc).command = 'transferToHost';
                nsc = nsc + 1;
        n = n+1;
    end
end

Event(n).info = 'Transfer/Process Data.';
Event(n).tx = 0; % no TX structure.
Event(n).rcv = 0; % no Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 3; % call processing function
Event(n).seqControl = [nsc, nsc+1]; % wait for data to be transferred
    SeqControl(nsc).command = 'waitForTransferComplete';
        SeqControl(nsc).argument = nsc-1;
        nsc = nsc+1;
    SeqControl(nsc).command = 'markTransferProcessed';
        SeqControl(nsc).argument = nsc-2;
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
n = n+1;

% Save all the structures to a .mat file.
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);