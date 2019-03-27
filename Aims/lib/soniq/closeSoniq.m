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

function closeSoniq(lib)

%open Soniq comm
calllib (lib,'CloseSoniqConnection');