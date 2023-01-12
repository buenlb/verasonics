function tData = removeExcessSonications(tData)
if length(tData.sonicatedTrials)>1
    disp(['Session contains ', num2str(length(tData.sonicatedTrials)), ' sonications.'])
    idx = 1:(tData.sonicatedTrials(2)-1);
    tData = selectSubTdata(tData,idx);
    tData.sonicatedTrials = tData.sonicatedTrials(1);
end