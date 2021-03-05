%% Process all data
clear; close all; clc;

addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\lib\placementVerification');
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\lib\');

%% Set the paths
taskPath = 'C:\Users\Taylor\Documents\Data\Task\';
couplingPath = 'C:\Users\Taylor\Documents\Data\Task\Coupling\';
gsCouplingFile = 'C:\Users\Taylor\Documents\Papers\MacaqueMethods\figs\gs_Euler_0925.mat';

files = dir([taskPath,'*.mat']);
tskIdx = 1;
for ii = 1:length(files)
    couplingFile = [couplingPath,files(ii).name(1:end-4), '_final.mat'];
    if ~exist(couplingFile,'file')
        warning(['Skipping ',files(ii).name,' because it lacks a corresponding coupling file.'])
        passFinal(ii) = nan;
        passInitial(ii) = nan;
    else
        disp(['Processing ', files(ii).name])
        % Load parameters - if it is an old log file, ask the user to
        % supply them
        logFile = [couplingPath, files(ii).name(1:end-4), '_log.mat'];
        log = load(logFile);
        
        [pass,distErr(ii,:),powErr(ii,:),totPowErr(ii,:)] = checkCoupling(gsCouplingFile, couplingFile, 1);
        passFinal(ii) = pass;
        
        couplingFileInit = [couplingPath,files(ii).name(1:end-4)];
        [passInit,distErrInit(ii,:),powErrInit(ii,:),totPowErrInit(ii,:)] = checkCoupling(gsCouplingFile, couplingFileInit, 1);
        passInitial(ii) = passInit;
        if pass
            try
                dc(tskIdx) = log.log.Parameters.DutyCycle; 
                prf(tskIdx) = log.log.Parameters.PulseRepFreq; %#ok<*SAGROW>
                voltage(tskIdx) = log.log.Parameters.voltages(1);
            catch
                manualEntry = input([files(ii).name,': Add Duty? >>']);
                if manualEntry
                    dc(tskIdx) = input([files(ii).name,': DC? >>']);
                    prf(tskIdx) = input([files(ii).name,': PRF? >>']);
                    voltage(tskIdx) = input([files(ii).name,': Voltage? >>']);
                    log.log.Parameters.DutyCycle = dc(tskIdx);
                    log.log.Parameters.PulseRepFreq = prf(tskIdx);
                    if ~isfield(log.log.Parameters,'voltages')
                        log.log.Parameters.voltages = ones(1,2)*voltage(tskIdx);
                    end
                    log = log.log;
                    keyboard
                    save(logFile,'log');
                else
                    continue;
                end
            end
            taskDataFile = [taskPath,files(ii).name];
            tData(tskIdx) = processTaskData(taskDataFile);
            tskIdx = tskIdx+1;
        end
    end
end

%% 10% Duty
idx = find(dc==10);
ch = [];
lgn = [];
delay = [];
result = [];
for ii = 1:length(idx)
%     catIdx = ceil(length(tData(idx(ii)).ch)/2):length(tData(idx(ii)).ch);
    catIdx = 1:length(tData(idx(ii)).ch);
    
    ch = cat(1,tData(idx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(idx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(idx(ii)).delay(catIdx),delay);
    result = cat(1,tData(idx(ii)).result(catIdx),result);
end
tData10 = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result);
axs = plotTaskResults(tData10);
axes(axs(1));
title('10% Duty')

%% 50% Duty
idx = find(dc==50);
ch = [];
lgn = [];
delay = [];
result = [];
for ii = 1:length(idx)
%     catIdx = ceil(length(tData(idx(ii)).ch)/2):length(tData(idx(ii)).ch);
    catIdx = 1:length(tData(idx(ii)).ch);
    
    ch = cat(1,tData(idx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(idx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(idx(ii)).delay(catIdx),delay);
    result = cat(1,tData(idx(ii)).result(catIdx),result);
end
tData50 = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result);
axs = plotTaskResults(tData50);
axes(axs(1));
title('50% Duty')

%% 100% Duty
idx = find(dc==100);
idx = idx(1:2)
ch = [];
lgn = [];
delay = [];
result = [];
for ii = 1:length(idx)
%     catIdx = ceil(length(tData(idx(ii)).ch)/2):length(tData(idx(ii)).ch);
    catIdx = 1:length(tData(idx(ii)).ch);
%     catIdx = find((tData(idx(ii)).lgn)>0)+1;
%     tmp = false(size(tData(idx(ii)).lgn));
%     tmp(catIdx) = true;
%     catIdx = tmp | boolean(tData(idx(ii)).lgn);
    
    ch = cat(1,tData(idx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(idx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(idx(ii)).delay(catIdx),delay);
    result = cat(1,tData(idx(ii)).result(catIdx),result);
end
tData100 = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result);
axs = plotTaskResults(tData100);
axes(axs(1));
title('100% Duty')