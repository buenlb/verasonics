% alignEegSpectra resets the vector to to be zero at the onset of
% ultrasound. This is in contrast to alignEeg which aligns smaller EEG
% windows to the onset of visual stimulus in each trial
% 
% @INPUTS
%   t: the time vectors (in a cell array) for the eeg data
%   tData: Task data (created by processTaskDataDurable) that contains
%     information on when the US sonication occurs. tData must be an array
%     of structs of the same length as the cell array, t
%   trIdx: index at which trials in tData occur within t. A cell array of
%     the same length as t.
%   trId: Trial ID of the trials in trIdx. A cell array of the same length
%     as t.
% 
% @OUTPUTS
%   tAligned: cell array the same size as t with a new set of time vectors
%     that are all zero at the ultrasound onset
% 
% Taylor Webb
% University of Utah

function [tAligned,zIdx] = alignEegSpectra(t,tData,trIdx,trId)
if ~iscell(t)
    error('Expected cell array')
end

if length(t) ~= length(tData) || length(t) ~= length(trIdx) || length(t) ~= length(trId)
    error('All inputs must have the same length');
end

tAligned = cell(size(t));
for ii = 1:length(tData)
    curId = trId{ii};
    curIdx = trIdx{ii};
    curT = t{ii};

    usIdx = find(tData(ii).Block==tData(ii).usBlock);
    if isempty(usIdx)
        error(['Unable to find a sonication in tData #', num2str(ii)])
    else
        usIdx = usIdx(1);
    end
    tUsIdx = find(curId==usIdx);
    if isempty(tUsIdx)
        warning(['Unable to find the sonication trial in the EEG data. Cell index #', num2str(ii)])
        tAligned{ii} = nan;
        zIdx = nan;
        continue
    end
    zIdx = curIdx(tUsIdx);
    tAligned{ii} = curT-curT(curIdx(tUsIdx));
end