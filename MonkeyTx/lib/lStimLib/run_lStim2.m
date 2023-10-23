% Run an LSTIM experiment. The parameters of the experiment are set by the
% system struct, sys, whose fields are described below.
% 
% @FIELDS
%   led_prf: PRF of LED stimulus in Hz (usually 2 or 4 Hz)
%   led_dur: Duration of each individual LED stimulus in ms(~10 ms)
%   timeBefore: Time (seconds) to wait between start of LED stimulus and 
%       delivery of US. NOTE: This is not exact - the US and LED will not 
%       be synchronized. Rather, this is how long the system will wait 
%       before beginning the sonication. Thus, this is a minimum time
%   timeAfter: time after sonication is completed before stopping LED
%       stimulus. The same note applies as provided in timeBefore
%   sonication: Struct containing details of the sonication
%       @FIELDS in sonication
%           prf: Pulse repitition frequency
%           duration: Overall duration of sonication in ms
%           dc: Duty cycle of US stimulus
%           voltage: desired voltage of US stimulus
%           target: x,y,z coordinates (mm) referenced to the US Tx
%           nFoci: number of targets in x,y,z locations
%           dev: deviation from central target if there is more than one
%               focus
%           frequency: central frequency of US stimulus (MHz)
%   verasonicsLogName: File name of log file output by
%      doppler256_neuromodulate2_spotlight.m.
% 
% Taylor Webb
% University of Utah
% January, 2023

%% Clear workspace to prepare
clear all; close all; clc;
% activate
%% Add relevant paths
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\setupScripts\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\lib\taskLib\')

addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\lStimLib')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\setupScripts\')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\taskLib\')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\lib\')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\ProcessTask\lib')

%% Define Sonication
%---------Target1--------                        --------Target2---------                        --Target1...
%-------------------------------------------------ISI--------------------------------------------
%------------PRF-------------
%--DC---
%----------Duration----------
%|||----|||----|||----|||------------------------|||----|||----|||----|||------------------------|||----...
prf = 10000; % Hz
duration = 100; % ms
dc = 50; % %
voltage = 1.93e3/55.2; % V
target = [-9.5,6,57;13.5,6,56]; % mm; referenced to US Tx
frequency = 0.48; % MHz

% Sonication parameters for BBB opening
% prf = 200; % Hz
% duration = 30; % ms
% dc = 100; % %
% voltage = 1.5e3/55.2; % V
% target = [-9.5,6,57;-9.5,6,57]; % mm; referenced to US Tx
% frequency = 0.48; % MHz

%% Define parameters specific to gamma measurement
timeBeforeGamma = 60; % time (seconds) to wait before starting US
timeAfterGamma = 120; % time (seconds) after gamma to wait before completing code
nReps = 40; % Number of sonications delivered to each LGN

% Note that the code uses a the sequence control command timeToNextAq to
% set the time between sonication of the left/right LGN. timeToNextAq is
% limited to ~4.2 seconds (see Verasonics documentation). Thus the maximum
% ISI time is 8.38 seconds. The setup script will throw an error if a 
% longer time is requested. 
isiGamma = 8000; % ms; time between sonication of LGN (note that when both LGNs are stimulated the time between sonications is half of this).

% Parameters for BBB Sonication
% isiGamma = 8000;
% isiGamma = 600; % BBB sonication
% nReps = ceil(60/(isiGamma*1e-3));

%% Define parameters specific to VEP measurement
led_prf = 2; % Hz
led_dur = 10; % ms
timeBeforeLed = 60; % s
timeAfterLed = 120; % s
isiLed = 6970; % ms

%% Which EEG recording system to use
sys.EEGSystem = 'INTAN';

%% Create System Struct
logPath = 'C:\Users\Verasonics\Desktop\Taylor\LStim\calvin20230330\';
% logPath = 'D:\tmpLStim\';

% Where to save log Files
sys.verasonicsLogName = [logPath,'calvin20230330_verasonicsParams.mat'];
sys.logName = [logPath,'calvin20230330.mat'];
% sys.logName = [logPath,'pre_session_system_test'];

