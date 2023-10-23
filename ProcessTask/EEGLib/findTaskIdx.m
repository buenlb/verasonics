% Loops through the digital data looking for trial numbers.
% 
% @INPUTS
%   t: time vector from intan system
%   dig: digital input with trial numbers encoded
% @OUTPUTS
%   idx: idx into t and dig at which trial numbers began. This marks the
%       beginning of a trial and is useful for syncronizing data
%   trNum: The trial number sent by the server at the beginning of this
%       trial
% 
% Taylor Webb
% University of Utah

function [idx,trNum] = findTaskIdx(t,dig)
dfDig = diff(dig);
idxOn = find(dfDig>0);

if isempty(idxOn)
    idx = [];
    trNum = [];
    return
end

curIdx = 1;
for ii = 1:length(idxOn)
    if ii == 1
        idx(curIdx) = idxOn(ii);
        curIdx = curIdx+1;
        if t(idxOn(ii+1)) - t(idxOn(ii)) > 200e-3
            idx(curIdx) = idxOn(ii+1);
            curIdx = curIdx+1;
        end
    elseif ii == length(idxOn)
        break
    elseif t(idxOn(ii+1)) - t(idxOn(ii)) > 200e-3
        idx(curIdx) = idxOn(ii+1);
        curIdx = curIdx+1;
    end
end

for ii = 1:length(idx)
    if idx(ii)+200e-3*20e3 > length(t)
        trNum(ii) = nan;
        continue
    else
        trNum(ii) = dig2num(t(idx(ii):idx(ii)+200e-3*20e3),dig(idx(ii):idx(ii)+100e-3*20e3),2.9e-3);
%         plot(t(idx(ii):idx(ii)+100e-3*20e3),dig(idx(ii):idx(ii)+100e-3*20e3))
    end
end
