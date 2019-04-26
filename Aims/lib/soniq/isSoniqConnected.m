% isSoniqConnected returns true if a connection with the soniq software is
% currently open
% 
% @INPUTS
%   lib: MATLAB alias of dll
%
% @OUTPUTS
%   connected: true if soniq connection is open and false otherwise
% 
% Taylor Webb
% University of Utah

function connected = isSoniqConnected(lib)

connected = calllib (lib,'Connected');