% Receives instructions for a focal spot from the server. Expects voltage
% followed by x,y,z coordinates in mm
% 
% @INPUTS
%   pt: serial port through which to receive the connection. Must already
%     be open.
% 
% @OUTPUTS
%   v: voltage of sonication.
%   target: target of sonication <x,y,z> in mm
% 
% Taylor Webb
% University of Utah

function [v,target] = receiveFocusFromServer(pt)
msg = fscanf(pt);
while isempty(msg)
    msg = fscanf(pt);
end
msg = msg(1:end-1);
result = sscanf(msg,'%f,');
if length(result) ~= 4
    fprintf(pt,['Expected 4 floats but received, ', msg]);
    error(['Expected 4 floats but received ', msg])
end
v = result(1);
target = result(2:4)';
fprintf(pt,msg);