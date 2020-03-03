function setExcitationNoScope_exVivoScan(RData)
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

    idx = find(abs(pos.THETA.loc - angles) < 1e-6);

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

    movePositionerAbs(lib,pos.THETA.Axis,angles(idx+1));
    
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