% Sonication
sonication = struct('prf',prf,'duration',duration,'dc',dc,'voltage',voltage,...
    'target',target,'nFoci',[0,0,0],'dev',[0,0,0],'frequency',frequency);
sys.sonication = sonication;

% Gamma
gammaParams = struct('timeBefore',timeBeforeGamma,'timeAfter',timeAfterGamma,'nReps',nReps,'isi',isiGamma);
sys.gammaParams = gammaParams;

% VEP
vepParams = struct('led_prf',led_prf,'led_dur',led_dur,'timeBefore',timeBeforeLed,'timeAfter',timeAfterLed,'isi',isiLed);
vepParams.nReps = ceil(3*60e3/vepParams.isi);
sys.vepParams = vepParams;

%% Compute the energy used so far and the energy for the current sonication
if exist(sys.logName,'file')
    tmp = load(sys.logName);
    logSys = tmp.logSys;
    runningEnergy = 0;
    for ii = 1:length(logSys)
        if strcmp(logSys(ii).protocol,'Gamma')
            [~,curVss] = lStimEnergy(logSys(ii).sonication.dc,...
                logSys(ii).gammaParams.isi,logSys(ii).sonication.voltage*55.2*1e3,logSys(ii).sonication.duration,...
                logSys(ii).gammaParams.isi*logSys(ii).gammaParams.nReps*1e-3);
            runningEnergy = runningEnergy + curVss;
        elseif strcmp(logSys(ii).protocol,'VEPs')
            [~,curVss] = lStimEnergy(logSys(ii).sonication.dc,...
                logSys(ii).vepParams.isi,logSys(ii).sonication.voltage*55.2*1e3,logSys(ii).sonication.duration,...
                logSys(ii).vepParams.isi*logSys(ii).vepParams.nReps*1e-3);
            runningEnergy = runningEnergy + curVss;
        else
            error('Unrecognized Type!')
        end
    end
else
    runningEnergy = 0;
end

[isptaGamma,vssGamma,isptaGammaSkull] = lStimEnergy(sys.sonication.dc,...
                sys.gammaParams.isi,sys.sonication.voltage*55.2*1e3,sys.sonication.duration,...
                sys.gammaParams.isi*sys.gammaParams.nReps*1e-3);
[isptaVep,vssVep,isptaVepSkull] = lStimEnergy(sys.sonication.dc,...
                sys.vepParams.isi,sys.sonication.voltage*55.2*1e3,sys.sonication.duration,...
                sys.vepParams.isi*sys.vepParams.nReps*1e-3);
%% Prompt the user to double check parameters and select wich mode to run in.
opts.Interpreter = 'tex';
opts.Default = 'Cancel';
uInput = questdlg({['Using ',sys.EEGSystem],'','\bfSonication Details: ',...
    ['\rmEstimated P: ', num2str(sys.sonication.voltage*55.2e-3,2), 'MPa'],...
    ['DC: ', num2str(sys.sonication.dc), '%'],...
    ['Duration: ', num2str(sys.sonication.duration),'ms'],...
    ['PRF: ', num2str(sys.sonication.prf), 'Hz'],...
    ['f: ', num2str(sys.sonication.frequency),'MHz'],...
    ['ISI Gamma: ', num2str(sys.gammaParams.isi/1e3), 's; ISI VEP: ', num2str(sys.vepParams.isi/1e3), 's'],...
    ['# Reps Gamma: ', num2str(sys.gammaParams.nReps), ' (', num2str(sys.gammaParams.nReps*sys.gammaParams.isi/60e3,2),...
    ' m); # Reps VEP: ', num2str(sys.vepParams.nReps), ' (', num2str(sys.vepParams.nReps*sys.vepParams.isi/60e3,2), ' m)'],...
    '','Select a protocol to begin. Or, press cancel to modify.',...
    '','\bfSafety',['\rmIspta (gamma):', num2str(isptaGamma,2), 'w/cm^2; (VEP): ', num2str(isptaVep,2),'w/cm^2'],...
    ['Ispta_{Skull} (gamma): ', num2str(isptaGammaSkull,2), 'w/cm^2; (VEP): ', num2str(isptaVepSkull,2),'w/cm^2']...
    ['V^2s (gamma):',num2str(vssGamma,4),'V^2s; (VEP): ', num2str(vssVep,4),'V^2s'],...
    '',['You have ', num2str(28843-runningEnergy,5),'V^2s remaining.']},...
    'Ultrasound Protocol','Begin Gamma','Begin VEPs','Cancel',opts);
