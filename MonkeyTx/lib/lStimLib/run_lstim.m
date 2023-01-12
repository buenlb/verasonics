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

% Voltage at 480 (1.2 MPa, 31.4kPa/V): 38.2. 1 MPa: 31.8
% Voltage at 650 (1.2 MPa, 51.2kPa/V): 23.4. 1 MPa: 19.5

%% 480 kHz Pulsed
% foci = [-8.5 5 57.7;13.2 6 52.7];
% V = 31.8;
% prf = 400; % 400 for 2.5 ms pulses, NA for CW
% dc = 98; % 98 for pulses, 100 for CW
% freq = 0.48;

%% 480 kHz CW
% foci = [-8.5 5 57.7;13.2 6 52.7];
% V = 31.8;
% prf = 400; % 400 for 2.5 ms pulses, NA for CW
% dc = 100; % 98 for pulses, 100 for CW
% freq = 0.48;
% logFile = 'calvin_0.48_cw';

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
end

fclose(Resource.Parameters.fgs(1));
% fclose(Resource.Parameters.fgs(2));