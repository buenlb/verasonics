% verasonics1dScan sets up the nessecary parameters to do a 1 dimensional
% scan on the verasonics system. Inputs are optional - if none are provided
% then the user will be prompted for the relevant parameters. If some are
% provided all must be provided
% 
% @INPUTS
%   axis: the axis along which to do the scan
%      (0:left/right,1:front/back,2:up/down)
%   sl: start location (in absolute coordinates)
%   el: end location (in absolute coordinates)
%   np: number of points to scan
% 
% @OUTPUTS
%   lib: MATLAB alias of the opened Soniq DLL
%   locs: scan locations
%   axis: axis on which to perform scan
% 
% Taylor Webb
% University of Utah

function [lib,axis,locs] = verasonics1dScan(axis,sl,el,np)

if nargin ~= 4 && nargin ~= 0
    error('Must provide all four grid parameters or none!')
end
%% Connect to Soniq
lib = loadSoniqLibrary();
openSoniq(lib);

if nargin == 0
    %% Get user defined parameters of scan
    axis = input('Axis ?>>');
    % Make sure an allowed axis was entered
    if axis < 0 || axis > 2 || mod(axis,1)
        error('Axis must be 0, 1, or 2')
    end
    sl = input('Start Location ?>>');
    % Check limits
    if ~withinLimits(lib,axis,sl)
        error('Outside of limits!')
    end

    el = input('End Location ?>>');
    %Check Limits
    if ~withinLimits(lib,axis,el)
        error('Outside of limits!')
    end

    np = input('Number of Points?>>');
    if mod(np,2)
        error('Verasonics can only handle an even number of frames => Number of points must be even')
    end
else
    %% User already supplied input - error check it
    if axis < 0 || axis > 2 || mod(axis,1)
        error('Axis must be 0, 1, or 2')
    end
    if ~withinLimits(lib,axis,sl)
        error('Start location is outside of limits!')
    end
    if ~withinLimits(lib,axis,el)
        error('End location is outside of limits!')
    end
    if mod(np,2)
        error('Verasonics can only handle an even number of frames => Number of points must be even')
    end
end

%% Set up grid
locs = linspace(sl,el,np);

%% Move to start location
movePositionerAbs(lib,axis,locs(1));