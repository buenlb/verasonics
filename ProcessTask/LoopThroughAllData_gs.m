%% Process all data
clear; close all; clc;

addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\lib\placementVerification');
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\lib\mrLib\transducerLocalization\');
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\lib\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\lib\');
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\lib\');

%% Set the paths
taskPath = 'D:\Task\Euler\GS\';
couplingPath = 'C:\Users\Taylor\Documents\Data\Task\Coupling\';
gsCouplingFile = 'C:\Users\Taylor\Documents\Papers\MacaqueMethods\figs\gs_Euler_0925.mat';

files = dir([taskPath,'*.mat']);
tskIdx = 1;
for ii = 1:length(files)
    couplingFile = [couplingPath,files(ii).name(1:end-4), '_final.mat'];
    if ~exist(couplingFile,'file')
        warning(['Skipping ',files(ii).name,' because it lacks a corresponding coupling file.'])
        passFinal = nan;
        passInitial = nan;
        passFinal(ii) = nan;
        passInitial(ii) = nan;
        
        log = [];
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
    end
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
%             save(logFile,'log');
        else
            continue;
        end
    end
    taskDataFile = [taskPath,files(ii).name];
    tmp = processGrayScreen(taskDataFile);
    
    
    
    targets = log.log.targets;
    voltages = log.log.voltages';
    
    if length(targets)>length(tmp.lgn)+1
        error('Different by more than 1!')
    elseif length(targets)>length(tmp.lgn)
        targets = targets(1:length(tmp.lgn),:);
        voltages = voltages(1:length(tmp.lgn));
    end
    tmp.targets = targets;
    tmp.voltages = voltages;
    tData(tskIdx) = tmp;
    tskIdx = tskIdx+1;
end
%%
idx = 1:length(tData);
ch = [];
lgn = [];
result = [];
targets = [];
voltages = [];
timing = [];
for ii = 1:length(idx)
    ch = cat(1,tData(idx(ii)).ch,ch);
    lgn = cat(1,tData(idx(ii)).lgn,lgn);
    result = cat(1,tData(idx(ii)).result,result);
    targets = cat(1,tData(idx(ii)).targets,targets);
    voltages = cat(1,tData(idx(ii)).voltages,voltages);
    timing = cat(2,tData(idx(ii)).timing,timing);
end

trIdx = 1:length(lgn);
trIdx = find(lgn==1 | targets(:,2) == 5.5);

totData = struct();
totData.ch = ch(trIdx);
totData.lgn = lgn(trIdx);
totData.result = result(trIdx);
totData.timing = timing(trIdx);
totData.targets = targets(trIdx,:);
totData.voltages = voltages(trIdx);
totData.fpWindow = tData(1).fpWindow;

plotGrayScreen(totData);