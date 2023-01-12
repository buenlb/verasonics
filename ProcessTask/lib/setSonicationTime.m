% This function sets the index at which the sonication occured. It assumes
% that the largest gap in the trial times is the gap that occured during
% injection.
% 
% @INPUTS: 
%   tData: Struct containing trial data. Created by loadMonk
% 
% @OUTPUTS
%   tData: Same struct now containing the field sonicatedTrials.
% 
% Taylor Webb
% December 2022

function tData = setSonicationTime(tData)

trialTm = zeros(size(tData.timing));
for ii = 1:length(tData.timing)
    trialTm(ii) = tData.timing(ii).startTime;
end

gapTime = diff(trialTm);
if sum(gapTime>200)>1
    keyboard
else
    [~,tData.sonicatedTrials] = max(gapTime);
    tData.sonicatedTrials = tData.sonicatedTrials+1;
end