% add an escape character, escapeChar before all spaces in the string, str
% 
% @INPUTS
%   str: string to escape
%   escapeChar: character to place before spaces
% 
% @OUTPUTS
%   escapedStr: str with escapeChar added before all spaces
% 
% Taylor Webb
% University of Utah

function escapedStr = escapeSpaces(str,escapeChar)
notDone = 1;
idx = 1;
while notDone
    if str(idx) == ' '
        str = [str(1:idx-1),escapeChar,str(idx:end)];
        idx = idx+1;
    end
    idx = idx+1;
    if idx == length(str)
        notDone = 0;
    end
end
escapedStr = str;