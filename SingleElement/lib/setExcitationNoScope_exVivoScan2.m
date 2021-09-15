function setExcitationNoScope_exVivoScan2(RData)

alpha = 10; %rotation increment; use 5 or 10; do also use negative angles to change direction

disp('setExcitationNoScope')
Resource = evalin('base','Resource');
TW = evalin('base','TW');
Trans = evalin('base','Trans');
TPC = evalin('base','TPC');

curIdx = Resource.Parameters.curExcitation+1;
disp(['Current Transmit Idx: ', num2str(curIdx)])
if curIdx > length(Resource.Parameters.excitations)
    lib = 'soniq';
    pos = getPositionerSettings(lib);

    angles = Resource.Parameters.angles;

    idx = find(abs(-pos.THETA.loc/alpha - angles) < 1e-6);

    if idx>1
        t = toc;
        disp(['Elapsed time on angle ', num2str(idx), ' is ' num2str(round(t)), ' seconds'])
    end
    tic
    
    if idx == length(angles)
        disp('Attempting to close VSX')
        VSXquit;
        VsClose;
        return
    end
    disp(['Point ', num2str(idx+1), ' of ', num2str(length(angles))])

%    movePositionerAbs(lib,pos.THETA.Axis,angles(idx+1));

i = angles(idx+1); %the next iteration

skulldims = [140 200];
projn = mean(skulldims)/2 * sin(deg2rad(alpha)) / sin(deg2rad(90 - 2 * alpha));
xsh = 0;
ysh = 0;
%correction for accumulated error at 0, 90, 270, 360 degrees
zit = 1;
if mod(alpha * i, 90) == 0
    zit = i;
end
for z = zit : i
    if mod(z, 2) == 0
        projns = -projn;
    else
        projns = projn;
    end
    xsh = xsh + projns * cos(deg2rad(alpha * z));
    ysh = ysh + projns * sin(deg2rad(alpha * z));
end
fprintf('angle %d: x = %.1f, y = %.1f, procn = %.1f\n', alpha * i, xsh, ysh, projn);
movePositionerAbs(lib,pos.THETA.Axis, -alpha * i);
movePositionerAbs(lib,pos.X.Axis, xsh);
movePositionerAbs(lib,pos.Y.Axis, -ysh);
    
    Resource.Parameters.curExcitation = 1;
    curIdx = 1;
end
nCycles = Resource.Parameters.excitations(curIdx);

if nCycles == 0
    TW(1).type = 'pulseCode';
    TW(1).PulseCode = generateImpulse(1/(8*Trans.frequency*1e6));
else
    TW(1).type = 'parametric';
    TW(1).Parameters = [Trans.frequency,0.67,nCycles,1]; % A, B, C, D
    disp(['Setting Excitation with ', num2str(nCycles/2), ' cycles.'])
end
if nCycles >= 3 %chirps
    TW(1).type = 'pulseCode';
    TW(1).PulseCode = generateChirp(Trans.frequency*1e6, nCycles);    
    disp(['Excitation with a chirp of ', num2str(nCycles), ' segments.']);    
end

TPC(1).hv = Resource.Parameters.excitationVoltages(curIdx);
disp(['Setting HV to ', num2str(Resource.Parameters.excitationVoltages(curIdx))]);
Resource.Parameters.curExcitation = curIdx;
%% Update them in base
assignin('base','TW', TW);
assignin('base','Resource',Resource);
assignin('base','TPC',TPC);
% Set Control command to update TX
Control = evalin('base','Control');
Control.Command = 'update&Run';
Control.Parameters = {'TW','TX','TPC'};
assignin('base','Control', Control);