function [time,p50,m_0delay] = behaviorOverTime(tData,lgn,type,windowSize,minWindow)

if ~exist('windowSize','var')
    windowSize = 10;
    minWindow = 8;
end

%% Compute 50% bias point for each structure in tData, average over them
p50 = cell(size(tData));
m_0delay = cell(size(tData));

time = cell(size(tData));
for ii = 1:length(tData)
    disp([num2str(ii), ' of ', num2str(length(tData))])
    
    idx = find(tData(ii).lgn==lgn);
    
    rawTime = [tData(ii).timing.startTime];
    if sum(diff(rawTime)<0)
        tmJump = find(diff(rawTime)<0);
        rawTime(tmJump+1:end) = rawTime(tmJump)-rawTime(tmJump+1)+rawTime(tmJump+1:end);
    end
    
    tWindowSize = windowSize*length(tData(ii).delayVector);
    ep = zeros(length(idx)-tWindowSize,1);
    m0 = ep;
    for jj = 1:(length(idx)-tWindowSize)
        curChIdx = idx(jj):(idx(jj)+tWindowSize);
        time{ii}(jj) = rawTime(curChIdx(ceil(length(curChIdx))));
        
        delay = tData(ii).delay(curChIdx);
            ch = tData(ii).ch(curChIdx);
        if sum(delay==0 & ~isnan(ch))<minWindow && checkBucketSizes(tData(ii).delayVector,tData(ii).delay(curChIdx)',tData(ii).ch(curChIdx),minWindow)
            keyboard
        end
        
        if strcmp(type,'EqualProb') || strcmp(type,'Both')
            if ~checkBucketSizes(tData(ii).delayVector,tData(ii).delay(curChIdx)',tData(ii).ch(curChIdx),minWindow)
                ep(jj) = nan;
            else

    %         [slopej, biasj, downshiftj, scalej] = sigmoid_plot2(tData(ii).delay(idx(jj):(idx(jj)+tWindowSize))', tData(ii).ch(idx(jj):(idx(jj)+tWindowSize)), [], [0,0,0], 4);
                [slope, bias, downshift, scale] = fitSigmoid(tData(ii).delay(curChIdx)', tData(ii).ch(curChIdx));
                ep(jj) = equalProbabilityPoint(slope,bias,downshift,scale);
            end
        end
        if strcmp(type,'0Delay') || strcmp(type,'Both')
            delay = tData(ii).delay(curChIdx);
            ch = tData(ii).ch(curChIdx);
            if sum(delay==0 & ~isnan(ch))<minWindow
                m0(jj) = nan;
            else
                m0(jj) = mean(ch(delay==0),'omitnan');
            end
        end
    end
    p50{ii} = ep;
    m_0delay{ii} = m0;
    if ~isempty(time{ii})
        time{ii} = time{ii}-rawTime(1);
    end
end
    
