verasonicsDir = 'C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\';
% verasonicsDir = 'C:\Users\Taylor\Documents\Projects\verasonics\verasonics\';
% Add relevant paths to give access to library functions

addpath([verasonicsDir, 'MonkeyTx\lib'])
addpath([verasonicsDir, 'MonkeyTx\lib\griddedImage'])
addpath([verasonicsDir, 'MonkeyTx\lib\placementVerification'])
addpath([verasonicsDir, 'MonkeyTx\MATFILES\'])
addpath([verasonicsDir, 'MonkeyTx\setupScripts\'])
addpath([verasonicsDir, 'lib'])
addpath([verasonicsDir, 'MonkeyTx\lib\mrLib\thermometry\'])
addpath([verasonicsDir, 'MonkeyTx\lib\mrLib\transducerLocalization\']);
addpath([verasonicsDir, 'MonkeyTx\lib\lStimLib\']);

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
LATERALIZE = 1;

if LATERALIZE
    % Set channel 1 to do LEDs
    setFgWaveform(fg1,1,'SQU',2e-6,triggerAmplitude,triggerAmplitude/2,50,4);
    setFgBurstMode(fg1,1,2*30);
    setFgTriggerMode(fg1,1,'BUS',0);

    setFgWaveform(fg2,2,'SQU',2e-6,triggerAmplitude,triggerAmplitude/2,50,4);
    setFgBurstMode(fg2,2,2*30,180);
    setFgTriggerMode(fg2,2,'EXT',0);
else
    % Set channel 1 to do LEDs
    setFgWaveform(fg1,1,'SQU',4e-6,triggerAmplitude,triggerAmplitude/2,50,2);
    setFgBurstMode(fg1,1,4*30);
    setFgTriggerMode(fg1,1,'BUS',0);
end
keyboard
% Set channel 2 to trigger US triggers
setFgWaveform(fg1,2,'SQU',4e-6,triggerAmplitude,triggerAmplitude/2,50,2);
setFgBurstMode(fg1,2,1);
setFgTriggerMode(fg1,2,'BUS',0);

% %% 650 kHz Pulsed
% foci = [-8.5 5 57.7;13.2 6 52.7];
% V = 19.5;
% prf = 400; % 400 for 2.5 ms pulses, NA for CW
% dc = 98; % 98 for pulses, 100 for CW
% freq = 0.65;
% logFile = 'calvin_0.65_p';
% 
% %% 650 kHz CW
foci = [-8.5 5 57.7;13.2 6 52.7];
V = 19.5*2;
prf = 400; % 400 for 2.5 ms pulses, NA for CW
dc = 100; % 98 for pulses, 100 for CW
freq = 0.65;
logFile = 'calvin_0.65_CW';

<<<<<<< HEAD
% Usage: lStim(duration,voltage,focalSpot(s),PRF,DC,freq,logFileName,txSn)
Resource = lStim(20e-3,V,foci,prf,dc,freq,logFile,'JAB800'); % 2.5 ms pulses alternating LGN

try
    save tmpBeforeVSX.mat
    filename = 'lStim.mat';
    VSX;
    load tmpBeforeVSX.mat
catch ME
    fclose(Resource.Parameters.fgs(1));
%     fclose(Resource.Parameters.fgs(2));
    rethrow(ME);
=======
 % Turn on output.
outpOn(fg1,1);
outpOn(fg1,2);
outpOn(fg2,1);
if LATERALIZE
    outpOn(fg2,2);
else
    outpOn(fg2,2,'OFF');
end

try
    if length(voltage)~=length(dc)
        error('There must be a voltage for every duty cycle')
    end
    
    controlFgs_lstim([fg1,fg2],voltage,1);
catch ER
    fclose(fg2);
    fclose(fg1);
    rethrow(ER);
>>>>>>> 146de6f206ed9fb3dd51d7d78b091a4a51ba6b08
end

fclose(Resource.Parameters.fgs(1));
% fclose(Resource.Parameters.fgs(2));