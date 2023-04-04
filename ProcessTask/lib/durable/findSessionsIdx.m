function sIdx = findSessionsIdx(sessions,idx)
sIdx = zeros(size(idx));
for ii = 1:length(idx)
    for jj = 1:length(sessions)
        if ismember(idx(ii),sessions(jj).sessionsLeft)
            sIdx(ii) = jj;
        elseif ismember(idx(ii),sessions(jj).sessionsRight)
            sIdx(ii) = jj;
        elseif ismember(idx(ii),sessions(jj).sessionsCtl)
            sIdx(ii) = jj;
        end
    end
end
