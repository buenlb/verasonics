function [idxLeft,idxRight,idxCtl] = getLeftRightIdx(sessions,idx,nSessions,days)
idxLeft = [];
idxRight = [];
idxCtl = [];
for ii = 1:length(idx)
    curIdxLeft = sessions(idx(ii)).sessionsLeft;
    curIdxRight = sessions(idx(ii)).sessionsRight;
    curIdxCtl = sessions(idx(ii)).sessionsCtl;

    if exist('nSessions','var')
        if ~exist('days','var')
            error('If you request a number of sessions you must provide days!')
        end
        [~,tmpIdx] = sort(days(curIdxLeft));
        curIdxLeft = curIdxLeft(tmpIdx);
    
        [~,tmpIdx] = sort(days(curIdxRight));
        curIdxRight= curIdxRight(tmpIdx);
        
        curIdxLeft = curIdxLeft(1:nSessions);
        curIdxRight = curIdxRight(1:nSessions);

        if ~isempty(curIdxCtl)
            [~,tmpIdx] = sort(days(curIdxCtl));
            curIdxCtl = curIdxCtl(tmpIdx);
            curIdxCtl = curIdxCtl(1:nSessions);
        end
    end

    idxLeft = cat(2,idxLeft,curIdxLeft);
    idxRight = cat(2,idxRight,curIdxRight);
    idxCtl = cat(2,idxCtl,curIdxCtl);
end