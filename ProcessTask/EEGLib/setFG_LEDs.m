FG694VISA = 'USB0::0x0957::0x2A07::MY52600694::0::INSTR';
FG670VISA = 'USB0::0x0957::0x2A07::MY52600670::0::INSTR';

if ~exist('FG670','var')
    FG670 = establishKeysightConnection(FG670VISA);
end
if strcmp(FG670.Status, 'closed')
    fopen(FG670);
end

triggerAmplitude = 10e3;
baselineTime = 30;
%% LEDs (694 Ch 1)
setFgWaveform(FG670,1,'SQU',4e-6,triggerAmplitude,triggerAmplitude/2,'INF',4);
setFgBurstMode(FG670,1,4*baselineTime);
setFgTriggerMode(FG670,1,'BUS',0);

%%
fgTrigger(FG670);