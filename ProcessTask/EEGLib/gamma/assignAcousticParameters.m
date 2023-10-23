function [usTrigIdx,finalNum] = assignAcousticParameters(log,ard2trig,usTrigIdx,num,idxNum)
% If more than one us trigger share the same message - this means they are
% spurious triggers. Get rid of the extras
ard2trig(diff(ard2trig)==0) = nan;

if length(log.log)==1
    keyboard
elseif sum(~isnan(ard2trig)) ~= length(log.log)
    tmp = ard2trig(~isnan(ard2trig));
    idx = find(diff(num(tmp))==0);

    % There doesn't seem to be more than one time that the table ID was
    % sent
    if isempty(idx)
        idx = 1;

    % The table ID may have been sent multiple times. Find all indices that
    % match the table ID. Extra instances of the table ID imply that the
    % code was restarted while the INTAN was running. We can just remove
    % those.
    else
        idx = [idx,idx(end)+1];
    end

    % Make sure that all the indices we selected really do match the table
    % ID. If they do, they can be removed.
    if sum(num(tmp(idx))==log.paramTable(1).TableID) == length(idx)
        ard2trig(ard2trig<=tmp(idx(end))) = nan;

        % If the lengths still aren't equal, this wasn't enough to fix the
        % problem. Alert the user.
        if sum(~isnan(ard2trig))~=length(log.log)
            keyboard
            error('Even after correcting for extra table IDs the INTAN and log files are not lining up.')
        end

    % This implies an unknown error - report it to the user
    else 
        keyboard
        error('The number of arduino messages cannot be reconciled with the US triggers')
    end
end

curIdx = 1;
correctParams = true(size(log.log));
finalUsTrigIdx = nan(size(correctParams));
finalNum = nan(size(correctParams));
for ii = 1:length(ard2trig)
    if isnan(ard2trig(ii))
        continue;
    end
    if num(ard2trig(ii)) == 0
        finalUsTrigIdx(curIdx) = usTrigIdx(ii);
        finalNum(curIdx) = num(ard2trig(ii));
        curIdx = curIdx+1;
        warning('Found a zero in the INTAN')
        continue;
    end
    curParams = log.paramTable(num(ard2trig(ii)));
    curParams = rmfield(curParams,'TableID');

    if ~isequal(curParams,log.log(curIdx).params)
        error('INTAN and log file do not agree')
        % correctParams(curIdx) = false;
    end
    finalUsTrigIdx(curIdx) = usTrigIdx(ii);
    finalNum(curIdx) = num(ard2trig(ii));
    curIdx = curIdx+1;
end
usTrigIdx = finalUsTrigIdx;