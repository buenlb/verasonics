clear; close all; clc;
logPath = 'D:\Gamma\Logs\';
%% Process Gamma results: Load data Boltzmann
logFileB = {'boltzmann20230619.mat','boltzmann20230621.mat','boltzmann20230622.mat',...
    'boltzmann20230628.mat','boltzmann20230629.mat','boltzmann20230630.mat'};

eegPth = 'C:\Users\Taylor\Box Sync\MonkeyData\gamma\';
eegBaseB = {'boltzmann__230619','boltzmann__230621','boltzmann__230622',...
    'boltzmann__230628','boltzmann__230629','boltzmann__230630'};

%% Process Gamma results: Load data Hobbes
logFileH = {'hobbes20230727.mat','hobbes20230731.mat','hobbes20230804.mat','hobbes20230814',...
    'hobbes20230816','hobbes20230817','hobbes20230818','hobbes20230821'};

eegPth = 'C:\Users\Taylor\Box Sync\MonkeyData\gamma\';
eegBaseH = {'hobbes__230727','boltzmann__230731','hobbes__230804','hobbes__230814', ...
    'boltzmann__230816','hobbes__230817','hobbes__230818','hobbes__230821'};

% logFile = {'TEST'};
% eegBase = eegBase(end);
% 
logFile = [logFileB,logFileH];
eegBase = [eegBaseB,eegBaseH];

% logFile = logFileB;
% eegBase = eegBaseB;

eegAll = cell(size(logFile));
eegAllLeft = cell(size(logFile));
eegAllRight = cell(size(logFile));

for hh = 1:length(logFile)
    if strcmp(logFile{hh},'TEST')
        [t,eeg,dig,log] = testGammaResults2();
    else
        log = load([logPath,logFile{hh}]);
        [t,eeg,dig] = concatIntan(eegPth, eegBase{hh});
    end
    
    eeg = notchFilter(eeg,20e3,[58,62]);
    eeg = notchFilter(eeg,20e3,[118,122]);
    eeg = notchFilter(eeg,20e3,[175,185]);

    % Low Pass Filter
