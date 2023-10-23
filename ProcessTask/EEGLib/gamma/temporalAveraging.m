function tsOut = temporalAveraging(t,ts,window,desiredTime)

tsOut = nan(size(ts,1),length(desiredTime),size(ts,3));
for hh = 1:size(ts,3)
    for ii = 1:length(desiredTime)
        curIdx = find(t>desiredTime(ii)-window & t<= desiredTime(ii));
        tsOut(:,ii,hh) = mean(ts(:,curIdx,hh),2,'omitnan');
    end
end