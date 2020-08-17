function initializeSkullRotation2(RData)
alpha = 10;

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
    switch alpha
        case 10
            movePositionerAbs(lib,pos.X.Axis, -15.7); %alpha = 10 deg
        case 5
            movePositionerAbs(lib,pos.X.Axis, -7.5); %alpha = 5 deg
        otherwise
            movePositionerAbs(lib,pos.X.Axis, 0);
    end
    movePositionerAbs(lib,pos.Y.Axis, 0);

    Resource.Parameters.firstAngle = 0;
    assignin('base','Resource',Resource);
else
    return
end