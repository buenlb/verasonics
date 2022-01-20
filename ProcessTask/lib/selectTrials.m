function newT = selectTrials(tData,idx)

fieldNames = fieldnames(tData);
nTrials = length(tData.ch);

for ii = 1:length(fieldNames)
    cf = getfield(tData,fieldNames{ii});
    
    if isscalar(cf)
        eval(['newT.',fieldNames{ii},'=cf';]);
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