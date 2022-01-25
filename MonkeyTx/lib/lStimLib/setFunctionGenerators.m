FG694VISA = 'USB0::0x0957::0x2A07::MY52600694::0::INSTR';
FG670VISA = 'USB0::0x0957::0x2A07::MY52600670::0::INSTR';

if ~exist('FG670','var')
    FG670 = establishKeysightConnection(FG670VISA);
end
if ~exist('FG694','var')
    FG694 = establishKeysightConnection(FG694VISA);
end
if strcmp(FG670.Status, 'closed')
    fopen(FG670);
end
if strcmp(FG694.Status, 'closed')
    fopen(FG694);
end

triggerAmplitude = 5e3;

outpOn(FG694,1,'OFF');
outpOn(FG694,2,'OFF');

outpOn(FG670,1,'OFF');
outpOn(FG670,2,'OFF');

%% LEDs (694 Ch 1)
setFgWaveform(FG694,1,'SQU',4e-6,triggerAmplitude,triggerAmplitude/2,50,4);
setFgBurstMode(FG694,1,4*60);
setFgTriggerMode(FG694,1,'BUS',0);

%% Trigger to start US triggers (694 Ch 2)
setFgWaveform(FG694,2,'SQU',0.0111e-6,triggerAmplitude,triggerAmplitude/2,50,4);
setFgBurstMode(FG694,2,1,240);
setFgTriggerMode(FG694,2,'BUS',0);


%% US Trigger (670 ch 1)
setFgWaveform(FG670,1,'SQU',0.5e-6,triggerAmplitude,triggerAmplitude/2,50,5);
setFgBurstMode(FG670,1,30);
setFgTriggerMode(FG670,1,'EXT',17,'POS');

%%

outpOn(FG694,1);
outpOn(FG694,2);

outpOn(FG670,1);
outpOn(FG670,2,'OFF');
return
% setFgTriggerMode(FG694,1,'BUS',0);
% setFgTriggerMode(FG694,2,'BUS',0);

%%
% pause(5);
% fgTrigger(FG694)