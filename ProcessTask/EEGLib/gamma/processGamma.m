function [tWindow,eegLeft,eegRight] = processGamma(t,eeg,trg,log)
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
num = num(2:end);
idxNum = idxNum(2:end);
for ii = 1:length(log.log)
%     if isnan(log.log(ii).leftIdx)
%         num(ii) = num(ii)+12;
%     end
    curParams = log.paramTable(num(ii));
    curParams = rmfield(curParams,'TableID');

    if ~isequal(curParams,log.log(ii).params)
        keyboard
        error('Order of parameters does not align between INTAN and log file!')
    end
end

%% Align arduino order with US triggers
while length(idxNum)~=length(usTrigIdx)
    % The INTAN number is always delivered before the US trigger so the
    % difference between the time of the INTAN number and the trigger must
    % be negative
    if t(idxNum(1))-t(usTrigIdx(1)) > 0
        usTrigIdx = usTrigIdx(2:end);
    elseif t(idxNum(1))-t(usTrigIdx(1)) < 0
        usTrigIdx = usTrigIdx(1:end-1);
    end

    if length(usTrigIdx) < length(idxNum)
        error('Something went wrong removing spurious triggers!')
    end
end

if max(t(idxNum)-t(usTrigIdx)) >= 0
    error('Something went wrong removing spurious triggers!')
end

keyboard
testTiming = zeros(size(usTrigIdx));
for ii = 2:length(log)
    testTiming(ii) = log(ii).time.sonicationTime-(t(usTrigIdx(ii))-t(usTrigIdx(ii-1)));
end
if max(testTiming)>0.5
    error('Something is off in the timing.')
end

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
    trigCheck(ii,:) = trg((usTrigIdx(ii)-preWindowIdx):(usTrigIdx(ii)+windowIdx));
end

if VERBOSE
    h = figure;
    plot(tWindow,mean(trigCheck,1),'linewidth',2);
    xlabel('time (s)')
    ylabel('Trigger Signal')
    title('Check Trigger Alignment')
    makeFigureBig(h);
end
