function newT = selectTrials(tData,idx)

found = 0;
for ii = 1:length(tData)
    delays = unique(tData(ii).delay);
    for jj = 1:tData(ii).Block(end)-1
        if sum(tData(ii).Block'==jj-1 & ~isnan(tData(ii).ch) & tData(ii).correctDelay) ~=15
            warning('There is an excess trial! I will remove it but this shouldn''t happen!')
            tmpIdx = find(tData(ii).Block==jj-1);
            for kk = 1:length(delays)
                if sum(tData(ii).delay(tmpIdx)==delays(kk) & tData(ii).correctDelay(tmpIdx) & ~isnan(tData(ii).ch(tmpIdx)))>3
                    tmpIdx2 = find(tData(ii).delay(tmpIdx)==delays(kk) & tData(ii).correctDelay(tmpIdx) & ~isnan(tData(ii).ch(tmpIdx)));
                    idx(tmpIdx(tmpIdx2(end))) = false;
                    found = 1;
                end
            end
            if ~found 
                keyboard
            end
            found = 0;
        end
    end
end

fieldNames = fieldnames(tData);
nTrials = length(tData.ch);

for ii = 1:length(fieldNames)
    cf = getfield(tData,fieldNames{ii});
    
    if isscalar(cf)
        eval(['newT.',fieldNames{ii},'=cf;']);
    elseif (isrow(cf) || iscolumn(cf)) && length(cf)==nTrials
        eval(['newT.',fieldNames{ii},'=cf(idx);']);
    elseif size(cf,1)==nTrials
        eval(['newT.',fieldNames{ii},'=cf(idx,:);']);
    elseif size(cf,2)==nTrials
        eval(['newT.',fieldNames{ii},'=cf(:,idx);']);
    else
        eval(['newT.',fieldNames{ii},'=cf;']);
    end
end