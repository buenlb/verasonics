%% Process one day of data
clear all; close all; clc;

addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\lib\placementVerification');
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\lib\');

%% Set the filenames
taskPath = 'C:\Users\Taylor\Documents\Data\Task\';
taskDataFileName = 'Euler20210303';
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
tData = processTaskData(taskDataFile);

%% Plot Results
axs = plotTaskResults(tData);
axes(axs(1));
if pass
    title(taskDataFileName)
    txt = text(0.5,-0.1,['PASSED! DC: ', num2str(dc), ', V: ', num2str(voltage(1)), ', PRF: ', num2str(prf)]);
    txt.FontWeight = 'bold';
    txt.FontSize = 18;
else
    title(['FAILED! DC: ', num2str(dc), ', V: ', num2str(voltage(1)), ', PRF: ', num2str(prf)])
end
%% Process EEG