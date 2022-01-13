function tData = selectSubTdata(tData,idx)

nCh = length(tData.ch);

nms = fieldnames(tData);
for ii = 1:length(nms)
    sz = eval(['size(tData.',nms{ii},');']);
    if sz(1)==nCh&&sz(2)==1 || sz(1)==1&&sz(2)==nCh
        eval(['tData.',nms{ii},'=tData.',nms{ii},'(idx);'])
    elseif sz(1)==nCh
        eval(['tData.',nms{ii},'=tData.',nms{ii},'(idx,:);'])
    elseif sz(2)==nCh
        eval(['tData.',nms{ii},'=tData.',nms{ii},'(:,idx);'])
    elseif length(sz)>2
        if sz(3)==nCh
            eval(['tData.',nms{ii},'=tData.',nms{ii},'(:,:,idx);'])
        end
    end
end

