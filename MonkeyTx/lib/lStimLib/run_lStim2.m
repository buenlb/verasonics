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
pause(10)
%% Add relevant paths
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\setupScripts\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\lib\taskLib\')

%% Define System Struct
ledTime = 90;
sys = struct('led_prf',4,'led_dur',10,'timeBefore',ledTime,'timeAfter',ledTime);

% logPath = 'C:\Users\Verasonics\Desktop\Taylor\LStim\';
logPath = 'D:\tmpLStim\';
sys.verasonicsLogName = [logPath,'20230106_Monk'];

% Sonication
sonication = struct('prf',5,'duration',300000,'dc',14.4,'voltage',9,...
    'target',[11,3,56],'nFoci',[0,0,0],'dev',[0,0,0],'frequency',0.48);

sys.sonication = sonication;

%% Set Function Generator
FG694VISA = 'USB0::0x0957::0x2A07::MY52600694::0::INSTR';

if ~exist('fg1','var')
    fg1 = establishKeysightConnection(FG694VISA);
end
if strcmp(fg1.Status, 'closed')
    fopen(fg1);
end

setFgWaveform(fg1,1,'SQU',sys.led_prf/1e6,5e3,2.5e3,50,sys.led_dur*sys.led_prf);
outpOn(fg1,1)
ledsOn = tic;

%% Set Verasonics
% On the actual verasonics this should change to the one that will take an
% enter
% doppler256_neuromodulate2_spotlight(sonication.duration, sonication.voltage, sonication.target,...
%     sonication.prf, sonication.dc, sonication.frequency, sys.verasonicsLogName, 'JAB800',...
%     sonication.dev, sonication.nFoci);

%% Wait timeBefore
while toc(ledsOn)<=sys.timeBefore
end

%% Run verasonics

sonicationTime = tic;
%% Wait timeAfter
while toc(sonicationTime)<sys.timeAfter
end

%% Turn off LEDs
outpOn(fg1,1,'OFF');

fclose(fg1);