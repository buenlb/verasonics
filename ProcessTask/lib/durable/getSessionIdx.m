function idx = getSessionIdx(sessions,varargin)
if mod(nargin-1,2)
    error('Incorrect number of values')
end

for ii = 1:length(varargin)/2
    field = varargin{(ii-1)*2+1};
    if ~isfield(sessions(1),field)
        error([field, ' is not a valid field in sessions'])
    end
    counter = 1;
    curIdx = [];
    for jj = 1:length(sessions)
        if sessions(jj).(field)==varargin{ii*2}
            curIdx(counter) = jj; %#ok<AGROW> 
            counter = counter+1;
        end
    end

    if ii == 1
        idx = curIdx;
    else
        idx = intersect(idx,curIdx);
    end
    if isempty(idx)
        return
    end
end
