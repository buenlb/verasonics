clear all; clc;

HIFU = 1;
%% Set up path locations
srcDirectory = setPaths();

%%
% txSn = 'JAB800'; % Serial number of transducer - necessary for correct geometry
% txSn = 'IHG989';
txSn = 'JEC482';
frequency = 0.65; % Frequency in MHz
focus = [10,0,57]; % Focal location in mm. x is the long axis of the array, y is the short axis, and z is depth
nCycles = 5; % number of cycles with which to excite Tx (can integer multiples of 1/2)
% nCycles = round(300e-3*650e3);
ioChannel = 256;
NA = 1;

% Specify system parameters
Resource.Parameters.numTransmit = 256; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 256; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.connector = 0; % trans. connector to use (V256).
Resource.Parameters.speedOfSound = 1490; % speed of sound in m/sec
Resource.Parameters.numAvg = NA;
Resource.Parameters.ioChannel = ioChannel;
% Resource.Parameters.simulateMode = 1; % runs script in simulate mode

if HIFU
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

    TPC(5).hv = 1.6;
    maxV = 75;
    maxCycles = 12*0.65*1e6;
    for ii = 1:5
        TPC(ii).maxHighVoltage = maxV;
        TPC(ii).highVoltageLimit = maxV;
        TPC(ii).xmitDuration = maxCycles;
    end
end

% Specify media points
Media.MP(1,:) = [0,0,100,1.0]; % [x, y, z, reflectivity]

% Specify Trans structure array.
Trans = transducerGeometry(0,txSn);
Trans.frequency = frequency;
Trans.units = 'mm';
Trans.maxHighVoltage = 80;

TPC(1).hv = 1.6;


% Specify Resource buffers.
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = NA*2048*4; % this allows for 1/4 maximum range
Resource.RcvBuffer(1).colsPerFrame = 1; % change to 256 for V256 system
Resource.RcvBuffer(1).numFrames = 1; % minimum size is 1 frame.

% Specify Transmit waveform structure. 
TW(1).type = 'parametric';
TW(1).Parameters = [Trans.frequency,0.67,nCycles*2,1]; % A, B, C, D
% TW(1).type = 'pulseCode';
% TW(1).PulseCode = generateImpulse(1/(4*0.5e6));
% TW(1).PulseCode = generateImpulse(3/250e6);

% Specify TX structure array.
TX(1).waveform = 1; % use 1st TW structure.
TX(1).focus = 0;
TX(1).Apod = ones(1,256);
% TX(1).Apod(ioChannel) = 1;
TX(1).Apod(ioChannel) = 1;


xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

elements.x = xTx*1e-3;
elements.y = yTx*1e-3;
elements.z = zTx*1e-3;
            
elements = steerArray(elements,focus*1e-3,frequency);
delays = [elements.t]';
TX(1).Delay = delays;
% TX(1).Delay = zeros(1,256);

% Specify TGC Waveform structure.
TGC(1).CntrlPts = ones(1,8)*1023;
TGC(1).rangeMax = 200;
TGC(1).Waveform = computeTGCWaveform(TGC);

% Specify Receive structure array -
Receive(1).Apod = ones(1,256);
Receive(1).startDepth = 0;
Receive(1).endDepth = 100;
Receive(1).TGC = 1; % Use the first TGC waveform defined above
Receive(1).mode = 0;
Receive(1).bufnum = 1;
Receive(1).framenum = 1;
Receive(1).acqNum = 1;
Receive(1).sampleMode = 'custom';
Receive(1).decimSampleRate = 13;
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

n = 1;
nsc = 1;
if HIFU
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
end

% Specify sequence events.
Event(n).info = 'Acquire RF Data.';
Event(n).tx = 1; % use 1st TX structure.
Event(n).rcv = 1; % use 1st Rcv structure.
Event(n).recon = 0; % no reconstruction.
Event(n).process = 0; % no processing
    Event(n).seqControl = [nsc,nsc+1,nsc+2];
    SeqControl(nsc).command = 'timeToNextAcq';
    SeqControl(nsc).argument = 800;
    nscTime2Aq = nsc;
    nsc = nsc + 1;
    SeqControl(nsc).command = 'transferToHost';
    nsc = nsc + 1;
    SeqControl(nsc).command = 'triggerOut';
    SeqControl(nsc).argument = 0;
nscTrig = nsc;
nsc = nsc + 1;
n = n+1;

for ii = 2:NA
    Event(n) = Event(1);
    Event(n).rcv = ii;
    if ~HIFU
        Event(n).seqControl = [nscTime2Aq,nscTrig,nsc];
    else
        Event(n).seqControl = [nscTrig,nsc];
    end
     SeqControl(nsc).command = 'transferToHost';
	   nsc = nsc + 1;
    n = n+1;
end

if ~HIFU
    Event(n).info = 'Call external Processing function.';
    Event(n).tx = 0; % no TX structure.
    Event(n).rcv = 0; % no Rcv structure.
    Event(n).recon = 0; % no reconstruction.
    Event(n).process = 1; % no processing function
    Event(n).seqControl = [nsc,nsc+1,nsc+2]; % wait for data to be transferred
    SeqControl(nsc).command = 'waitForTransferComplete';
    if NA > 1
        SeqControl(nsc).argument = nsc-1;
    else
        SeqControl(nsc).argument = nsc-2;
    end
    SeqControl(nsc+1).command = 'markTransferProcessed';
    if NA > 1
        SeqControl(nsc+1).argument = nsc-1;
    else
        SeqControl(nsc+1).argument = nsc-2;
    end
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
end
Event(n).info = 'Jump back to Event 1.';
    Event(n).tx = 0; % no TX structure.
    Event(n).rcv = 0; % no Rcv structure.
    Event(n).recon = 0; % no reconstruction.
    Event(n).process = 0; % no processing
    Event(n).seqControl = nsc; % jump back to Event 1
    SeqControl(nsc).command = 'jump';
    SeqControl(nsc).condition = 'exitAfterJump';
    if HIFU
        SeqControl(nsc).argument = 2;
    else
        SeqControl(nsc).argument = 1;
    end
% Save all the structures to a .mat file.
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);