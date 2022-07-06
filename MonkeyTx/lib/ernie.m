% Set and run FGs for Ernie
addpath 'C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\lib\lStimLib';

FG694VISA = 'USB0::0x0957::0x2A07::MY52600694::0::INSTR';
FG670VISA = 'USB0::0x0957::0x2A07::MY52600670::0::INSTR';

if ~exist('fg1','var')
    fg1 = establishKeysightConnection(FG670VISA);
end
if ~exist('fg2','var')
    fg2 = establishKeysightConnection(FG694VISA);
end
if strcmp(fg2.Status, 'closed')
    fopen(fg2);
end
if strcmp(fg1.Status, 'closed')
    fopen(fg1);
end
triggerAmplitude = 5e3;

usFrequency = 0.25; % Stimulus frequency (MHz)
usAmplitude = 100; % Stimulus amplitude (mVpp)

baselineLedDuration = 1*60;
postUsDuration = (1+0)*60;

%% Set up function generators for LED stim+US Stim
% FG 1
% Set channel 1 to do LEDs
setFgWaveform(fg1,1,'SQU',2e-6,triggerAmplitude,triggerAmplitude/2,50,2);
setFgBurstMode(fg1,1,(baselineLedDuration+postUsDuration)*2,0);
setFgTriggerMode(fg1,1,'BUS',0);

% Set channel 2 to trigger US
setFgWaveform(fg1,2,'SQU',1e-6,triggerAmplitude,triggerAmplitude/2,50,10);
setFgBurstMode(fg1,2,60,0);
setFgTriggerMode(fg1,2,'BUS',baselineLedDuration*1e3);

outpOn(fg1,1);
outpOn(fg1,2);

% FG 2
% Set channels 1 and 2 to be US signal
setFgWaveform(fg2,1,'SIN',usFrequency,usAmplitude,0,50);
setFgBurstMode(fg2,1,ceil(usFrequency*0.1*1e6),0);
setFgTriggerMode(fg2,1,'EXT',0);

setFgWaveform(fg2,2,'SIN',usFrequency,usAmplitude,0,50);
setFgBurstMode(fg2,2,ceil(usFrequency*0.1*1e6),0);
setFgTriggerMode(fg2,2,'EXT',0);

outpOn(fg2,1);
outpOn(fg2,2);