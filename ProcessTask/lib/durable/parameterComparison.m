% parameterComparison plots the contralateral choices made by each subject
% as a function of the parameter, param. Param is binned into the bins
% given in bins. If bins is empty, each individual param is considered
% seperately.
% 
% @INPUTS
%   sessions: the struct returned by sortSessions
%   tm: array of time values corresponding to the columns of contraVar
%   contraVar: A matrix representing contralateral choices (either in
%       percent or ms depending on which representation you chose). It must
%       have nSessions rows (nSessions is the total number of sessions, not
%       the length of the sorted sessions struct) and length(tm) columns.
%   window: The time window within which to average contralateral choices
%       (corresponds to tm).
%   param: The parameter across which you wish to plot contralateral
%       choices. It must be a field in sessions.
%   bins: bins in which to combine sessions across the parameters in param.
%       Optional. Defaults to empty. This array represents the edges of the
%       bins.
% 
% @OUTPUTS
%   bins: the x-axis for plotting the result - this is how the parameters
%      were divided up
%   brs: The average contralateral choices within the specified time
%       window
% 
% Taylor Webb
% March 2023
function [bins,brs,se,nSessions,p] = parameterComparison(sessions,tm,contraVar,window,param,bins)

params = arrayfun(@(s) s.(param), sessions);

if ~exist('bins','var')
    bins = [];
end
if isempty(bins)
    bins = unique(params);
    sIdx = myBinner(sessions,params,bins);
else
    sIdx = myBinner(sessions,params,bins);
    % Convert to bin centers instead of edges for plotting
    bins = diff(bins)/2+bins(1:end-1);
end
% Find time index
if length(window)>1
    error('I haven''t implemented multiple windows yet')
end
tmIdx = find(tm==window);

% Get average data
brs = nan(size(bins));
se = brs;
nSessions = zeros(size(se));
for ii = 1:length(bins)
    curS_idx = find(sIdx==ii);

    [idxLeft,idxRight] = getLeftRightIdx(sessions,curS_idx);
    idx1 = [idxLeft,idxRight];

    brs(ii) = mean(contraVar(idx1,tmIdx),1,'omitnan');
    se(ii) = semOmitNan(contraVar(idx1,tmIdx),1);
    
    allIdx{ii} = idx1;

    nSessions(ii) = length(idx1);
end

p = nan(length(allIdx));
for ii = 1:length(allIdx)
    for jj = ii:length(allIdx)
        [~,p(ii,jj)] = ttest2(contraVar(allIdx{ii},tmIdx),contraVar(allIdx{jj},tmIdx));
    end
end