return
% Set wait times
txSn = 'JAB800';
switch uInput
    case 'Begin Gamma'
        beforeTime = sys.gammaParams.timeBefore;
        afterTime = sys.gammaParams.timeAfter;
        type = 'Gamma';
        isi = sys.gammaParams.isi;
        
        lStim(sonication.target, isi, sys.gammaParams.nReps, sonication.prf,...
            sonication.dc, sonication.duration, sonication.voltage, sonication.frequency,...
            sys.verasonicsLogName, txSn);
    case 'Begin VEPs'
        beforeTime = sys.vepParams.timeBefore;
        afterTime = sys.vepParams.timeAfter;
        type = 'VEPs';
        isi = sys.vepParams.isi;

        lStim(sonication.target, isi, sys.vepParams.nReps, sonication.prf,...
            sonication.dc, sonication.duration, sonication.voltage, sonication.frequency,...
            sys.verasonicsLogName, txSn);
    otherwise
        return
end
return
%% Set Function Generator
FG694VISA = 'USB0::0x0957::0x2A07::MY52600694::0::INSTR';
% FG694VISA = 'USB0::0x0957::0x2A07::MY52600670::0::INSTR';

if ~exist('fg1','var')
    fg1 = establishKeysightConnection(FG694VISA);
end
if strcmp(fg1.Status, 'closed')
    fopen(fg1);
end

% Set channel 1
setFgWaveform(fg1,1,'SQU',sys.vepParams.led_prf/1e6,5e3,2.5e3,50,sys.vepParams.led_dur*sys.vepParams.led_prf*100*1e-3);
outpOn(fg1,2,'off');

% Set channel 2
fgPRF = 2.1/(isi*1e-3)*1e-6;
if strcmp(sys.EEGSystem,'INTAN')
    setFgWaveform(fg1,2,'SQU',fgPRF,3.3e3,1.65e3,'INF',sonication.duration*1e-3*fgPRF*1e6*100);
elseif strcmp(sys.EEGSystem,'BCI')
    setFgWaveform(fg1,2,'SQU',fgPRF,3.3e3,1.65e3,'INF',sonication.duration*1e-3*fgPRF*1e6*100);
else
    fclose(fg1);
    error([sys.EEGSystem, ' is not a recognized EEG system.'])
end

setFgBurstMode(fg1,2,1);
setFgTriggerMode(fg1,2,'EXT',0,'NEG'); 

outpOn(fg1,2);

%% Run verasonics
waitfor(msgbox(['Press OK when EEG system is active. The system will wait ', num2str(beforeTime), ' s and then launch VSX.']));

% Save status
sys.startTime = datestr(now);
sys.protocol = type;
if exist(sys.logName,'file')
    tmp = load(sys.logName);
    logSys = tmp.logSys;
    logSys(end+1) = sys;
else
    logSys = sys;
end
save(sys.logName,'logSys');

% Start LEDs if doing VEPs
if strcmp(type,'VEPs')
    outpOn(fg1,1);
end

startTime = tic;

% Wait for baseline
disp(['Baseline period: ', num2str(beforeTime), 's']);
while toc(startTime)<=beforeTime
end

% Run US
disp('Launching VSX!')
save tmpBeforeVSX.mat
filename = 'lStim.mat';
VSX;
load tmpBeforeVSX.mat

% Wait post time
if ~isnan(afterTime)
    disp(['Post period: ', num2str(afterTime), 's']);
    postTime = tic;
    while toc(postTime)<=afterTime
    end
else
    return
end

outpOn(fg1,1,'off');
outpOn(fg1,2,'off');
fclose(fg1);