% selectSessions(dc,freq,voltage,dcCond,freqCond,voltCond,passed)

function idx = selectSessions(taskData,threshold,dc,freq,voltage,dcCond,freqCond,voltCond,passed,task)

if ~exist('task','var')
    task = 0;
end
if length(dc) ~= length(freq) || length(dc) ~= length(voltage) || length(dc) ~= length(passed)
    error('dc, freq, voltage, and passed must all be the same length')
end

condIdx = 1;
if ~isempty(dcCond)
    cond(condIdx,:) = (dc == dcCond);
    condIdx = condIdx+1;
end
if ~isempty(freqCond)
    cond(condIdx,:) = (freq == freqCond);
    condIdx = condIdx+1;
end
if ~isempty(voltCond)
    cond(condIdx,:) = (voltage == voltCond);
    condIdx = condIdx+1;
end

curCond = true(size(dc));
for ii = 1:size(cond,1)
    curCond = curCond & cond(ii,:);
end
curCond = curCond & passed;

idx = find(curCond);
remove = removeSmallSessions(taskData(idx),threshold,task);
idx = idx(~remove);