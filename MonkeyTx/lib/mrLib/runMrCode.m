%% This runs the MR code
clear all; close all; clc;
%% Add necessary paths
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\griddedImage')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\placementVerification')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\MATFILES\')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\setupScripts\')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\lib')
%% Files
goldStandardFile = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRLogs\goldStandard_testCoupling.mat';
logFile ='C:\Users\Verasonics\Desktop\Taylor\Data\MRLogs\test.mat';
couplingCheckFile = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRLogs\test_coupling2.mat';
% dcmPath = '';
load('C:\Users\Verasonics\Desktop\Taylor\mrSysExample.mat')

sys.logFile = logFile;
sys.goldStandardFile = goldStandardFile;
sys.couplingCheckFile = couplingCheckFile;

%% Localize Transducer
sys = mrScanNoGUI(sys);

save(sys.logFile,'sys');

%% Visually select a focus
colorImg = drawTransducerColor(sys.img,sys.txImg);
sys.colorImg = colorImg;

waitfor(selectFocusGui(sys));

x = sys.x;
y = sys.y;
z = sys.z;

load('guiFileOutput.mat')
delete('guiFileOutput.mat');
focalSpot = (-[x(sys.centerIdx(1)),y(sys.centerIdx(2)),z(sys.centerIdx(3))]+...
    [x(focalSpotIdx(1)),y(focalSpotIdx(2)),z(focalSpotIdx(3))])*1e3;

sys.focalSpot = focalSpot;
disp(['Selected Focal Spot: <', num2str(focalSpot(1),2), ', ',...
    num2str(focalSpot(2),2), ', ', num2str(focalSpot(3),2), '>'])

%% Coupling Checks

% save('tmp.mat','sys');
% testArrayPlacement(sys.goldStandardFile,sys.couplingCheckFile);
% load('tmp.mat');
% delete('tmp.mat');