%% Run a test sonication  using mrSonication
clc
verasonicsDir = 'C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\';
addpath([verasonicsDir, 'MonkeyTx\lib'])
addpath([verasonicsDir, 'MonkeyTx\lib\griddedImage'])
addpath([verasonicsDir, 'MonkeyTx\lib\placementVerification'])
addpath([verasonicsDir, 'MonkeyTx\MATFILES\'])
addpath([verasonicsDir, 'MonkeyTx\setupScripts\'])
addpath([verasonicsDir, 'lib'])
addpath([verasonicsDir, 'MonkeyTx\lib\mrLib\'])
addpath([verasonicsDir, 'MonkeyTx\lib\mrLib\thermometry\'])
addpath([verasonicsDir, 'MonkeyTx\lib\mrLib\transducerLocalization\']);

sys = struct('focalSpot',[12,5,59],'focalSpotIdx',[0,0,0],'focalSpotMr',[0,0,0]);

v = 6.4;
duration = 1;

mrSonication(sys,duration,v);