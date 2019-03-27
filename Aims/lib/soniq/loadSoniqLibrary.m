% loadSoniqLibrary loads the 64 bit Soniq dll using a default path of 
% C:\Program Files (x86)\Soniq\SoniqClient64.dll
% 
% @INPUTS
%   None
%
% @OUTPUTS
%   lib: MATLAB assigned alias of the library
% 
% Taylor Webb
% University of Utah

function lib = loadSoniqLibrary()

lib = 'soniq';

if not(libisloaded('soniq'))
    loadlibrary('C:\Program Files (x86)\Soniq\SoniqClient64.dll',...
        'C:\Users\Public\Documents\Soniq\Delphi\SoniqClient64Interface.h',...
        'alias',lib)
else
    disp('INFO: Library already loaded.')
end