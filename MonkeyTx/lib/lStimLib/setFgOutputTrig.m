% Sets output trigger
% 
% @INPUTS
%   fg: Opened pointer to FG (VISA Object)
%   on: Trigger on or off (ON|OFF)
%   ch: Source for output trigger (1|2)
%   slope: Slope of trigger (POS|NEG)
% 
% @OUTPUTS
%   None
% 
% Taylor Webb
% taylorwebb85@gmail.com

function setFgOutputTrig(fg,on,ch,slope)

if ch ~= 1 && ch ~= 2
    error('Channel must be 1 or 2');
end

command = ['OUTP:TRIG ',on];
fprintf(fg,command);

command = ['OUTP:TRIG:SLOP ',slope];
fprintf(fg,command);

command = ['OUTP:TRIG:SOUR CH',num2str(ch)];
fprintf(fg,command);

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