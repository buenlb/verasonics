function [idxLeft,idxRight] = sortTrialsBySonication(lgn)

leftIdx = nan;
rightIdx = nan;

maxLength = 15;

idxRight = cell(1,maxLength);
idxLeft = cell(1,maxLength);

for ii = 1:length(lgn)
    if lgn(ii)==-1
        leftIdx = 0;
        rightIdx = nan;
        continue
    elseif lgn(ii)==1
        leftIdx = nan;
        rightIdx = 0;
        continue
    else
        leftIdx = leftIdx+1;
        rightIdx = rightIdx+1;
    end
    if rightIdx > maxLength || leftIdx > maxLength
        continue
    end

    if ~isnan(leftIdx)
        idxLeft{leftIdx} = cat(1,idxLeft{leftIdx},ii);
    end
    if ~isnan(rightIdx)
        idxRight{rightIdx} = cat(1,idxRight{rightIdx},ii);
    end
end

if ~exist('idxLeft','var')
    idxLeft = [];
end
if ~exist('idxRight','var')
    idxRight= [];
end
