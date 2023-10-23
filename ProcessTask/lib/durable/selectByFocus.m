function idx = selectByFocus(tData,desiredFocus)

curIdx = 1;
for ii = 1:length(tData)
    if sum(tData(ii).sonication.focalLocation==desiredFocus)==3
        idx(curIdx) = ii; %#ok<AGROW> 
        curIdx = curIdx+1;
    end
end