function [y,pBefore,pAfter] = beforeAfterSonication(tData,usBlock,nBlocks,blocksToSkip)

delays = unique(tData(1).delay);
trialsPerBlock= zeros(size(tData));
for ii = 1:length(tData)
    delays = unique([unique(tData(ii).delay); delays]);
    trialsPerBlock(ii) = tData(ii).trialsPerBucket;
end

if length(delays) > 5
    warning('Extra delays. Throwing out any extra delays from before US')
    delays = unique(tData(1).delay(150:end));
    if length(delays)>5
        error('Still too many delays')
    end
end

trialsPerBlock = unique(trialsPerBlock);
if length(trialsPerBlock) > 1
    error('Different runs have a different number of trials per block. I don''t know how to combine them.')
end
totTrialsPerBlock = trialsPerBlock*length(delays);

usIdx = usBlock*totTrialsPerBlock+1;

% beforeIdx = (usIdx-(nBlocks)*totTrialsPerBlock):usIdx-1;
% afterIdx = (usIdx+blocksToSkip*totTrialsPerBlock):((usIdx+blocksToSkip*totTrialsPerBlock)+(nBlocks)*totTrialsPerBlock-1);

pBefore = zeros(size(tData));
pAfter = pBefore;
y = pBefore;
for ii = 1:length(tData)
    beforeIdx = find(tData(ii).Block < usBlock & tData(ii).Block > usBlock-nBlocks-1);
    afterIdx = find(tData(ii).Block < usBlock+blocksToSkip+nBlocks & tData(ii).Block > usBlock+blocksToSkip-1);

    [slope, bias, downshift, scale] = fitSigmoid(tData(ii).delay(beforeIdx),tData(ii).ch(beforeIdx));
    x0 = equalProbabilityPoint(slope,bias,downshift,scale);
    pBefore(ii) = x0;

    [slope, bias, downshift, scale] = fitSigmoid(tData(ii).delay(afterIdx),tData(ii).ch(afterIdx));
    y(ii) = sigmoid_ext(x0,slope,bias,downshift,scale);
    pAfter(ii) = equalProbabilityPoint(slope,bias,downshift,scale);
end