function [idxLeft,idxRight,idxCtl] = getLeftRightIdx(sessions,idx)
idxLeft = [];
idxRight = [];
idxCtl = [];
for ii = 1:length(idx)
    idxLeft = cat(2,idxLeft,sessions(idx(ii)).sessionsLeft);
    idxRight = cat(2,idxRight,sessions(idx(ii)).sessionsRight);
    idxCtl = cat(2,idxCtl,sessions(idx(ii)).sessionsCtl);
end
