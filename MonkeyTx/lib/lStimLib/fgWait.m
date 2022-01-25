% Wait for function generator. If WAIT is true then it also stops matlab
% processing until the FG is ready.
% 
% @INPUTS
%   fg: pointer to opened function generator (VISA)
% 
% @OUTPUTS
%   None
% 
% Taylor Webb
% University of Utah
function fgWait(fg)
return
fprintf(fg,'*WAI');