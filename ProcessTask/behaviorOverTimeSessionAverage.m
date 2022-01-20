function [time,p50,m_0delay,ch,y] = behaviorOverTimeSessionAverage(tData,type,windowSize,x0)


%% Compute 50% bias point for each structure in tData, average over them
time = cell(size(tData));


%% Figure out how many different delays we need to deal with
totDelays = [];
for ii = 1:length(tData)
        delay = unique(tData(ii).delay);
        totDelays = unique([totDelays,delay]);
end

% ep = zeros(floor(length(tData(ii).ch)/(windowSize*length(delay))),1);
% m0 = ep;
jj = 1;
dataRemains = 1;
while dataRemains
    curCh = nan(length(totDelays),length(tData));
    dataRemains = 0;
    for ii = 1:length(tData)
        if jj == 20
            keyboard;
        end
        curIdx = ((jj-1)*windowSize*length(delay)+1):(jj*windowSize*length(delay));
        try
            delay = unique(tData(ii).delay);
            for kk = 1:length(delay)
                curIdx = ((jj-1)*windowSize*length(delay)+1):(jj*windowSize*length(delay));
                if sum(tData(ii).delay(curIdx)==delay(kk))~=windowSize
                    wlabel = [];
                    for ll = 1:length(delays)
                        wlabel = [wLabel,', ', num2str(sum(tData(ii).delay(curIdx)==delay(ll)))];
                    end
                    warning(['Wrong number of delays. BlockNo: ', num2str(jj),'. # Delays: ', wlabel]);
                end
                if sum(~tData(ii).correctDelay(curIdx))
                    warning(['Removing ', num2str(sum(~tData(ii).correctDelay(curIdx))), ' trials for incorrect delay.'])
                end
                curIdx = curIdx(logical(tData(ii).correctDelay(curIdx)));
                
                curCh(delay(kk)==totDelays,ii) = mean(tData(ii).ch(curIdx(tData(ii).delay(curIdx)==delay(kk))));
                dataRemains = 1;
            end
            time{ii}(jj) = tData(ii).timing(curIdx(1)).startTime;
        catch
            curCh(:,ii) = nan;
        end
    end
    ch(:,jj) = mean(curCh,2,'omitnan');

    if strcmp(type,'EqualProb') || strcmp(type,'Both')
        [slope, bias, downshift, scale] = fitSigmoid(totDelays, ch(:,jj));
        ep(jj) = equalProbabilityPoint(slope,bias,downshift,scale);
        if exist('x0','var')
            y(jj) = sigmoid_ext(x0,slope,bias,downshift,scale);
        end
    end
    if strcmp(type,'0Delay') || strcmp(type,'Both')
        m0(jj) = mean(ch(totDelays==0,jj),'omitnan');
    end
    jj = jj+1;
end
p50 = ep;
m_0delay = m0;
time = time{ii}-time{ii}(1);
    
