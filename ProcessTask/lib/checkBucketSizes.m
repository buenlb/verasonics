function [valid, buckets] = checkBucketSizes(delayVector,delays,ch,threshold)

buckets = zeros(size(delayVector));
for ii = 1:length(delayVector)
    buckets(ii) = sum(~isnan(ch(delays==delayVector(ii))));
end

if min(buckets) >= threshold
    valid = true;
else
    valid = false;
end
return