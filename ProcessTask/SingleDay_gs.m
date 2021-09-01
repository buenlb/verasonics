%% Process one day of data
clear all; close all; clc;

addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\lib\placementVerification');
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\lib\mrLib\transducerLocalization\');
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\lib\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\lib\');
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\lib\');

%% Set the filenames
taskPath = 'C:\Users\Taylor\Documents\Data\Task\grayScreen\';
taskDataFileName = 'Euler20210315_gs';
taskDataFile = [taskPath,taskDataFileName,'.mat'];

couplingPath = 'C:\Users\Taylor\Documents\Data\Task\Coupling\';
couplingFileNameFinal = [taskDataFileName,'_final'];

gsCouplingFile = 'C:\Users\Taylor\Documents\Papers\MacaqueMethods\figs\gs_Euler_0925.mat';

logFile = [couplingPath,taskDataFileName,'_log'];
log = load(logFile);
try
    dc = log.log.Parameters.DutyCycle;
    prf = log.log.Parameters.PulseRepFreq;
catch
    dc = input('Duty Cycle? >>');
    prf = input('PRF? >>');
end
voltage = log.log.Parameters.voltages;

%% Check the coupling
pass = checkCoupling(gsCouplingFile, [couplingPath,couplingFileNameFinal], 1);

if pass
    disp('*****PASSED coupling check!*****')
else
    disp('*****FAILED coupling check!*****')
end

passInit = checkCoupling(gsCouplingFile, [couplingPath,taskDataFileName], 1);
if passInit
    disp('  Initial coupling check passed')
else
    disp('  Initial coupling check failed')
end

%% Process Task Data
tData = processGrayScreen(taskDataFile);

%% Plot Results
plotGrayScreen(tData);