%     eeg = lowpass(eeg',10,20e3)';
    
    %% Process EEG
    [tWindow,eegLeft,eegRight,tableEntries] = processGamma_jn19(t,eeg,dig,log);
    %% timeSpectrum
    disp('Processing Spectra')
    % close all
    totEeg = (eegLeft+eegRight)/2;
    
    h = figure;
    plot(tWindow,mean(totEeg,1,'omitnan'));
    xlabel('time (s)')
    ylabel('signal (\muV)')
    title(logFile(hh))
    makeFigureBig(h)
    drawnow
    
    desiredTimes = -0.5:0.25:8;
    desiredFreq = [0.5,200];
    window = 0.5;
    % ts = nan(length(desiredFreq),length(desiredTimes),size(eegLeft,1));
    clear ts tsRaw;
    for ii = 1:size(totEeg,1)
        [ts(:,:,ii),fftX] = timeSpectrum(totEeg(ii,:),tWindow,window,desiredTimes,desiredFreq);
    end
    
    PERCENT_CHANGE = 1;
    if PERCENT_CHANGE
        % Normalize the result to baseline
        % One has to be careful with how we average to baseline here. Averaging to
        % the baseline for every session biases the whole result towards an
        % increase in the magnitude of each fourier coefficient. This is because if
        % the baseline is small relative to the current window then you get:
        % 
        % (bigN-smallN)/smallN
        % 
        % Resulting in a large positive percentage. If, however, the baseline is
        % large - indicating that the Fourier coefficient decreased, you end up
        % with a smaller negative percentage:
        % 
        % (smallN-bigN)/bigN
        % 
        % Thus, we do the subtraction for each session but for the division we use
        % an average across all sessions so that the change in the coefficient is
        % weighted equally across sessions.
        baselineSubtractor = ts(:,desiredTimes<=0,:);
        baselineSubtractor = mean(baselineSubtractor,2,'omitnan');
        baselineSubtractor = repmat(baselineSubtractor,[1,size(ts,2),1]);
        baselineDivider = ts(:,desiredTimes==0,:);
        baselineDivider = mean(baselineDivider,3,'omitnan');
        baselineDivider = repmat(baselineDivider,[1,size(ts,2),size(ts,3)]);
        ts = 100*(ts-baselineSubtractor)./baselineDivider;
        tsAvg = mean(ts,3,'omitnan');
    else
        baselineDivider = ts(:,desiredTimes<=0,:);
        baselineDivider = mean(baselineDivider,2,'omitnan');
        baselineDivider = repmat(baselineDivider,[1,size(ts,2),1]);
        ts = 100*ts./baselineDivider;
        tsAvg = mean(ts,3,'omitnan');
    end

    % Sort the result by sonication. This enables us to average across
    % sessions later.
    [~,sortIdx] = sort(tableEntries);
    tsAll{hh} = ts(:,:,sortIdx);
    tEntriesAll{hh} = tableEntries(sortIdx);

    eegAll{hh} = totEeg(sortIdx,:);
    eegAllLeft{hh} = eegLeft(sortIdx,:);
    eegAllRight{hh} = eegRight(sortIdx,:);
%     plotTimeSpectraSpatial(ts,tableEntries,log,fftX,desiredTimes)
end

%% Plot overall results
% Averaged across sonications:
nSonications = 0;
for ii = 1:length(tsAll)
    nSonications = nSonications + size(tsAll{ii},3);
end

ts = nan(size(tsAll{1},1),size(tsAll{1},2),nSonications);
tEntries = nan(1,nSonications);
eeg = nan(length(tEntries),size(eegAll{1},2));
eegLeft = nan(length(tEntries),size(eegAll{1},2));
eegRight = nan(length(tEntries),size(eegAll{1},2));

loggedSonications = 0;
for ii = 1:length(tsAll)
    ts(:,:,loggedSonications+1:loggedSonications+size(tsAll{ii},3)) = tsAll{ii};
    tEntries(1,loggedSonications+1:loggedSonications+size(tsAll{ii},3)) = tEntriesAll{ii};
    eeg(loggedSonications+1:loggedSonications+size(tsAll{ii},3),:) = eegAll{ii};
    eegRight(loggedSonications+1:loggedSonications+size(tsAll{ii},3),:) = eegAllLeft{ii};
    eegLeft(loggedSonications+1:loggedSonications+size(tsAll{ii},3),:) = eegAllRight{ii};
    loggedSonications = loggedSonications+size(tsAll{ii},3);
end
avgTimes = -1:1:8;
ts = temporalAveraging(desiredTimes,ts,4,avgTimes);

for ii = 1:size(eeg,1)
    if max(abs(eeg(ii,:)))>500
        eeg(ii,:) = nan;
    end
end

%% UEP
[leftUep, rightUep, nLeft, nRight] = plotTimeSpatial(eeg(:,tWindow<1&tWindow>=0),tEntries,log,tWindow(tWindow<1&tWindow>=0));

%% Spectra
% plotTimeSpectraSpatial(ts,tEntries,log,fftX,desiredTimes)
plotBandsSpatial(ts,tEntries,log,fftX,avgTimes)
%%
hl = figure;
hr = figure;
ax = gca;
plotTimeSpatial(eegLeft(:,tWindow<1&tWindow>=0),tEntries,log,tWindow(tWindow<1&tWindow>=0),'rightFig',hr,'leftFig',hl,'Color',ax.ColorOrder(1,:))
ax = gca;
plotTimeSpatial(eegRight(:,tWindow<1&tWindow>=0),tEntries,log,tWindow(tWindow<1&tWindow>=0),'rightFig',hr,'leftFig',hl,'Color',ax.ColorOrder(2,:))
figure(hl)
subplot(341)
legend('Left Pin','Right Pin')

figure(hr)
subplot(341)
legend('Left Pin','Right Pin')

% plotTimeSpectraSpatial(ts,tEntries,log,fftX,desiredTimes)
% plotBandsSpatial(ts,tEntries,log,fftX,desiredTimes)
% plotTimeSpectraSpatial(ts,tEntries,log,fftX,avgTimes)
% plotBandsSpatial(ts,tEntries,log,fftX,avgTimes)

%%
% Averaged across sessions. 
tsSessions = zeros(size(ts,1),size(ts,2),max(tEntriesAll{1}));
tIdx = unique(tEntriesAll{1});
for hh = 1:length(tsAll)
    for ii = 1:max(tEntriesAll{1})
        tsSessions(:,:,ii) = mean(tsAll{hh}(:,:,tIdx(ii)==tEntriesAll{hh}),3,'omitnan') + tsSessions(:,:,ii);
    end
end
avgTimes = -1:1:7;
tsSessions = temporalAveraging(desiredTimes,tsSessions,4,avgTimes);

plotTimeSpectraSpatial(tsSessions,repmat(tIdx,[1,length(tsAll)]),log,fftX,desiredTimes)
plotBandsSpatial(tsSessions,repmat(tIdx,[1,length(tsAll)]),log,fftX,desiredTimes)