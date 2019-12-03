function rotateSkull(RData)

Resource = evalin('base','Resource');

lib = 'soniq';
pos = getPositionerSettings(lib);

angles = Resource.Parameters.angles;

idx = find(abs(pos.THETA.loc - angles) < 1e-6);

if idx == length(angles)
    disp('Attempting to close VSX')
    VSXquit;
    VsClose;
    return
end
disp(['Point ', num2str(idx+1), ' of ', num2str(length(angles))])

movePositionerAbs(lib,pos.THETA.Axis,angles(idx+1));
return