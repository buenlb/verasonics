function remove = removeSmallSessions(tData,threshold,task)
if ~exist('task','var')
    task = 0;
end
remove = zeros(size(tData));
for ii = 1:length(tData)
    if sum(tData(ii).lgn & ~isnan(tData(ii).ch) & tData(ii).task==task) < threshold
        remove(ii) = 1;
    end
end
        