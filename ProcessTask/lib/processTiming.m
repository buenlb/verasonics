% Saves event timing and eye data in a struct
% 
% @INPUTS
%   trial: A single trial from the trial_data struct
% 
% @OUTPUTS
%   timing: A struct with fields
%       eyePos: Nx2 vector of x,y locations of eye tracking measuremnets
%       eyeTm: timing of recorded eyePos relative to the start of the trial
%         (trial.start_t)
%       eventTimes: Time at which events occured (also relative to start_t)
%       eventNames: Names of events that correspond to eventTimes.
% 
% Taylor Webb
% University of Utah

function timing = processTiming(trial)

eyePos = [trial.eye_data(:,1), trial.eye_data(:,2)];
eyeTm = trial.eye_data(:,4) - trial.start_t;

eventTimes = trial.event_time;
eventNames = trial.event_name;

timing = struct('eyePos',[],'eyeTm',[],'eventTimes',[],...
    'eventNames',[],'startTime',trial.start_t);

timing.eyePos = eyePos;
timing.eyeTm = eyeTm;
timing.eventTimes = eventTimes;
timing.eventNames = eventNames;
