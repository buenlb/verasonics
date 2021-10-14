function targets = generateTargets(target,nTargets,dev)
nTargets(nTargets==1) = 0;
if sum(nTargets)==0
    targets = target;
    return
end

targets = repmat(target,[sum(nTargets),1]);
xLim = (nTargets(1)-1)/2;
yLim = (nTargets(2)-1)/2;
zLim = (nTargets(3)-1)/2;

targets(1:nTargets(1),1) = target(1)+dev(1)*(-xLim:1:xLim);
targets((nTargets(1)+1):(nTargets(1)+nTargets(2)),2) = target(2)+dev(2)*(-yLim:1:yLim);
targets((nTargets(1)+nTargets(2)+1):end,3) = target(3)+dev(3)*(-zLim:1:zLim);

distFromCenter = sqrt(sum((targets-repmat(target,sum(nTargets),1)).^2,2));
idx = find(~distFromCenter);
if ~isempty(idx)
    tmp = true(size(targets,1),1);
    tmp(idx(2:end)) = false;
    targets = targets(tmp,:);
end