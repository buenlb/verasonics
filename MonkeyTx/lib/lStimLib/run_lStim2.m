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
activate
%% Add relevant paths
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\setupScripts\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\lib\taskLib\')

addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\lStimLib')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\setupScripts\')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\taskLib\')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\lib\')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\ProcessTask\lib')

%% Define Sonication
prf = 200; % Hz
duration = 100; % ms
dc = 50; % %
voltage = 1.6; % V
target = [-11,-3.5,57.5;9,-1.5,58]; % mm referenced to US Tx
frequency = 0.48; % MHz

%% Define parameters specific to gamma measurement
timeBeforeGamma = 5; % time (seconds) to wait before starting US
timeAfterGamma = 5; % time (seconds) after gamma to wait before completing code
nReps = 2; % Number of sonications delivered to each LGN
isiGamma = 8e3; % time between sonication of LGN (note that when both LGNs are stimulated the time between sonications is half of this).

%% Define parameters specific to VEP measurement
led_prf = 4; % Hz
led_dur = 10; % ms
timeBeforeLed = 2; % s
timeAfterLed = 2; % s
isiLed = 700; % ms

%% Which EEG recording system to use
sys.EEGSystem = 'INTAN';

%% Create System Struct
logPath = 'C:\Users\Verasonics\Desktop\Taylor\LStim\';
% logPath = 'D:\tmpLStim\';

% Where to save log Files
sys.verasonicsLogName = [logPath,'test_lstim_vsx.mat'];
sys.logName = [logPath,'test_lstim.mat'];

% Sonication
sonication = struct('prf',prf,'duration',duration,'dc',dc,'voltage',voltage,...
    'target',target,'nFoci',[0,0,0],'dev',[0,0,0],'frequency',frequency);
sys.sonication = sonication;

% Gamma
gammaParams = struct('timeBefore',timeBeforeGamma,'timeAfter',timeAfterGamma,'nReps',nReps,'isi',isiGamma);
sys.gammaParams = gammaParams;

% VEP
vepParams = struct('led_prf',led_prf,'led_dur',led_dur,'timeBefore',timeBeforeLed,'timeAfter',timeAfterLed,'isi',isiLed);
vepParams.nReps = ceil(0.5*60/vepParams.isi);
sys.vepParams = vepParams;

%% Prompt the user to double check parameters and select wich mode to run in.
opts.Interpreter = 'tex';
opts.Default = 'Cancel';
uInput = questdlg({'\bfSonication Details: ',...
    ['\rmEstimated P: ', num2str(sys.sonication.voltage*55.2e-3,2), 'MPa'],...
    ['DC: ', num2str(sys.sonication.dc), '%'],...
    ['Duration: ', num2str(sys.sonication.duration),'ms'],...
    ['PRF: ', num2str(sys.sonication.prf), 'Hz'],...
    ['f: ', num2str(sys.sonication.frequency),'MHz'],...
    ['ISI Gamma: ', num2str(sys.gammaParams.isi/1e3), 's; ISI VEP: ', num2str(sys.vepParams.isi), 's'],...
    ['# Reps Gamma: ', num2str(sys.gammaParams.nReps), ' (', num2str(sys.gammaParams.nReps*sys.gammaParams.isi/60e3,2),...
    ' m); # Reps VEP: ', num2str(sys.vepParams.nReps), ' (', num2str(sys.vepParams.nReps*sys.vepParams.isi/60e3,2), ' m)'],...
    '','Select a protocol to begin. Or, press cancel to modify.'},...
    'Ultrasound Protocol','Begin Gamma','Begin VEPs','Cancel',opts);

% Set wait times
txSn = 'JAB800';
switch uInput
    case 'Begin Gamma'
        beforeTime = sys.gammaParams.timeAfter;
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

%% Set Function Generator
FG694VISA = 'USB0::0x0957::0x2A07::MY52600694::0::INSTR';

if ~exist('fg1','var')
    fg1 = establishKeysightConnection(FG694VISA);
end
if strcmp(fg1.Status, 'closed')
    fopen(fg1);
end

% Set channel 1
setFgWaveform(fg1,1,'SQU',sys.vepParams.led_prf/1e6,5e3,2.5e3,50,sys.vepParams.led_dur*sys.vepParams.led_prf);
outpOn(fg1,2,'off');

% Set channel 2
fgPRF = 2/(isi*1e-3)*1e-6;
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