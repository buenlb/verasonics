function [time,p50,m_0delay,y] = behaviorOverTimeKnownBlocks(tData,type,windowSize,x0)


%% Compute 50% bias point for each structure in tData, average over them
p50 = cell(size(tData));
m_0delay = cell(size(tData));
time = cell(size(tData));
y = cell(size(tData));
for ii = 1:length(tData)
    disp([num2str(ii), ' of ', num2str(length(tData))])
    
    delay = unique(tData(ii).delay);
    ep = zeros(floor(length(tData(ii).ch)/(windowSize*length(delay))),1);
    m0 = ep;
    for jj = 1:(floor(length(tData(ii).ch)/(windowSize*length(delay))))
        curIdx = ((jj-1)*windowSize*length(delay)+1):(jj*windowSize*length(delay));
        time{ii}(jj) = tData.timing(curIdx(1)).startTime;

        for kk = 1:length(delay)
            if sum(tData.delay(curIdx)==delay(kk))~=windowSize
%                 keyboard
                warning('Wrong number of delays');
            end
        end

        if strcmp(type,'EqualProb') || strcmp(type,'Both')
            if sum(~tData.correctDelay(curIdx))
                warning(['Removing ', num2str(sum(~tData.correctDelay(curIdx))), ' trials for incorrect delay.'])
            end
            curIdx = curIdx(logical(tData.correctDelay(curIdx)));
            [slope, bias, downshift, scale] = fitSigmoid(tData(ii).delay(curIdx)', tData(ii).ch(curIdx));
            ep(jj) = equalProbabilityPoint(slope,bias,downshift,scale);
%             if isnan(ep(jj))
%                 keyboard
%             end
            if exist('x0','var')
                y{ii}(jj) = sigmoid_ext(x0,slope,bias,downshift,scale);
            end
        end
        if strcmp(type,'0Delay') || strcmp(type,'Both')
            ch = tData(ii).ch(curIdx);
            m0(jj) = mean(ch(tData(ii).delay(curIdx)==0),'omitnan');
        end
    end
    p50{ii} = ep;
    m_0delay{ii} = m0;
    time{ii} = time{ii}-time{ii}(1);
end
    
