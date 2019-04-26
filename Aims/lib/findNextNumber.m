% Helper function to find the next number when reading a text header.
% 
% @INPUTS
%   text: string to look in
%   idx: index to start at
% 
% @OUTPUTS
%   x: the next number in the sequence
% 
% Taylor Webb
% University of Utah
% 2019

function x = findNextNumber(text,curIdx)
curChar = text(curIdx);
while isnan(str2double(curChar)) || curChar == 'i' || curChar == 'j'
    curIdx = curIdx+1;
    curChar = text(curIdx);
end
stIdx = curIdx;
while ~isnan(str2double(curChar)) || curChar == '.'
    curIdx = curIdx+1;
    curChar = text(curIdx);
end
eIdx = curIdx-1;

x = str2double(text(stIdx:eIdx));

if text(stIdx-1) == '-'
    x = -x;
end