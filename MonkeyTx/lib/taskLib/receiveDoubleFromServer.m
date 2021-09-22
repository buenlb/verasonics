% Receives a number over a serial connection. Throws an error of the
% received message is not numeric. No timeout.
% 
% @INPUTS
%   pt: serial port through which to receive the connection. Must already
%     be open.
% 
% @OUTPUTS
%   result: numerical result. If the message is not numerical an error is
%     thrown before the function returns.
% 
% Taylor Webb
% University of Utah

function result = receiveDoubleFromServer(pt)
msg = fscanf(pt);
while isempty(msg)
    msg = fscanf(pt);
end
msg = msg(1:end-1);
result = str2double(msg);
if isnan(result)
    fprintf(pt,['Expected numerical message but received, ', msg]);
    error(['Expected numerical input but received ', msg])
end
fprintf(pt,msg);