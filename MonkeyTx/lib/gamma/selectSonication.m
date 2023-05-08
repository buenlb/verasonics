function bucket = selectSonication(buckets)

idx = randi(sum(buckets));
notFound = 1;
runningSum = 0;
curIdx = 1;
while notFound
    runningSum = runningSum+buckets(curIdx);
    if idx<=runningSum
        bucket = curIdx;
        notFound = 0;
    end
    curIdx = curIdx+1;
end
