function idx = actualDelayMatch(tData,delays)
if length(tData)>1
    error('Can only accept one struct at a time')
end

ad = tData.actualDelay.*sign(tData.delay);
if size(delays,1)>size(delays,2)
    delays = delays';
end
delaysMat = repmat(delays,[length(ad),1]);
adMat = repmat(ad,[1,length(delays)]);

tmp = abs(adMat-delaysMat);
[~,idx] = min(tmp,[],2);
idx(isnan(ad)) = nan;