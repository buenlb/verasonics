% getSessionIdx returns the indices of the sessions in sessions that meet
% the intersection of the conditions contained in varargin. 
% 
% The conditions must be passed as three variable sets. The conditions
% specify 1) the field in sessions to compare to, 2) the value to be
% compared, and 3) the method of comparison.
% 
% For example, if you want all the sessions that exceed an Ispta of 1
% W/cm^2 you would type:
% 
% getSessionIdx(sessions, 'Ispta', 1, '>');
% 
% If you wanted only the sessions that both exceed 1 w/cm^2 and have a
% duration less than five minutes this becomes:
% 
% getSessionIdx(sessions, 'Ispta', 1, '>', 'duration', 300, '=');
% 
% Note that this does not allow comparison of fields that contain arrays -
% only fields that contain scalars. To select sessions with a specific
% focus use selectByFocus.m
% 
% @INPUTS
%   sessions: An array of structs created by the function sortSessions
%   varargin: 3 variable sets specifying the conditions that the returned
%    sessions should meet.

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
                if length(sessions(jj).(field)) > 1
                    if sum(sessions(jj).(field) == varargin{ii-1}*3+2)==length(sessions(jj).field)
                        curIdx(counter) = jj; %#ok<AGROW> 
                        counter = counter+1;
                    end
                else
                    if sessions(jj).(field)==varargin{(ii-1)*3+2}
                        curIdx(counter) = jj; %#ok<AGROW> 
                        counter = counter+1;
                    end
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
