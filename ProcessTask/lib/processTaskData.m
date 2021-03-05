% processTaskData plots sigmoids for the task result and returns a struct
% with the results
% 
% @INPUTS
%   fName: file name from which to load the task data structure. This file
%       must contain the task_data struct created by the server.
% 
% @OUTPUTS
%   tData: struct with fields:
%         result: a vector with a 1 for each trial in which a correct 
%           choice was made, a zero for incorrect choices, 2 if a 
%           contra-hemifield result is detected, 3 if no fixation was
%           achieved, 4 if he fixated but broke it pre-maturely, and 5 if
%           he fixated by failed to make a choice.
%         lgn: -1 if the left LGN was sonicated, 1 if it was the right, and
%           0 if no LGN was sonicated
%         delay: delay in ms used for each trial
%         delayVector: List of all possible delays
%         ch: 1 for a leftward choice, 0 for a rightward choice, nan if no
%           choice was made
%   axs: vector pointing to the three axes used to make the plot. Not
%       returned if plotResults is 0
% 
% Taylor Webb
% University of Utah

function tData = processTaskData(fName)

if nargin < 2
    plotResults = 0;
end

trialData = load(fName);
trial_data = trialData.trial_data;

% Sometimes it populates a trial that doesn't finish. If this is the case,
% get rid of that trial.
if ~isfield(trial_data{end},'us')
    trial_data = trial_data(1:end-1);
end

% Set up variables
lgn = zeros(size(trial_data));
result = lgn;
delay = lgn;
delayVector = [];
ch = lgn;

% Loop through struct
for ii = 1:length(trial_data)
    if trial_data{ii}.us.priorSonications{ii} == 'L'
        lgn(ii) = -1;
    elseif trial_data{ii}.us.priorSonications{ii} == 'R'
        lgn(ii) = 1;
    elseif trial_data{ii}.us.priorSonications{ii} == 'C'
        lgn(ii) = 0;
    end
    
    switch trial_data{ii}.result{1}
        case 'NOFIX'
            result(ii) = 3;
        case 'CORRECT'
            result(ii) = 1;
        case 'FIXBREAK'
            result(ii) = 4;
        case 'WRONG'
            result(ii) = 0;
        case 'CONTRA_HEMIFIELD'
            result(ii) = 2;
        case 'NOCHOICE'
            result(ii) = 5;
    end
    
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
    
    delay(ii) = trial_data{ii}.timingOffset;
    
    if ~ismember(delay(ii),delayVector) && ~isnan(delay(ii))
        delayVector(end+1) = delay(ii); %#ok<AGROW>
    end
end

tData = struct('ch',ch,'delay',delay,'delayVector',delayVector,'lgn',lgn,'result',result);