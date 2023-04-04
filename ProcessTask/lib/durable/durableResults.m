clear; close all; clc;
%% Add paths
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\lib\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\EEGLib\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\lib\')
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\lib\durable\')
%% Load files - US Only
[tDataB, filesB] = loadMonk('b');
[tDataE, filesE] = loadMonk('e');

%% Combine subjects
tData = [tDataB,tDataE];
processedFiles = [filesB,filesE];
monk(1:length(tDataB)) = 'b';
monk(length(tDataB)+1:length(tData)) = 'e';

%% Load files - nanoparticles
[tDataC, filesC] = loadMonk('c');
[tDataCS, filesCS] = loadMonk('c_saline');
[tDataH, filesH] = loadMonk('h');
[tDataHS, filesHS] = loadMonk('h_saline');

%% Combine subjects - nanoparticles
tDataN = [tDataC,tDataH];
monkN(1:length(tDataC)) = 'c';
monkN(length(tDataC)+1:length(tDataN)) = 'h';
processedFilesN = [filesC, filesH];

tDataS = [tDataCS, tDataHS];
monkSaline(1:length(tDataCS)) = 'c';
monkSaline(length(tDataCS)+1:length(tDataS)) = 'h';
processedFilesS = [filesCS, filesHS];
%% This code temporarily replaces the above while I am still sorting out loadDataDurable
% old = load('tmpSideSonicated.mat');
% load data10October2022.mat;
% for ii = 1:length(processedFiles)
%     curSession = processedFiles{ii};
%     for jj = 1:length(old.processedFiles)
%         if strcmp(old.processedFiles{jj}(end-length(curSession)+1:end),curSession)
%             tData(ii).sonication.focalLocation = old.tData(jj).sonicationProperties.FocalLocation;
%             tData(ii).sonication.nFoci = old.tData(jj).sonicationProperties.nFocalSpots;
%             tData(ii).sonication.dev = old.tData(jj).sonicationProperties.focalDev;
%         end
%     end
% end
%% Process behavior over time
% Set time window and range
tWindow = 5*60;
dt = 0.5*60;
tBefore = 2*tWindow;
tAfter = 12*tWindow;
tm = -tBefore:dt:tAfter;
baseline = 0;
% tm = 0:dt:40*60;
% tm = tWindow;

%% Error Checking
% Error check for sonications that occured on erroneous triggers
[tData,keepIdxNc] = processNonConformingSessions('noncomformingSessions',tData,processedFiles);
disp([num2str(sum(~keepIdxNc)), ' session(s) removed for erroneous sonication.'])
keepIdxNs = true(size(tData));
keepIdxBl = true(size(tData));
keepIdxNan = true(size(tData));
keepIdxLog = true(size(tData));
for ii = 1:length(tData)
% Display progress
    disp(['Finding Errors: ', num2str(ii), ' of ', num2str(length(tData))])

    % Error check for a session without a sonication
    if isnan(tData(ii).sonicatedTrials)
        % disp(['Throwing session out because it appears to lack a sonication: ', processedFiles{ii},'!'])
        keepIdxNs(ii) = false;
        continue
    end

    % Error check for early sessions in which we sonicated multiple times.
    % This throws out all trials after later sonications
    tData(ii) = removeExcessSonications(tData(ii));

    % Acquire baseline point of equal probability
    p0 = behaviorOverTime2(tData(ii),baseline,tWindow);

    % Error check for an unreasonable baseline (a sigmoid with an equal
    % probabability point outside of the available delays
    if abs(p0)>100
        %disp(['Throwing session out because of unreasonable baseline: ', processedFiles{ii},'!'])
        keepIdxBl(ii) = false;
        continue
    end

    % Error check for an nan baseline
    if isnan(p0)
        %disp(['Throwing session out because of nan baseline: ', processedFiles{ii},'!'])
        keepIdxNan(ii) = false;
        continue
    end

    % Error check by verifying that the record of the sonication in tData
    % matches the Verasonics log
    keepIdxLog(ii) = verifyWithLog(tData(ii),processedFiles{ii});
%     keepIdxLog = true(size(keepIdxLog));
end
disp('ELIMINATED SESSIONS')
keepIdx = keepIdxNc & keepIdxNs & keepIdxBl & keepIdxNan & keepIdxLog;
% keepIdx = keepIdxNs;
disp(['  ', num2str(sum(~keepIdx)), ' total sessions eliminated.'])
disp(['    ', num2str(sum(~keepIdxNc)), ' eliminated by non-conforming files check'])
disp(['    ', num2str(sum(~keepIdxNs)), ' eliminated because they lacked a sonication'])
disp(['    ', num2str(sum(~keepIdxBl)), ' eliminated because the baseline was outside of the expected range'])
disp(['    ', num2str(sum(~keepIdxNan)), ' eliminated because the baseline was NaN (not enough trials)'])
disp(['    ', num2str(sum(~keepIdxLog)), ' eliminated because verification with the Verasonics log failed'])

% tdOld = tData;
% tData = tData(keepIdx);
% pfOld = processedFiles;
% processedFiles = processedFiles(keepIdx);
% monkOld = monk;
% monk = monk(keepIdx);

%% Process 'good' data
y = nan(length(tData),length(tm));
m = y;
allCh = y;
epp = y;
err = y;
p0 = nan(size(tData));
chVectors = nan(5,length(tm),length(tData));
dVectors = chVectors;
for ii = 1:length(tData)
    disp(['Processing Behavior: ', num2str(ii), ' of ', num2str(length(tData))])
    if isnan(tData(ii).sonicatedTrials)
        continue
    end
    % Process behavior over time
    p0(ii) = behaviorOverTime2(tData(ii),baseline,tWindow);
%     idx =  1:tData(ii).sonicatedTrials;
%     idx = idx(logical(tData(ii).correctDelay(idx)));
%     if length(idx)<200
%         disp('!!!Skipped')
%         continue
%     end
%     [~,slope,bias,downshift,scale] = plotSigmoid(tData(ii),idx);
%     p0(ii) = equalProbabilityPoint(slope,bias,downshift,scale);
    [epp(ii,:),y(ii,:),m(ii,:),allCh(ii,:),chVectors(:,:,ii),dVectors(:,:,ii),err(ii,:)]...
        = behaviorOverTime2(tData(ii),tm,tWindow,p0(ii));
end