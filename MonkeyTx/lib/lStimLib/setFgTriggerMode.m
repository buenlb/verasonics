% Sets the preferences for the function generator, fg.
% 
% @INPUTS
%   fg: Opened pointer to the FG
%   ch: Channel on which to implement the settings
%   source: Source of trigger (IMM|EXT|BUS). IMM: Immediate, EXT: external,
%       BUS: Manual. I haven't implemented the timer option.
%   delay: delay in ms (default is 0)
%   slope: slope of trigger (POS|NEG). (default is POS). Note that this has
%       no effect if the source is not EXT and is an optional paramter
% 
% @OUTPUTS
%   None
% 
% Taylor Webb
% taylorwebb85@gmail.com

function setFgTriggerMode(fg,ch,source,delay,slope)
if ~exist('delay','var')
    delay = 0;
end

command = ['TRIG',num2str(ch),':SOUR ',source];
fprintf(fg,command);

command = ['TRIG',num2str(ch),':DEL ',num2str(delay*1e-3)];
fprintf(fg,command);

if exist('slope','var')
    command = ['TRIG',num2str(ch),':SLOP ',slope];
    fprintf(fg,command);
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