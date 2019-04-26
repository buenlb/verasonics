% Initializes information about 2D grids that will be used to characterize
% the transducer
% 
% @INPUTS
%   lib: MATLAB alias for soniq DLL. Used to make sure requested grid is
%       within software limits
%   Grid: struct with following fields
%       xStart: beginning point along x-axis
%       xEnd: end point along x-axis
%       yStart: beginning point along y-axis
%       yEnd: end point along y-axis
%       zLength: length along which to scan z-axis
%       zStart: beginning point along z-axis. Optional. Default is focal
%          distance minus 10 wavelengths
%       zEnd: end point along z-axis. Optional. Default is focal distance
%          plus 10 wavelengths
%       xPoints: number of points along x-axis. Optional. Default sets the
%          number of points to give a spacing of lamba/4
%       yPoints: number of points along y-axis. Optional. Default sets the
%          number of points to give a spacing of lamba/4
%       zPoints: number of points along z-axis. Optional. Default sets the
%          number of points to give a spacing of lamba/4
%       averages: number of signal averages to acquire. Optional. Default
%          is 1
%       pause: time to pause after motion during final characterization
%          grids
%       dx: spacing disance along x-axis
%       dy: spacing distance along y-axis
%       dz: spacing distance along z-axis
%       recordWaveforms(1/0):  Specifies whether or not to record the full
%          waveform at each grid location. Defaults to 0.
%       parameter: parameter to measure on the grid. Examples:
%          Negative Peak Voltage
%          Positive Peak Voltage
%          VRMS
%          Peak to Peak Voltage
%          Pulse Intensity Integral
%          Temporal Average
%   Tx: Transducer struct. See characterizeTx for Details
% 
% @OUTPUS
%   Grid: Struct as described in inputs with any missing fields set to the
%     default value
% 
% Taylor Webb
% University of Utah

function Grid = initializeGrid(lib,Grid,Tx)

Pos = getPositionerSettings(lib);

lambda = 1490000/(Tx.frequency*1e6);

if Tx.focalLength <= 0
    focus = Tx.diameter^2/(2*lambda);
else
    focus = Tx.focalLength;
end

if ~isfield(Grid,'zStart')
    if ~isfield(Grid,'zLength')
        Grid.zStart = focus-10*lambda;
        Grid.zEnd = focus+10*lambda;
        Grid.zLength = 20*lambda;
    else
        Grid.zStart = focus-Grid.zLength/2;
        Grid.zEnd = focus+Grid.zLength/2;
    end
end

if ~withinLimits(lib,Pos.Z.Axis,Grid.zStart)
    Grid.zStart = calllib(lib,'GetPositionerLowLimit',Pos.Z.Axis)+0.1;
    warning(['Re-assigning Z start point to edge of Soniq software limit: ',num2str(Grid.zStart)]);
end
if ~withinLimits(lib,Pos.Z.Axis,Grid.zEnd)
    Grid.zEnd = calllib(lib,'GetPositionerHighLimit',Pos.Z.Axis);
    warning(['Re-assigning Z end point to edge of Soniq software limit: ',num2str(Grid.zEnd)]);
end

%% If User didn't specify a number dx, dy, or dz set it such that there will be four samples/lambda
if ~isfield(Grid,'dx')
    Grid.dx = lambda/4;
end
if ~isfield(Grid,'dy')
    Grid.dy = lambda/4;
end
if ~isfield(Grid,'dz')
    Grid.dz = lambda/4;
end

Grid.xPoints = ceil((abs(Grid.xStart-Grid.xEnd))/Grid.dx)+1;
Grid.yPoints = ceil((abs(Grid.yStart-Grid.yEnd))/Grid.dy)+1;
Grid.zPoints = ceil((abs(Grid.zStart-Grid.zEnd))/Grid.dz)+1;

%% If user didn't specify averages add it here
if ~isfield(Grid,'averages')
    Grid.averages = 1;
end

%% If user didn't specify pause time add it here
if ~isfield(Grid,'pause')
    Grid.pause = 100;
end

%% If user didn't specify measured parameter add it here
if ~isfield(Grid,'parameters')
    Grid.parameters = 'Negative Peak Voltage';
end

%% If user didn't specify whether or not to record waveforms
if ~isfield(Grid,'recordWaveforms')
    Grid.recordWaveforms = 0;
end