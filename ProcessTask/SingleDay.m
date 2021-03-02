%% Process one day of data
clear all; close all; clc;

addpath('..\MonkeyTx\lib\placementVerification');

%% Set the filenames
taskPath = 'C:\Users\Taylor\Documents\Data\Task\';
taskDataFileName = 'Euler20210226';
taskDataFile = [taskPath,taskDataFileName,'.mat'];

couplingPath = 'C:\Users\Taylor\Documents\Data\Task\Coupling\';
couplingFileNameFinal = [taskDataFileName,'_final'];

gsCouplingFile = 'C:\Users\Taylor\Documents\Papers\MacaqueMethods\figs\gs_Euler_0925.mat';

%% Check the coupling
pass = checkCoupling(gsCouplingFile, [couplingPath,couplingFileNameFinal], 1);

if pass
    disp('*****PASSED coupling check!*****')
else
    disp('*****FAILED coupling check!*****')
end

pass = checkCoupling(gsCouplingFile, [couplingPath,taskDataFileName], 1);
if pass
    disp('  Initial coupling check passed')
else
    disp('  Initial coupling check failed')
end

%% Display results
tData = processTaskData(taskDataFile,1);

%% Process EEG