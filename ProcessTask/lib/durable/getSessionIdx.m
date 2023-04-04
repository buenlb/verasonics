function idx = getSessionIdx(sessions,varargin)
if mod(nargin-1,3)
    error('Incorrect number of values')
end

for ii = 1:length(varargin)/3
    field = varargin{(ii-1)*3+1};
    if ~isfield(sessions(1),field)
        error([field, ' is not a valid field in sessions'])
    end
    counter = 1;
    curIdx = [];
    for jj = 1:length(sessions)
        switch varargin{ii*3}
            case '>'
                if sessions(jj).(field)>varargin{(ii-1)*3+2}
                    curIdx(counter) = jj; %#ok<AGROW> 
                    counter = counter+1;
                end
            case '<'
                if sessions(jj).(field)<varargin{(ii-1)*3+2}
                    curIdx(counter) = jj; %#ok<AGROW> 
                    counter = counter+1;
                end
            case '='
                if sessions(jj).(field)==varargin{(ii-1)*3+2}
                    curIdx(counter) = jj; %#ok<AGROW> 
                    counter = counter+1;
                end
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
