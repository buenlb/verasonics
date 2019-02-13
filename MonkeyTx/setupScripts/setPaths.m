% This file sets up the correct paths so that lib files (both universal
% files and files specific to the Tx) are available on the MATLAB path. It
% also adds the MATFILES directory to ensure that VSX can find the mat file
% of interest.
% 
% IMPORTANT NOTE
%   Because this sets up the paths it cannot be stored in the universal lib
%   directory. Instead a copy of this file must be stored in each
%   setupScripts folder. When you run the script you want to use to
%   generate a matfile if that script isn't in the MATLAB path select "Add
%   to Path" and this file will take care of the rest of the path setup.

function srcDirectory = setPaths()
%% Add lib/MATFILE path regardless of which machine you are on
% Setup paths
% Find the directory this script is in (could be different since this can
% be run in simulation on individual laptops as well as on the main
% machine) and add the lib path. This will also be used to save the
% resulting mat file.
workingDirectory = mfilename('fullpath');
idx = strfind(workingDirectory,'\');
srcDirectory = workingDirectory(1:idx(end-1));
verasonicsCodeDirectory = workingDirectory(1:idx(end-2));

addpath([srcDirectory,'lib'])
addpath([srcDirectory,'MATFILES'])
addpath([verasonicsCodeDirectory,'lib'])