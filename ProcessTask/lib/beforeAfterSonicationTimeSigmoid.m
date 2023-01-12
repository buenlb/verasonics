function [sigParamsAfter,meanChoicesAfter,sigParamsBefore,meanChoicesBefore,allDelays,nTrialsBefore,nTrialsAfter,totIdxBefore,totIdxAfter] = beforeAfterSonicationTimeSigmoid(tData,tWindow,blocksToSkip)

pBefore = zeros(size(tData));
pAfter = pBefore;
y = pBefore;
nTrialsBefore = pBefore;
nTrialsAfter = pBefore;
totIdxBefore = cell(size(tData));
totIdxAfter = cell(size(tData));
for ii = 1:length(tData)
    delays = unique(tData(ii).delay);
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
    sigParamsBefore(ii) = struct('slope',slope,'bias',bias,'downshift',downshift,'scale',scale);
    
    curCh = tData(ii).ch(beforeIdx);
    curDelay = tData(ii).delay(beforeIdx);
    for jj = 1:length(delays)
        meanChoicesBefore{ii}(jj) = mean(curCh(curDelay==delays(jj)),'omitnan');
    end

    [slope, bias, downshift, scale] = fitSigmoid(tData(ii).delay(afterIdx),tData(ii).ch(afterIdx));
    y(ii) = sigmoid_ext(x0,slope,bias,downshift,scale);
    pAfter(ii) = equalProbabilityPoint(slope,bias,downshift,scale);
    sigParamsAfter(ii) = struct('slope',slope,'bias',bias,'downshift',downshift,'scale',scale);
    
    curCh = tData(ii).ch(afterIdx);
    curDelay = tData(ii).delay(afterIdx);
    for jj = 1:length(delays)
        meanChoicesAfter{ii}(jj) = mean(curCh(curDelay==delays(jj)),'omitnan');
    end
    allDelays{ii} = delays;
end