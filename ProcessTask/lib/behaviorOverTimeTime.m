function [time,p50,y,m0,rawCh,nTrials,blocksUsed] = behaviorOverTimeTime(tData,tWindow,x0,time)

useBlocks = 0;

% Find Delays
delay = unique(tData.delay);
if length(delay) > 5
    delay = unique(tData.delay(150:end));
    warning('Removing early delays.');
    if length(delay)>5
        error('Too many delays');
    end
end

% Find the index for the end of each block
blocks = [tData.Block];
tmp = [diff(blocks),0];
nBlockIdx = find(tmp);

% Find the time at which the end of each block was acquired
trTime = [tData.timing.startTime];
blockTime = trTime(nBlockIdx);
blocksWithTime = blocks(nBlockIdx);

% Set the time to be zero at the sonication
usBlock = 40;
stIdx = find(blocks==usBlock);
stIdx = stIdx(1);
blockTime = blockTime-trTime(stIdx);
trTime = trTime-trTime(stIdx);

% Create the time axis
if ~exist('time','var')
    minTime = ceil(-min(blockTime)/tWindow);
    maxTime = ceil(max(blockTime)/tWindow);
    time = -minTime*tWindow:tWindow:maxTime*tWindow;
end

% Initialize Variables
p50 = nan(size(time));
y = nan(size(time));
m0 = nan(size(time));
rawCh = nan(size(time));
nTrials = zeros(size(time));
blocksUsed = cell(size(time));
% Look through time
for ii = 1:(length(time))
%     disp(['  Processing time block ', num2str(ii) ' of ', num2str(length(time))])
    
    % Figure out which blocks are in the current window. Note that
    % time(ii)-time(ii-1) may not equal tWindow (in the case of overlapping
    % windows)
    if useBlocks
        curBlocks = blocksWithTime(blockTime<time(ii) & blockTime>=time(ii)-tWindow);
        
        % Remove the two blocks during the sonication
        if time(ii)==0
            curBlocks = curBlocks(curBlocks~=40);
            curBlocks = curBlocks(curBlocks~=41);
        end
    
        % Figure out which trials belong to this time block
        curIdx = find(ismember(blocks,curBlocks));
        blocksUsed{ii} = curBlocks;
    else
        curIdx = find(trTime<time(ii) & trTime>=time(ii)-tWindow & tData.correctDelay');

        % Remove sonication blocks
        % curIdx = curIdx(blocks(curIdx)~=usBlock & blocks(curIdx)~=usBlock+1);

        blocksUsed{ii} = curIdx;
    end
    if length(curIdx)<150
        continue;
    end

    % Match choices to the correct delay
    curCh = zeros(size(delay));
    tmpCh = tData.ch(curIdx);
    tmpDelay = tData.delay(curIdx);
    for kk = 1:length(delay)
        curCh(delay(kk)==delay) = mean(tmpCh(tmpDelay==delay(kk)),'omitnan');
    end
    rawCh(ii) = mean(tData.ch(curIdx),'omitnan');
    
    % Compute Sigmoid
    if sum(isnan(curCh))
        continue;
    end
    [slope, bias, downshift, scale] = fitSigmoid(delay, curCh);

    % Note the number of trials contributing to this time block
    nTrials(ii) = length(curIdx);

    %Equal Probability Point
    p50(ii) = equalProbabilityPoint(slope,bias,downshift,scale);

    % Bias at x0
    if exist('x0','var')
        if ~isempty(x0)
            y(ii) = sigmoid_ext(x0,slope,bias,downshift,scale);
        end
    end

    % Bias at 0 delay
    m0(ii) = curCh(delay==0);
end
