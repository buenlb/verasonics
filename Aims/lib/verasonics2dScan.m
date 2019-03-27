% verasonics1dScan sets up the nessecary parameters to do a 1 dimensional
% scan on the verasonics system. Inputs are optional - if none are provided
% then the user will be prompted for the relevant parameters. If some are
% provided all must be provided
% 
% @INPUTS
%   axis: a 2 x 1 vector specifying the axes along which to do the scan
%      (0:left/right,1:front/back,2:up/down)
%   sl: a 2 x 1 vector of start locations (in absolute coordinates)
%   el: a 2 x 1 vector of end location (in absolute coordinates)
%   np: a 2 x 1 vector of number of points to scan
% 
% @OUTPUTS
%   lib: MATLAB alias of the opened Soniq DLL
%   axis: axis on which to perform scan
%   LOCS1: matrix of scan locations for the first axis
%   LOCS2: matrix of scan locations for the third axis
% 
% Taylor Webb
% University of Utah

function [lib,axis,LOCS1,LOCS2] = verasonics2dScan(axis,sl,el,np)

if nargin ~= 4 && nargin ~= 0
    error('Must provide all four grid parameters or none!')
end
%% Connect to Soniq
lib = loadSoniqLibrary();
openSoniq(lib);

if nargin == 0
    for ii = 1:2
        %% Get user defined parameters of scan
        axis(ii) = input(['Axis ', num2str(ii), '?>>']);
        % Make sure an allowed axis was entered
        if axis(ii) < 0 || axis(ii) > 2 || mod(axis(ii),1)
            error('Axis must be 0, 1, or 2')
        end
        sl(ii) = input('Start Location ?>>');
        % Check limits
        if ~withinLimits(lib,axis(ii),sl(ii))
            error('Start location is outside of limits!')
        end
        el(ii) = input('End Location ?>>');
        %Check Limits
        if ~withinLimits(lib,axis(ii),el(ii))
            error('Outside of limits!')
        end
        np(ii) = input('Number of Points?>>');
        if mod(np,2)
            error('Verasonics can only handle an even number of frames => Number of points must be even')
        end
    end
else
    %% User already supplied input - error check it
    for ii = 1:2
        if axis(ii) < 0 || axis(ii) > 2 || mod(axis(ii),1)
            error(['Axis ', num2str(ii), ' must be 0, 1, or 2'])
        end
        if ~withinLimits(lib,axis(ii),sl(ii))
            error(['Start location ', num2str(ii), ' is outside of limits!'])
        end
        if ~withinLimits(lib,axis(ii),el(ii))
            error(['End location ', num2str(ii), ' is outside of limits!'])
        end
        if mod(np,2)
            error(['Verasonics can only handle an even number of frames => Number of points for axis ',...
                num2str(ii), ' must be even'])
        end
    end
end

%% Set up grid
locs1 = linspace(sl(1),el(1),np(1));
locs2 = linspace(sl(2),el(2),np(2));
[LOCS1,LOCS2] = ndgrid(locs1,locs2);

%% Move to start location
movePositionerAbs(lib,axis(1),locs1(1));
movePositionerAbs(lib,axis(2),locs2(1));