% Appends variables together for use with anovan. This function simply adds
% the data in newVar to the data already present in var and then adds on
% group descriptors to match. It is, therefore, essential that the order in
% newGrp and grp always be the same.

function [var,grp] = myAnovaVars(var,grp,newVar,newGrp)
if length(newGrp) ~= length(grp)
    error('You have a different number of group variables')
end

for ii = 1:length(newGrp)
    if length(newVar(:))~=length(newGrp{ii}(:))
        error(['New variable length and the length of the corresponding group do no match! (Iteration: ', num2str(ii),')'])
    end
end

var = [var;newVar(:)];

for ii = 1:length(grp)
    grp{ii} = [grp{ii};newGrp{ii}(:)];
end