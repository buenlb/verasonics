    %% Process all data
clear; close all; clc;

addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\lib\placementVerification');
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\lib\mrLib\transducerLocalization\');
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\MonkeyTx\lib\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\lib\');
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\lib\');

%% Set the paths
taskPath = 'C:\Users\Taylor\Documents\Data\Task\';
couplingPath = 'C:\Users\Taylor\Documents\Data\Task\Coupling\';
gsCouplingFile = 'C:\Users\Taylor\Documents\Papers\MacaqueMethods\figs\gs_Euler_0925.mat';

if exist([taskPath,'currentData.mat'],'file')
    curData = load([taskPath,'currentData.mat']);
%     curData.processedFiles = curData.processedFiles(2:end);
else
    curData = [];
end
files = dir([taskPath,'Euler*.mat']);
passFinal = [];
passInitial = [];
tskIdx = 1;
for ii = 1:length(files)
    if strcmp(files(ii).name,'currentData.mat')
        continue
    end
    taskDataFile = [taskPath,files(ii).name];
%     keyboard
    if ~isempty(curData)
        if ismember(taskDataFile,curData.processedFiles)
            disp('Already Processed')
            oldIdx = find(strcmp(curData.processedFiles,taskDataFile));
            dc(tskIdx) = curData.dc(oldIdx);
            voltage(tskIdx) = curData.voltage(oldIdx);
            prf(tskIdx) = curData.prf(oldIdx);
            freq(tskIdx) = curData.freq(oldIdx);
            try
            targets{tskIdx} = curData.targets{oldIdx};
            catch
                tagets{tskIdx} = [0 0 0];
            end
            passFinal(tskIdx) = curData.passFinal(oldIdx);
            passInitial(tskIdx) = curData.passInitial(oldIdx);
            tData(tskIdx) = curData.tData(oldIdx);
            processedFiles{tskIdx} = curData.processedFiles{oldIdx};
            tskIdx = tskIdx+1;
            continue;
        end
    end
    
    couplingFile = [couplingPath,files(ii).name(1:end-4), '_final.mat'];
    if ~exist(couplingFile,'file')
        warning(['Skipping ',files(ii).name,' because it lacks a corresponding coupling file.'])
        passFinal = double(passFinal);
        passInitial = double(passInitial);
        passFinal(tskIdx) = nan;
        passInitial(tskIdx) = nan;
        
        try
            logFile = [couplingPath, files(ii).name(1:end-4), '_log.mat'];
            log = load(logFile);
        catch        
            log = [];
        end
    else
        disp(['Processing ', files(ii).name])
        % Load parameters - if it is an old log file, ask the user to
        % supply them
        logFile = [couplingPath, files(ii).name(1:end-4), '_log.mat'];
        log = load(logFile);
        
        [pass,distErr(tskIdx,:),powErr(tskIdx,:),totPowErr(tskIdx,:)] = checkCoupling(gsCouplingFile, couplingFile, 1);
        passFinal(tskIdx) = pass;
        
        couplingFileInit = [couplingPath,files(ii).name(1:end-4)];
        [passInit,distErrInit(tskIdx,:),powErrInit(tskIdx,:),totPowErrInit(tskIdx,:)] = checkCoupling(gsCouplingFile, couplingFileInit, 1);
        passInitial(tskIdx) = passInit;
    end
    try
        dc(tskIdx) = log.log.Parameters.DutyCycle; 
        prf(tskIdx) = log.log.Parameters.PulseRepFreq; %#ok<*SAGROW>
        voltage(tskIdx) = log.log.Parameters.voltages(1);
        
        if isfield(log.log,'targets')
            targets{tskIdx} = log.log.targets;
        else
            targets{tskIdx} = {[-10,6.5,60.5]*1e-3,[12,5,59]*1e-3};
        end
        if isfield(log.log,'frequency')
            freq(tskIdx) = log.log.frequency;
        else
            freq(tskIdx) = 0.65;
        end
    catch
        manualEntry = input([files(ii).name,': Add Duty? >>']);
        if manualEntry
            dc(tskIdx) = input([files(ii).name,': DC? >>']);
            prf(tskIdx) = input([files(ii).name,': PRF? >>']);
            voltage(tskIdx) = input([files(ii).name,': Voltage? >>']);
            keyboard
            log.log.Parameters.DutyCycle = dc(tskIdx);
            log.log.Parameters.PulseRepFreq = prf(tskIdx);
            if ~isfield(log.log.Parameters,'voltages')
                log.log.Parameters.voltages = ones(1,2)*voltage(tskIdx);
            end
            log = log.log;
