% getPositionerSettings returns the orientation and lower and upper limits
% of each axis in the struct Pos
% 
% @INPUTS
%   lib: MATLAB alias of Soniq DLL
% 
% @OUTPUTS
%   Pos: Struct with positioner settings
%       Fields:
%           X.Axis: number of x-axis
%           X.lowLimit: lower software limit for x-axis on the positioner
%           X.highLimit: upper software limit for x-axis on the positioner
%           X.loc: current location
%           Other identical fields for Y and Z axis
% 
% Taylor Webb
% University of Utah

function Pos = getPositionerSettings(lib)

Pos.X.Axis = calllib(lib,'GetOrientationXAxis');
Pos.Y.Axis = calllib(lib,'GetOrientationYAxis');
Pos.Z.Axis = calllib(lib,'GetOrientationZAxis');
Pos.PHI.Axis = 3;
Pos.THETA.Axis = 4;

Pos.X.lowLimit = calllib(lib,'GetPositionerLowLimit',Pos.X.Axis);
Pos.X.highLimit = calllib(lib,'GetPositionerHighLimit',Pos.X.Axis);
Pos.X.loc = calllib(lib,'GetPosition',Pos.X.Axis);

Pos.Y.lowLimit = calllib(lib,'GetPositionerLowLimit',Pos.Y.Axis);
Pos.Y.highLimit = calllib(lib,'GetPositionerHighLimit',Pos.Y.Axis);
Pos.Y.loc = calllib(lib,'GetPosition',Pos.Y.Axis);

Pos.Z.lowLimit = calllib(lib,'GetPositionerLowLimit',Pos.Z.Axis);
Pos.Z.highLimit = calllib(lib,'GetPositionerHighLimit',Pos.Z.Axis);
Pos.Z.loc = calllib(lib,'GetPosition',Pos.Z.Axis);

Pos.PHI.lowLimit = calllib(lib,'GetPositionerLowLimit',3);
Pos.PHI.highLimit = calllib(lib,'GetPositionerHighLimit',3);
Pos.PHI.loc = calllib(lib,'GetPosition',3);

Pos.THETA.lowLimit = calllib(lib,'GetPositionerLowLimit',4);
Pos.THETA.highLimit = calllib(lib,'GetPositionerHighLimit',4);
Pos.THETA.loc = calllib(lib,'GetPosition',4);

Pos.AxisLabels = {'Left/Right','Front/Back','Up/Down','Angular Arm','Angular Turn Table'};