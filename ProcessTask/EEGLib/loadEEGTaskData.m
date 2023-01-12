function [tA,eegLeft,eegRight,trigCheck,t,eeg,dig,anlg,trId,taskIdx] = loadEEGTaskData(pth,baseName,tData)

rightEegIdx = 1;
leftEegIdx = 2;

[t,eeg,dig,anlg] = concatIntan(pth,baseName);
if size(dig,1)<2
    warning('Binary Coding for trial number on different channel than expecteds')
    bCodeIdx = 1;
else
    bCodeIdx = 2;
end

if isempty(t)
    if size(dig,1)<2
        warning('No Binary Coding for trial number')
    end
    tA = [];
    eegLeft = [];
    eegRight = [];
    trigCheck = [];
    t = [];
    eeg = [];
    dig = [];
    anlg = [];
    trId = [];
    taskIdx = [];
    return;
end

[taskIdx,trId] = findTaskIdx(t,dig(bCodeIdx,:));
if isempty(trId)
    warning('No trials found')
    tA = [];
    eegLeft = [];
    eegRight = [];
    trigCheck = [];
    t = [];
    eeg = [];
    dig = [];
    anlg = [];
    trId = [];
    taskIdx = [];
    return;
end
taskIdx = taskIdx(~isnan(trId));
trId = trId(~isnan(trId));
tmpIdx = find(diff(trId)<1);
if ~isempty(tmpIdx)
    warning('Discarding trials after apparent restart of system')
    trId = trId(1:tmpIdx(1));
end
if trId(end)==length(tData.timing)+1
    % This just means the session was cut off in the middle of a trial -
    % discard that ID
    trId = trId(1:end-1);
elseif trId(end)>length(tData.timing)+1
    % This shouldn't happen. Alert the user
    keyboard
end

if length(trId)<100
    tA = [];
    eegLeft = [];
    eegRight = [];
    trigCheck = [];
    t = [];
    eeg = [];
    dig = [];
    anlg = [];
    trId = [];
    taskIdx = [];
    return;
end

if trId(end)<trId(end-1)
    trId = trId(1:end-1);
    taskIdx = taskIdx(1:end-1);
end

newIdx = taskIdx(1):(taskIdx(end)+max(diff(taskIdx)));
newIdx = newIdx(newIdx<=length(t));
taskIdx = taskIdx-newIdx(1)+1;

t = t(newIdx)-t(newIdx(1));
eeg = eeg(:,newIdx);
dig = dig(:,newIdx);
anlg = anlg(:,newIdx);
eeg = filterEEG(eeg,0);
try
alignIdx = alignEEG(trId,taskIdx,tData,'FT');

window = [-800,800]*1e-3;
Fs = 20e3;
tA = window(1):(1/Fs):window(2);
eegLeft = nan(length(tData.ch),length(tA));
eegRight = eegLeft;
trigCheck = eegLeft;
for ii = 1:length(tData.ch)
    curTrial = find(ii==trId);
    if isempty(curTrial) || isnan(alignIdx(curTrial))
        continue
    end
    curIdx = (alignIdx(curTrial)+window(1)*Fs):(alignIdx(curTrial)+window(2)*Fs);
    if curIdx(1)<1 || curIdx(end)>size(eeg,2)
        continue
    end
    eegLeft(ii,:) = eeg(leftEegIdx,curIdx);
    trigCheck(ii,:) = dig(1,curIdx);
    eegRight(ii,:) = eeg(rightEegIdx,curIdx);

    if max(eegLeft(ii,:)>100)
        eegLeft(ii,:) = nan;
    end
    if max(eegRight(ii,:)>100)
        eegRight(ii,:) = nan;
    end
end
disp('Success!')
catch me
    keyboard
    tA = [];
    eegLeft = [];
    eegRight = [];
    t = [];
    eeg = [];
    dig = [];
    anlg = [];
    trId = [];
    trigCheck = [];
    taskIdx = [];
    return;
end


