% Turns FG output on/off
% 
% @INPUTS
%   fg: pointer to opened function generator
%   ch: channel (1|2|BOTH). Defaults to BOTH
% 
% Taylor Webb
% taylorwebb85@gmail.com
function fgTrigger(fg,ch)
if ~exist('ch','var')
    fprintf(fg,'TRIG');
elseif strcmp(ch,'BOTH')
    fprintf(fg,'TRIG');
else
    fprintf(fg,['TRIG',num2str(ch)]);
end

err = checkFgError(fg);
if err
    ii = 1;
    nextErr = 1;
    while nextErr
        nextErr = checkFgError(fg);
        ii = ii+1;
    end
    error([num2str(ii), ' remote errors. First error: ', err])
end