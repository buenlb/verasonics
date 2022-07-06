function [y,pBefore,pAfter,nTrialsBefore,nTrialsAfter,totIdxBefore,totIdxAfter] = beforeAfterSonicationTime(tData,tWindow,blocksToSkip)

delays = unique(tData(1).delay);
for ii = 1:length(tData)
    delays = unique([unique(tData(ii).delay); delays]);
end

if length(delays) > 5
    warning('Extra delays. Throwing out any extra delays from before US')
    delays = unique(tData(1).delay(150:end));
    if length(delays)>5
        error('Still too many delays')
    end
end

pBefore = zeros(size(tData));
pAfter = pBefore;
y = pBefore;
nTrialsBefore = pBefore;
nTrialsAfter = pBefore;
totIdxBefore = cell(size(tData));
totIdxAfter = cell(size(tData));
for ii = 1:length(tData)
    curTime = [tData(ii).timing.startTime];
    usIdx = find(tData(ii).Block==40);
    usIdx = usIdx(1);
    curTime = curTime-curTime(usIdx);

    beforeIdx = find(curTime>=-tWindow & curTime<0);
    afterIdx = find(curTime>=0 & curTime<tWindow);

    nTrialsBefore(ii) = length(beforeIdx);
    nTrialsAfter(ii) = length(afterIdx);

    for jj = 1:blocksToSkip
        afterIdx = afterIdx(tData(ii).Block(afterIdx)~=40+jj-1);
    end

    totIdxBefore{ii} = beforeIdx;
    totIdxAfter{ii} = afterIdx;

    [slope, bias, downshift, scale] = fitSigmoid(tData(ii).delay(beforeIdx),tData(ii).ch(beforeIdx));
    x0 = equalProbabilityPoint(slope,bias,downshift,scale);
    pBefore(ii) = x0;

    [slope, bias, downshift, scale] = fitSigmoid(tData(ii).delay(afterIdx),tData(ii).ch(afterIdx));
    y(ii) = sigmoid_ext(x0,slope,bias,downshift,scale);
    pAfter(ii) = equalProbabilityPoint(slope,bias,downshift,scale);
end