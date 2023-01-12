% Tests whether a set of scalars are members of a set of arrays. The first
% N/2 input variables are the scalars and the next N/2 input variables are
% the arrays. The scalar in position 1 will be checked against the array in
% position 1+N/2 etc...
% 
% Taylor Webb
% December 2022

function [result,idx] = multipleIsMember(varargin)

if mod(nargin,2)
    error('There must be one array for every scalar - thus the number of inputs must be even')
end

nCompares = length(varargin)/2;

result = false(1,nCompares);
for ii = 1:length(varargin)/2
    if ~isscalar(varargin{ii})
        error(['The First N/2 arguments must be scalars but the ', num2str(ii),'th argument is not.'])
    end
    result(ii) = ismember(varargin{ii},varargin{ii+nCompares});
end
idx = nan;

curIdx = cell(size(result));
if sum(result) == length(result)
    for ii = 1:length(result)
        curIdx{ii} = find(varargin{ii}==varargin{ii+nCompares});
    end
    idx = curIdx{1};
    for ii = 1:length(result)-1
        idx = intersect(idx,curIdx{ii+1});
    end
end

if length(idx)>1
    keyboard;
end