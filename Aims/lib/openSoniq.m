% openSoniq establishes a connection to Soniq. Soniq must be running
% 
% @INPUTS
%   lib: MATLAB alias of dll
%
% @OUTPUTS
%   None
% 
% Taylor Webb
% University of Utah

function openSoniq(lib)
if calllib(lib,'SoniqRunning')==0
   error('Soniq is not running!')
   return
end

%open Soniq comm
calllib (lib,'OpenSoniqConnection','localhost');