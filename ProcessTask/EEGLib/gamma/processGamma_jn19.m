function [tWindow,eegLeft,eegRight,tableEntry] = processGamma_jn19(t,eeg,trg,log)
VERBOSE = 1;
%% Find US Triggers
usTrigIdx = find(diff(trg(1,:))>0);
usTrigIdx = usTrigIdx(2:end);

%% Decode parameter order from INTAN
[num,idxNum] = processArduino(t,trg(2,:),1e-3);
%% Error check - make sure table ID is correct and INTAN order matches log file order
if log.paramTable(1).TableID ~= num(1)
    error('Table ID decoded by INTAN does not match Table ID in Log File!')
end

% Figure out which INTAN message goes with which us trigger
disp('Aligning Triggers')
ard2trig = alignVerasonicsArduino(idxNum,usTrigIdx,t);

% Check that the INTAN agrees with the log file in terms of parameter order
disp('Checking agreement between table and binary signals')
try
[usTrigIdx,tableEntry] = assignAcousticParameters(log,ard2trig,usTrigIdx,num,idxNum);
catch
    keyboard
end

disp(['Average Time lag: ', num2str(mean(diff(t(usTrigIdx)))), '. Min: ', num2str(min(diff(t(usTrigIdx)))), '; max: ', num2str(max(diff(t(usTrigIdx))))]);

disp('Ensuring that the timing between us triggers makes sense')
testTiming = zeros(size(usTrigIdx));
for ii = 2:length(log)
    testTiming(ii) = log(ii).time.sonicationTime-(t(usTrigIdx(ii))-t(usTrigIdx(ii-1)));
end
if max(testTiming)>0.5
    error('Something is off in the timing.')
end

disp('Storing EEG Data')
eegWindow = 8;
preWindow = 1;
dt = t(2)-t(1);
windowIdx = ceil(eegWindow/dt);
preWindowIdx = ceil(preWindow/dt);
tWindow = t(1:windowIdx+preWindowIdx+1);
tWindow = tWindow-tWindow(preWindowIdx);
eegLeft = nan(length(usTrigIdx),windowIdx+preWindowIdx+1);
eegRight = eegLeft;
trigCheck = eegLeft;
for ii = 1:length(usTrigIdx)
    eegLeft(ii,:) = eeg(1,(usTrigIdx(ii)-preWindowIdx):(usTrigIdx(ii)+windowIdx));
    eegRight(ii,:) = eeg(2,(usTrigIdx(ii)-preWindowIdx):(usTrigIdx(ii)+windowIdx));
    trigCheck(ii,:) = trg(1,(usTrigIdx(ii)-preWindowIdx):(usTrigIdx(ii)+windowIdx));

    % Remove signal during actual sonication
    usIdx = find(tWindow>=0 & tWindow<=log.log(ii).params.duration*1e-3);
    eegLeft(ii,usIdx) = nan;
    eegRight(ii,usIdx) = nan;

    if max(abs(eegLeft(ii,:))) > 10000
        disp('Activated Left!')
        keyboard
        eegLeft(ii,:) = nan;
    end
    if max(abs(eegRight(ii,:))) > 10000
        disp('Activated Right!')
        keyboard
        eegRight(ii,:) = nan;
    end
end
if VERBOSE
    h = figure;
    plot(tWindow,mean(trigCheck,1),'linewidth',2);
    xlabel('time (s)')
    ylabel('Trigger Signal')
    title('Check Trigger Alignment')
    makeFigureBig(h);
end
