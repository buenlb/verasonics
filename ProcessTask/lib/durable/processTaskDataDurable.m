% processTaskData plots sigmoids for the task result and returns a struct
% with the results
% 
% @INPUTS
%   fName: file name from which to load the task data structure. This file
%       must contain the task_data struct created by the server.
% 
% @OUTPUTS
%   tData: struct containing results
%         
% Taylor Webb
% University of Utah

function tData = processTaskDataDurable(fName)

tic
trialData = load(fName,'trial_data');
toc
trial_data = trialData.trial_data;
if isempty(trial_data)
    tData = nan;
    return
end

% Sometimes it populates a trial that doesn't finish. If this is the case,
% get rid of that trial.
if ~isfield(trial_data{end},'us')
    trial_data = trial_data(1:end-1);
end
loc = nan(2,4,length(trial_data));
ch = nan(size(trial_data));
delay = ch;
voltage = ch;
correctDelay = ch;
dur = ch;
freq = ch;
prf = ch;
dc = ch;
block = ch;
sonicatedTrials = nan;
idxSonicatedTrials = 1;
focus = nan(length(trial_data),3);
nFoci = focus;
dev = focus;
freeChoice = ch;
taskType = blanks(length(ch));
for ii = 1:length(trial_data)
    % Save the delay for each trial
    delay(ii) = trial_data{ii}.timingOffset;

    % Convert his choice into a 1 for leftward choice, 0 for a rightward
    % choice and nan if he made no choice.
    if isfield(trial_data{ii},'choice')
        if ~iscell(trial_data{ii}.choice)
            ch(ii) = nan;
        elseif strcmp(trial_data{ii}.choice{1},'left')
            ch(ii) = 1;
        else
            ch(ii) = 0;
        end
    else
        ch(ii) = nan;
    end

    % Save the position of the visual target
    loc(:,:,ii) = trial_data{ii}.targ_pos;

    % If a trigger was sent to verasonics, us.sonicated is 1. This is an
    % extra check on when ultrasound occured. It doesn't apply to injection
    % sessions because the ultrasound is turned on manually in those
    % sessions.
    if isfield(trial_data{ii},'injection')
        if trial_data{ii}.injection
        elseif trial_data{ii}.us.sonicated
            sonicatedTrials(idxSonicatedTrials) = ii;
            idxSonicatedTrials = idxSonicatedTrials+1;
        end
    elseif (trial_data{ii}.us.sonicated)
        sonicatedTrials(idxSonicatedTrials) = ii;
        idxSonicatedTrials = idxSonicatedTrials+1;
    end

    % Get the timing for each event in this trial
    timing(ii) = processTiming(trial_data{ii}); %#ok<AGROW> 

    if ~isfield(trial_data{ii},'voltage')
        error('PROCESS:notDurable',[fName, ' appears to be a non-durable session!'])
    end
    voltage(ii) = trial_data{ii}.voltage;
    dc(ii) = trial_data{ii}.us_duty;
    dur(ii) = trial_data{ii}.us_dur;
    freq(ii) = trial_data{ii}.us_freq;
    prf(ii) = trial_data{ii}.us_prf;
    focus(ii,:) = trial_data{ii}.focalLocation;

    if isfield(trial_data{ii},'nFocalSpots')
        dev(ii,:) = trial_data{ii}.focalDev;
        nFoci(ii,:) = trial_data{ii}.nFocalSpots;
    else
        dev(ii,:) = [0,0,0];
        nFoci(ii,:) = [0,0,0];
    end
    
    % Determine if the delay was correct.
    if abs(abs(delay(ii))-1e3*abs(trial_data{ii}.event_time(4)-trial_data{ii}.event_time(3))) > 7 % the frame period is about 8.3 ms so if it is greater than 7 ms it is off by a frame or more.
        correctDelay(ii) = false;
    else
        correctDelay(ii) = true;
    end

    % Save the block number
    block(ii) = trial_data{ii}.us.bucketCounter;    

    % Save information about the task
    freeChoice(ii) = trial_data{ii}.no_wrong_choice;
    switch(trial_data{ii}.us.trData.task)
        case 'timing'
            taskType(ii) = 't';
        case 'brightness'
            taskType(ii) = 'b';
        otherwise
            taskType(ii) = '?';
    end
end

% If someone changed the sonication parameters after starting the session
% this needs to be appropriately delt with. The software sends the command
% for parameters to the verasonics system at the beginning of the session
% so the first set of parameters is the one delivered to the subject. This
% code also warns the user that this occured. Further investigation of the
% logs is warranted in this case.
curVoltage = unique(voltage);
curDc = unique(dc);
curDur = unique(dur);
curFreq = unique(freq);
curPrf = unique(prf);
for ii = 1:3
    curF = unique(focus(:,ii));
    if length(curF) > 1
        warning('There is only one sonication in durable sessions but this struct contains multiple parameter sets!')
    end

    curF = unique(dev(:,ii));
    if length(curF) > 1
        warning('There is only one sonication in durable sessions but this struct contains multiple parameter sets!')
    end

    curF = unique(nFoci(:,ii));
    if length(curF) > 1
        warning('There is only one sonication in durable sessions but this struct contains multiple parameter sets!')
    end
end
finalFocus = focus(1,:);
finalnFoci = nFoci(1,:);
finalDev = dev(1,:);

if length(curVoltage)>1 || length(curDc)>1 || length(curDur)>1 || length(curFreq)>1 || length(curPrf)>1
    voltage = voltage(1);
    dc = dc(1);
    dur = dur(1);
    freq = freq(1);
    prf = prf(1);
    warning('There is only one sonication in durable sessions but this struct contains multiple parameter sets! Using the first set.')
else
    voltage = curVoltage;
    dc = curDc;
    dur = curDur;
    freq = curFreq;
    prf = curPrf;
end

task = struct('type',taskType,'freeChoice',freeChoice);

sonication = struct('voltage',voltage,'dc',dc,'dur',dur,'freq',freq,'prf',prf,...
    'focalLocation',finalFocus,'nFoci',finalnFoci,'focalDev',finalDev);

tData = struct('delay',delay,'ch',ch,'timing',timing,'sonication',sonication,...
    'loc',loc,'correctDelay',correctDelay,'block',block,...
    'sonicatedTrials',sonicatedTrials,'Task',task);