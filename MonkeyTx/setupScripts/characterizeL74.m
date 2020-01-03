clear all; close all; clc;

HIFU = 1;

%% Set up path locations
srcDirectory = setPaths();


%%
NA = 1;
ioChannel = 1;

% Specify system parameters
Resource.Parameters.numTransmit = 128; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 128; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.connector = 1; % trans. connector to use (V256).
Resource.Parameters.speedOfSound = 1490; % speed of sound in m/sec
Resource.Parameters.numAvg = NA;
Resource.Parameters.ioChannel = ioChannel;
Resource.Parameters.simulateMode = 0;
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


    % The pairing number is determinded by the following command
    % DO NOT MODIFY! If the transducer can't be recognized, the user needs to be
    % responsible for any modification of the following commands.
    % try [presence, ~, personalityId] = getConnectorInfo();    
    %     switch presence(2)
    %         case 0 % No probe is connected, expect to use fakeScanhead mode
    %             PairingNum = 7;%input('No probe is connected; please enter the pairing number used for fakeScanhead mode: ');
    %             if isempty(PairingNum)
    %                 disp('HIFUPlex exiting; no pairing number specified.')
    %                 clear
    %                 return
    %             end
    %             disp(['Pairing ',num2str(PairingNum),' will be used for fakeScanhead mode'])
    %         case 1 
    %             % Pair is determined by transducer id            
    %             Probe = char(computeTrans(num2str(personalityId(2), '%06X')));            
    %             if isequal(Probe, 'H-104')
    %                 PairingNum = 1;
    %             elseif isequal(Probe, 'H-101')
    %                 PairingNum = 2;
    %             elseif isequal(Probe, 'H-106')
    %                 PairingNum = 3;
    %             elseif isequal(Probe, 'H-313')
    %                 PairingNum = 4;
    %             elseif isequal(Probe, 'H-301')
    %                 PairingNum = 5;
    %             elseif isequal(Probe, 'H-302')
    %                 PairingNum = 6;
    %             elseif isequal(Probe, 'L7-4')
    %                 PairingNum = 7;
    %             else
    %                 fprintf(2, 'Not supported pairing! Please disconnect the transducer and redo the test.\n');
    %                 return
    %             end
    %     end
    % catch
    %     PairingNum = input('Hardware does not exist; please enter the pairing number used for simulation mode: ');
    %     if isempty(PairingNum)
    %         disp('HIFUPlex exiting; no pairing number specified.')
    %         clear
    %         return
    %     end
    %     disp(['Pairing ',num2str(PairingNum),' will be used for simulation'])
    % end
    % 
    % switch PairingNum
    %     case 1
    %         TransName = 'H-104';
    %     case 2
    %         TransName = 'H-101';
    %     case 3
    %         TransName = 'H-106';
    %     case 4
    %         TransName = 'H-313';
    %     case 5
    %         TransName = 'H-301';
    %     case 6
    %         TransName = 'H-302';
    %     case 7
             TransName = 'L7-4';
    %     otherwise
    %         error('Incorrect pairing number!')
    % end
end
% Specify media points
Media.MP(1,:) = [0,0,100,1.0]; % [x, y, z, reflectivity]

% Specify Trans structure array.
Trans.name = 'L7-4';
Trans.frequency = 2.5;
Trans = computeTrans(Trans);
frequency = Trans.frequency;

xTx = Trans.ElementPos(:,2);
yTx = Trans.ElementPos(:,1);
zTx = Trans.ElementPos(:,3);

elements.x = xTx*1e-3;
elements.y = yTx*1e-3;
elements.z = zTx*1e-3;
            
elements = steerArray(elements,[0,0,15]*1e-3,frequency*1e6);
delays = [elements.t]';
% Specify Resource buffers.
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = NA*4096; % this allows for 1/4 maximum range
Resource.RcvBuffer(1).colsPerFrame = 128; % change to 256 for V256 system
Resource.RcvBuffer(1).numFrames = 1; % minimum size is 1 frame.

% Specify Transmit waveform structure.
TW(1).type = 'parametric';
if HIFU
    sonTime = 100; % Sonication time in ms
    numberHalfCycles = sonTime*Trans.frequency*2e3;
else
    numberHalfCycles = 2;
end
TW(1).Parameters = [frequency,0.67,numberHalfCycles,1]; % A, B, C, D
% TW(1).type = 'pulseCode';
% TW(1).PulseCode = generateImpulse(1/(4*2.25e6));
% TW(1).PulseCode = generateImpulse(3/250e6);

% Specify TX structure array.
TX(1).waveform = 1; % use 1st TW structure.
TX(1).focus = 0;
TX(1).Apod = ones(1,128);
TX(1).Delay = delays;

% Specify TGC Waveform structure.
TGC(1).CntrlPts = zeros(1,8);
TGC(1).rangeMax = 250;
TGC(1).Waveform = computeTGCWaveform(TGC);

% TPC(5).highVoltageLimit = 3;

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
if HIFU
    SeqControl(nsc).argument = 1e6;
else
    SeqControl(nsc).argument = 1e4;
end
nscTime2Aq = nsc;
nsc = nsc + 1;
SeqControl(nsc).command = 'transferToHost';
nsc = nsc + 1;
SeqControl(nsc).command = 'triggerOut';
nscTrig = nsc;
nsc = nsc + 1;
n = n+1;

for ii = 2:NA
    nsc
    Event(n) = Event(1);
    Event(n).rcv = ii;
    Event(n).seqControl = [nscTime2Aq,nscTrig,nsc];
     SeqControl(nsc).command = 'transferToHost';
	   nsc = nsc + 1;
    n = n+1;
end

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
