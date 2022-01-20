% Turns FG output on/off
% 
% @INPUTS
%   fg: pointer to opened function generator
%   ch: channel (1|2)
%   on: whether to turn output on or off (ON|OFF). Defaults to ON
% 
% Taylor Webb
% taylorwebb85@gmail.com
function outpOn(fg,ch,on)
if ~exist('on','var')
    on = 'ON';
end

fprintf(fg,['OUTP',num2str(ch),' ', on]);

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