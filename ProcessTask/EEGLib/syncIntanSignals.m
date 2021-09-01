function timing = syncIntanSignals(t,dig,alg)
threshold = 2e-3;
%% Look for photodiode signal
onIdx = zeros(1,2);
for ii = 2:-1:1
    curS = alg(ii,:);
    curS = curS-mean(curS(t-t(1)<150e-3));
    idx = find(curS>threshold);
    if isempty(idx)
        onIdx(ii) = nan;
    else
        onIdx(ii) = idx(1);
    end
end

if ~sum(isnan(onIdx))
    delay = diff(t(onIdx));
else
    delay = nan;
end

idx = find(dig>0);
if isempty(idx)
    usOnIdx = nan;
else
    usOnIdx = idx(1);
end

timing = struct('diodeOnIdx',onIdx,'usOnIdx',usOnIdx,'targetDelay',delay);