%             save(logFile,'log');
        else
            continue;
        end
    end
    processedFiles{tskIdx} = taskDataFile;
    tic
    tData(tskIdx) = processTaskData(taskDataFile);
    toc
    tskIdx = tskIdx+1;
    
    save([taskPath,'currentData.mat'],'tData','dc','prf','voltage','processedFiles','passInitial','passFinal','freq','targets');
end

%% Error checking
for ii = 1:length(tData)
    if isnan(diff(tData(ii).dc))
        continue
    end
    if sum(diff(tData(ii).dc))
        warning(['File ', processedFiles{ii}, ' has multiple duty cycles! Setting duty cycle to the last duty cycle in the struct (', num2str(tData(ii).dc(end)),').'])
        dc(ii) = tData(ii).dc(end);
    end
    
    if sum(diff(tData(ii).leftVoltage))
        warning(['File ', processedFiles{ii}, ' has multiple left voltages! Setting duty cycle to the last left voltage in the struct(', num2str(tData(ii).leftVoltage(end)),').']);
        dc(ii) = tData(ii).leftVoltage(end);
    end
    
    if sum(diff(tData(ii).rightVoltage))
        warning(['File ', processedFiles{ii}, ' has multiple right voltages! Setting duty cycle to the last right voltage in the struct(', num2str(tData(ii).rightVoltage(end)),').']);
        dc(ii) = tData(ii).rightVoltage(end);
    end
    
    if sum(diff(tData(ii).prf))
        warning(['File ', processedFiles{ii}, ' has multiple PRFs! Setting duty cycle to the last PRF in the struct(', num2str(tData(ii).prf(end)),').']);
        dc(ii) = tData(ii).rightVoltage(end);
    end
end
%%
passed = passFinal;
passed(isnan(passed)) = false;
passed(end-1:end) = true;

% passed = true(size(passed));
% passed(1:16) = false;
% 10% Duty
% idx = length(dc);
% idx = idx(1:end-1);
% idx = 3;
% idx = idx(end-3);
idx = find(dc==10 & freq == 0.65 & passed);
ch = [];
lgn = [];
delay = [];
result = [];
target = [];
task = [];
correctDelay = [];
for ii = 1:length(idx)
%     catIdx = ceil(length(tData(idx(ii)).ch)/2):length(tData(idx(ii)).ch);
%     if length(tData(idx(ii)).ch) < 400
%         continue
%     end
%     catIdx = 1:length(tData(idx(ii)).ch);
    catIdx = logical(~tData(idx(ii)).task);
