function Grid = createGrid(X,Y,Z,d,pauseDur,parameters,recordToggle)
if ~exist('X','var')
    error('Must include size of grid in X-axis.');
elseif length(X) ~= 2
    error('size of grid in X-axis must be of length = 2.');
end

if ~exist('Y','var')
    error('Must include size of grid in Y-axis.');
elseif length(Y) ~= 2
    error('size of grid in Y-axis must be of length = 2.');
end

if ~exist('Z','var')
    error('Must include size of grid in Z-axis.');
elseif ~(length(Z) == 2 || length(Z) == 1)
    error('size of grid in Z-axis must be of length = 2 or = 1.');
end

if ~exist('d','var')
    error('Must include x, y, and z increment sizes.');
elseif length(d) ~= 3
    error('size of increment vector must be of length = 3.');
end

if ~exist('pauseDur','var') 
    pauseDur = 10;
elseif isempty(pauseDur)
    pauseDur = 10;
end

if ~exist('parameters','var') 
    parameters = 'Negative Peak Voltage';
elseif isempty(parameters)
    parameters = 'Negative Peak Voltage';
end

if ~exist('recordToggle','var')
    recordToggle = 0;
elseif isempty(recordToggle)
   recordToggle = 0;
end


Grid.xStart     = X(1); 
Grid.xEnd       = X(2);

Grid.yStart     = Y(1);
Grid.yEnd       = Y(2);

switch length(Z)
    case 1
        Grid.zLength = Z;
    case 2
        Grid.zStart = Z(1);
        Grid.zEnd   = Z(2);
    otherwise
        Grid.zLength = Z;
end

Grid.pause = pauseDur;

Grid.dx =  d(1);
Grid.dy =  d(1);
Grid.dz =  d(1);

Grid.parameters = parameters;

Grid.recordWaveforms = recordToggle; %                            [boolean]
