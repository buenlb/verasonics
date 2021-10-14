function remove = removeSmallSessions(tData,threshold,task,delay)
if ~exist('task','var')
    task = 0;
end

remove = zeros(size(tData));
for ii = 1:length(tData)
    if ~exist('delay','var') || isempty(delay)
        delay = unique(tData(ii).delay);
    end
    
    if sum(tData(ii).lgn & ~isnan(tData(ii).ch) & tData(ii).task==task & ismember(tData(ii).delay,delay)) < threshold
        remove(ii) = 1;
    end
end
        