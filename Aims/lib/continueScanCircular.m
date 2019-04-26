% continueScan uses parameters in Resource.Parameters.Axis and
% Resource.Parameters.locs to compute a step size and move the positioner
% 
% The program finds MATLAB's alias for the soniq library in
% Resource.Parameters.soniqLib
% 
% Taylor Webb
% University of Utah

function continueScanCircular(RData)


Resource = evalin('base','Resource');
Receive = evalin('base','Receive');

% Make sure relevant fields are present
if ~isfield(Resource.Parameters,'soniqLib')
    error('You must provide a MATLAB alias to the Soniq library in Resource.Parameters.soniqLib')
end
if ~isfield(Resource.Parameters,'Axis')
    error('You must provide the scan axis in Resource.Parameters.Axis')
end
if ~isfield(Resource.Parameters,'rotAxis')
    error('You must provide the rotational scan axis in Resource.Parameters.rotAxis')
end
if ~isfield(Resource.Parameters,'theta')
    error('You must provide grid angles in Resource.Parameters.theta')
end
if ~isfield(Resource.Parameters,'radius')
    error('You must provide a radius in Resource.Parameters.radius')
end

theta = Resource.Parameters.theta;
radius = Resource.Parameters.radius;
lib = Resource.Parameters.soniqLib;
% Find where we currently are
Pos = getPositionerSettings(lib);
linAxis = Resource.Parameters.Axis;
rotAxis = Resource.Parameters.rotAxis;

[~,idx] = min(abs(Pos.THETA.loc-theta*180/pi));
if idx < length(theta)
    % Move the positioner
    movePositionerAbs(lib,linAxis,radius*sin(theta(idx+1)));
    movePositionerAbs(lib,Pos.Z.Axis,radius*cos(theta(idx+1)));
    movePositionerAbs(lib,rotAxis,180/pi*theta(idx+1))
end
    
c = Resource.Parameters.speedOfSound;
NA = Resource.Parameters.numAvg;

depth = 1000*(0:(Receive(1).endSample-1))/...
    (Receive(1).ADCRate*1e6/Receive(1).decimFactor)*...
    c/2;

h = figure(99);
for ii = 1:NA
    accum(:,ii) = double(RData(Receive(ii).startSample:Receive(ii).endSample,1));
    accumEnv(:,ii) = abs(hilbert(accum(:,ii)));
end
plot(depth,mean(accum,2),depth,mean(accumEnv,2),'--')
xlabel('depth (mm)')
ylabel('signal magnitude (A.U.)')
makeFigureBig(h);
axis([0,200,min(mean(accumEnv,2)),max(mean(accum,2))])
drawnow
pause(0.1)
return