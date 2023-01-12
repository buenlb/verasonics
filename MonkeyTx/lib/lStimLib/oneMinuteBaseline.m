FG694VISA = 'USB0::0x0957::0x2A07::MY52600670::0::INSTR';
% FG670VISA = 'USB0::0x0957::0x2A07::MY52600670::0::INSTR';

% if ~exist('fg2','var')
%     fg2 = establishKeysightConnection(FG670VISA);
% end
if ~exist('fg1','var')
    fg1 = establishKeysightConnection(FG694VISA);
end
% if strcmp(fg2.Status, 'closed')
%     fopen(fg2);
% end
if strcmp(fg1.Status, 'closed')
    fopen(fg1);
end
triggerAmplitude = 5e3;

%% 1 minute baseline
% Set channel 1 to do LEDs
setFgWaveform(fg1,1,'SQU',2e-6,triggerAmplitude,triggerAmplitude/2,50,2);
setFgBurstMode(fg1,1,2*60);
setFgTriggerMode(fg1,1,'BUS',0);
fgTrigger(fg1,1);
pause(60.1);