%     catIdx = find(tData(idx(ii)).loc(1,1,:)<-7);
    
    ch = cat(1,tData(idx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(idx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(idx(ii)).delay(catIdx),delay);
    result = cat(1,tData(idx(ii)).result(catIdx),result);
    target = cat(3,tData(idx(ii)).loc(:,:,catIdx),target);
    task = cat(1,tData(idx(ii)).task(catIdx),task);
    correctDelay = cat(1,tData(idx(ii)).correctDelay(catIdx),correctDelay);
end
tData10 = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result,'loc',target,'task',task,'correctDelay',correctDelay);
zeroDelay(tData10,1);
axs = plotTaskResults(tData10,0,1);
axes(axs(1));
title('10% Duty')
ch10 = ch;
%% 50% Duty
idx = find(dc==50 & passed & freq==0.48 & voltage > 30);
% idx = idx(1:end-3)
ch = [];
lgn = [];
delay = [];
result = [];
task = [];
correctDelay = [];
for ii = 1:length(idx)
%     catIdx = ceil(length(tData(idx(ii)).ch)/2):length(tData(idx(ii)).ch);
%     catIdx = 1:length(tData(idx(ii)).ch);
    catIdx = logical(~tData(idx(ii)).task);
    
    ch = cat(1,tData(idx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(idx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(idx(ii)).delay(catIdx),delay);
    result = cat(1,tData(idx(ii)).result(catIdx),result);
    task = cat(1,tData(idx(ii)).task(catIdx),task);
    correctDelay = cat(1,tData(idx(ii)).correctDelay(catIdx),correctDelay);
end
tData50 = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result,'task',task,'correctDelay',correctDelay);
axs = plotTaskResults(tData50,0,1,'timing');
axes(axs(1));
title('50% Duty')

%% 100% Duty
% passed(25:end) = 0;
idx = find(dc==100 & passed & freq == 0.65);
% idx = idx(1:end-2);
ch = [];
lgn = [];
delay = [];
result = [];
task = [];
correctDelay = [];
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
    task = cat(1,tData(idx(ii)).task(catIdx),task);
    correctDelay = cat(1,tData(idx(ii)).correctDelay(catIdx),correctDelay);
end
tData100 = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result,'task',task,'correctDelay',correctDelay);
axs = plotTaskResults(tData100,0,1);
axes(axs(1));
title('100% Duty')
ch100 = ch;
% Compare protocols
clear tDataAll
tDataAll(1) = tData10;
tDataAll(2) = tData50;
tDataAll(3) = tData100;

labels = {'10%','50%','100%'};
% labels = {'10%','100%'};

h = plotProtocolComparison(tDataAll,labels);
h.Position = [h.Position(1:2),h.Position(3)*1.5,h.Position(4)];

ch10 = tData10.ch(boolean(tData10.lgn&tData10.delay==0));
delay10 = tData10.delay(boolean(tData10.lgn&tData10.delay==0));
lgn10 = tData10.lgn(boolean(tData10.lgn&tData10.delay==0));

contra10 = (~isnan(ch10)&delay10==0&lgn10==-1&ch10==0) | (~isnan(ch10)&delay10==0&lgn10==1&ch10==1);
ips10 = (~isnan(ch10)&delay10==0&lgn10==-1&ch10==1) | (~isnan(ch10)&delay10==0&lgn10==1&ch10==0);

ch50 = tData50.ch(boolean(tData50.lgn&tData50.delay==0));
delay50 = tData50.delay(boolean(tData50.lgn&tData50.delay==0));
lgn50 = tData50.lgn(boolean(tData50.lgn&tData50.delay==0));

contra50 = (~isnan(ch50)&delay50==0&lgn50==-1&ch50==0) | (~isnan(ch50)&delay50==0&lgn50==1&ch50==1);
ips50 = (~isnan(ch50)&delay50==0&lgn50==-1&ch50==1) | (~isnan(ch50)&delay50==0&lgn50==1&ch50==0);

ch100 = tData100.ch(boolean(tData100.lgn&tData100.delay==0));
delay100 = tData100.delay(boolean(tData100.lgn&tData100.delay==0));
lgn100 = tData100.lgn(boolean(tData100.lgn&tData100.delay==0));

contra100 = (~isnan(ch100)&delay100==0&lgn100==-1&ch100==0) | (~isnan(ch100)&delay100==0&lgn100==1&ch100==1);
ips100 = (~isnan(ch100)&delay100==0&lgn100==-1&ch100==1) | (~isnan(ch100)&delay100==0&lgn100==1&ch100==0);

h = figure;
bar(1:3,100*[mean(contra10),mean(contra50),mean(contra100)]-50);
hold on
erBar = errorbar(1:3,100*[mean(contra10),mean(contra50),mean(contra100)]-50,[std(contra10)/sqrt(length(contra10)),std(contra50)/sqrt(length(contra50)),std(contra100)/sqrt(length(contra100))]*100);
erBar.Color = [0,0,0];
erBar.LineStyle = 'none';
axis([0,4,-20,20])

[~,p1] = ttest2(contra10,contra50);
[~,p2] = ttest2(contra10,contra100);
[~,p3] = ttest2(contra50,contra100);

p = [p1,p2,p3];
intervals = {[1,2],[1,3],[2,3]};
intervals = intervals(p<0.05);
p = p(p<0.05);

sigstar(intervals,p);