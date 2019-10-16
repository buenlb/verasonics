function movePositionerVerasonics(RData)

Resource = evalin('base','Resource');

grid = load(Resource.Parameters.gridInfoFile);

lib = 'soniq';

pos = getPositionerSettings(lib);

idx = find(abs(pos.X.loc - grid.X) < 1e-6 & abs(pos.Y.loc - grid.Y) < 1e-6 & abs(pos.Z.loc - grid.Z) < 1e-6);

if idx == length(grid.X(:))
    return
end
disp(['Point ', num2str(idx+1), ' of ', num2str(length(grid.X(:)))])

movePositionerAbs(lib,pos.X.Axis,grid.X(idx+1));
movePositionerAbs(lib,pos.Y.Axis,grid.Y(idx+1));
movePositionerAbs(lib,pos.Z.Axis,grid.Z(idx+1));
return