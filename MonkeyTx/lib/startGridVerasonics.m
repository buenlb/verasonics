function startGridVerasonics(RData)

if ~exist('isSoniqConnected.m','file')
    addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\Aims\lib\soniq');
end

if ~exist('readWaveform.m','file')
    addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\Aims\lib')
end

Resource = evalin('base','Resource');

% Resource = evalin('base','Resource');
lib = loadSoniqLibrary();
if ~isSoniqConnected(lib)
    openSoniq(lib);
end

grid = load(Resource.Parameters.gridInfoFile);

pos = getPositionerSettings(lib);

movePositionerAbs(lib,pos.X.Axis,grid.X(1));
movePositionerAbs(lib,pos.Y.Axis,grid.Y(1));
movePositionerAbs(lib,pos.Z.Axis,grid.Z(1));