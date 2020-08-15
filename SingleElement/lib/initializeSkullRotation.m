function initializeSkullRotation(RData)
alpha = 5;

Resource = evalin('base','Resource');
if Resource.Parameters.firstAngle
    disp('here')
    if ~exist('isSoniqConnected.m','file')
        addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\Aims\lib\soniq');
        addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\Aims\lib')
    end
    Resource = evalin('base','Resource');

    lib = loadSoniqLibrary();
    if ~isSoniqConnected(lib)
        openSoniq(lib);
    end
    pos = getPositionerSettings(lib);

    angles = Resource.Parameters.angles;
    movePositionerAbs(lib,pos.THETA.Axis, -angles(1) * alpha);

    Resource.Parameters.firstAngle = 0;
    assignin('base','Resource',Resource);
else
    return
end