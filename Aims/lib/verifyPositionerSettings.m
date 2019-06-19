function Pos = verifyPositionerSettings(lib,Tx)
Pos = getPositionerSettings(lib);

%% Error Checking
if abs(Pos.X.loc) > 0 || abs(Pos.Y.loc) > 0
    error('You must attempt to center in x-y plane and then set x and y positions to 0!')
end

if ~strcmp(Tx.cone,'none')
    if Tx.coneEdge == 0
        error('You have specified a cone without specifing the location of the cone edge!')
    end
end

%% Set position information in a more intuitive way
switch Pos.Z.Axis
    case 0
        leftRight = Pos.Z;
    case 1
        frontBack = Pos.Z;
    case 2
        upDown = Pos.Z;
end

switch Pos.X.Axis
    case 0
        leftRight = Pos.X;
    case 1
        frontBack = Pos.X;
    case 2
        upDown = Pos.X;
end

switch Pos.Y.Axis
    case 0
        leftRight = Pos.Y;
    case 1
        frontBack = Pos.Y;
    case 2
        upDown = Pos.Y;
end

save tmpPositionFile Pos upDown leftRight frontBack Tx

[wv,t,~,delay] = getSoniqWaveform(lib,'tmp.snq');
[~,estPosition] = arrivalTime(t+(delay)*1e6,wv);

positionTolerance = 5;

if abs(estPosition - Pos.Z.loc) > positionTolerance
    uiwait(msgbox(['WARNING: Computed distance to transducer, ', num2str(estPosition,3),...
        ' is more than ', num2str(positionTolerance),...
        ' mm different than positioner location, ', num2str(Pos.Z.loc,3),'!']));
end

VERIFIED = 0;
myTm = now;
if ~strcmp(Tx.cone,'none')
    uiwait(msgbox(['WARNING! The system has no way of knowing the precise location of the transducer and especially the edge of the cone.',...
        ' This safety check is only as good as your alignment of the transducer and hydrophone.',...
        char(10), char(10), 'You are responsible to ensure that the positioner limits are sufficient to avoid a collission!']));
    h = verifyPositionerSettingsConeGUI;
    set(h.UIFigure,'position',[639   419   650   550]);
else
    uiwait(msgbox(['WARNING! The system has no way of knowing the precise location of the transducer.',...
        'This safety check is only as good as your alignment of the transducer and hydrophone.',...
        char(10), char(10), 'You are responsible to ensure that the positioner limits are sufficient to avoid a collission!']));
    h = verifyPositionerSettingsGUI;
    set(h.UIFigure,'position',[639   419   650   500]);
end
uiwait(h.UIFigure);

close all;

%% Check that the time stamp on the file makes sense to avoid accidental issues
% If the tm variable isn't part of the file than this the GUI didn't reset
% it - the user probably hit 'x' instead of cancel.
load tmpPositionFile.mat
try
    if myTm >= tm
        error('Something is wrong with the GUI - the timestamps are wrong!')
    end
catch
    closeSoniq(lib);
    error('Terminated by user - inadequate positioner settings')
end

%% Did they click continue or cancel?
if ~VERIFIED
    closeSoniq(lib);
    error('Terminated by user - inadequate positioner settings')
end

delete tmpPositionFile.mat
