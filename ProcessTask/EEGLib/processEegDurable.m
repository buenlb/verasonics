function [t,eeg,dig,trIdx,trNum,eegLeft,eegRight] = processEegDurable(pth,baseName)
rightEegIdx = 1;
leftEegIdx = 2;

[t,eeg,dig] = concatIntan(pth,baseName);

if isempty(t)
    warning(['No Files Found in ', pth, ' with base name ', baseName])
    tA = [];
    eegLeft = [];
    eegRight = [];
    trigCheck = [];
    t = [];
    eeg = [];
    dig = [];
    anlg = [];
    trId = [];
    return;
end

[taskIdx,trId] = findTaskIdx(t,dig(bCodeIdx,:));