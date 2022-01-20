% Check for remote errors on the function generator
% 
% @INPUTS
%   fg: pointer to opened function generator (VISA object)
% 
% @OUTPUTS
%   err: 0 of there is no error. If there is an error it returns the text
%       returned by the FG
% 
% Taylor Webb
% taylorwebb85@gmail.com

function err = checkFgError(fg)

fprintf(fg,'SYST:ERR?');
err = fscanf(fg);

if strcmp(err(1:13),'+0,"No error"')
    err = 0;
end
