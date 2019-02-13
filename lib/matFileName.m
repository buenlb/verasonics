% Generate a name with which to save the structs. This function also
% performs some error checking to ensure that there are not duplicates of
% this mat file on the current MATLAB path.
% 
% @INPUTS
%   scriptName: Full path to the calling script. Simply pass the output of
%     mfilename('fullpath')
% 
% @OUTPUTS
%   fName: Full path and file name for saving the mat file.
% 
% Taylor Webb
% University of Utah
% February 2019

function fName = matFileName(scriptName)
%% Error Checking
% Make sure the scriptName makes sense. This can be a problem if the call
% to mfilename was made using ctrl+enter instead of actually running the
% script
if contains(scriptName,'~')
    error('%s\n%s','You probably called this with ctrl+enter',...
        'mfilename doesn''t give a valid path under this condition')
end

%% Setup the name
idx = strfind(scriptName,'\');
directory = scriptName(1:idx(end-1));
shortScriptName = scriptName(idx(end)+1:end);

if ~exist([directory,'MATFILES'],'dir')
    mkdir([directory,'MATFILES']);
end

fName = [directory,'MATFILES\',shortScriptName,'.mat'];

%% Error checking: 
% Make sure no other matfiles with the same name exist on the current path!
pthCheck = which(fName);
if isempty(pthCheck)
    % Passed!
    return;
elseif ~strcmp(fName,pthCheck)
    error('There is another mat file with this name in the MATLAB Path!')
else
    disp('INFO: You are overwriting an existing mat file.')
end
