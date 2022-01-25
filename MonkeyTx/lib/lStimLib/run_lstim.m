function run_lstim(voltage, target, dc)

FG694VISA = 'USB0::0x0957::0x2A07::MY52600694::0::INSTR';
FG670VISA = 'USB0::0x0957::0x2A07::MY52600670::0::INSTR';

if ~exist('fg2','var')
    fg2 = establishKeysightConnection(FG670VISA);
end
if ~exist('fg1','var')
    fg1 = establishKeysightConnection(FG694VISA);
end
if strcmp(fg2.Status, 'closed')
    fopen(fg2);
end
if strcmp(fg1.Status, 'closed')
    fopen(fg1);
end
triggerAmplitude = 5e3;

% Set channel 1 to do LEDs
setFgWaveform(fg1,1,'SQU',4e-6,triggerAmplitude,triggerAmplitude/2,50,4);
setFgBurstMode(fg1,1,4*30);
setFgTriggerMode(fg1,1,'BUS',0);

% Set channel 2 to trigger US triggers
setFgWaveform(fg1,2,'SQU',4e-6,triggerAmplitude,triggerAmplitude/2,50,4);
setFgBurstMode(fg1,2,1);
setFgTriggerMode(fg1,2,'BUS',0);

% Set channel 1 of fg2 to trigger US 
setFgWaveform(fg2,1,'SQU',0.5e-6,triggerAmplitude,triggerAmplitude/2,50,5);
setFgBurstMode(fg2,1,15);
setFgTriggerMode(fg2,1,'EXT',17);

 % Turn on output.
outpOn(fg1,1);
outpOn(fg1,2);
outpOn(fg2,1);
outpOn(fg2,2,'OFF');

try
    if length(voltage)~=length(dc)
        error('There must be a voltage for every duty cycle')
    end
    
    controlFgs_lstim([fg1,fg2],voltage);
catch ER
    fclose(fg2);
    fclose(fg1);
    rethrow(ER);
end
fclose(fg2);
fclose(fg1);