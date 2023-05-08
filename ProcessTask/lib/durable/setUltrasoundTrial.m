% setUltrasoundTrial.m takes the data in the struct tData and determines
% the sonication on which the ultrasound was delivered. The sonicatedTrial
% is assumed to be the trial following the longest pause in the task -
% representing the time when the investigator perfromed the injection.
% 
% @INPUTS
%   tData: data struct returned by loadMonk
% 
% @OUTPUTS
%   tData: the incoming data struct modified so that sonicatedTrials is set
%     to be the trial following the longest pause in the task.
% 
% Taylor Webb
% Spring, 2023
function tData = setUltrasoundTrial(tData)

for ii = 1:length(tData)
    if ~isnan(tData(ii).sonicatedTrials)
        error('sonicatedTrials is already set!')
    end
    time = [tData(ii).timing.startTime];
    [~,idx] = max(diff(time));
    tData(ii).sonicatedTrials = idx+1;
end
