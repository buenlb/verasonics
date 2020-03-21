clear all; close all; clc;

%% Set up path locations
srcDirectory = setPaths();
addpath([srcDirectory,'lib\placementVerification']); % Adds library functions specific to this script

NEWINSTANCE = 1;

if NEWINSTANCE
%% Use Hardware
testArrayPlacement(...
    'C:\Users\Verasonics\Desktop\Taylor\Data\Coupling\20200320\goldStandard_skull1_zInf.mat',...
    'C:\Users\Verasonics\Desktop\Taylor\Data\Coupling\20200320\skull22.mat');
else
%% Use File
testArrayPlacement(...
    'C:\Users\Verasonics\Desktop\Taylor\Data\Coupling\20200320\goldStandard_sphericalPhantom3_zInf.mat',...
    '',...
    'C:\Users\Verasonics\Desktop\Taylor\Data\Coupling\20200320\sphericalPhantom4.mat');
end