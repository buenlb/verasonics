% show2dScan takes the information from RData (populated by VSX) and shows
% a 2d image that represents the scan done using the AIMS water tank. In
% order to make the x-axis it reads the grid step size from aimsGrid.taylor
% in the working directory (see continueScan.m).
% 
% Taylor Webb
% University of Utah

function show1dScanCircular(RData)

fid = fopen('aimsGrid.Taylor');
a = fscanf(fid,'%d,%f');
fclose(fid);
stepSize = a(2);

Receive = evalin('base','Receive');
Resource = evalin('base','Resource');

nPoints = Resource.RcvBuffer.numFrames;
NA = length(Receive)/nPoints;
beam = zeros(length(double(RData(Receive(1).startSample:Receive(1).endSample))),nPoints);
for ii = 1:nPoints
    accum = zeros(size(double(RData(Receive(1).startSample:Receive(1).endSample,1,1))));
    for jj = 1:NA
        idx = (ii-1)*NA+jj;
        accum = double(RData(Receive(idx).startSample:Receive(idx).endSample,1,ii))+accum;
    end
    beam(:,ii) = abs(hilbert(accum/NA));
end

% Depth in mm assuming speed of sound in water
depth = 1000*(0:(Receive(1).endSample-1))/...
    (Receive(1).ADCRate*1e6/Receive(1).decimFactor)*...
    Resource.Parameters.speedOfSound/2;

% Show the image
h = figure;
lines2skip = 10;
imagesc(Resource.Parameters.theta*180/pi,depth(lines2skip:end),log10(beam(lines2skip:end,:)))
axis('equal')
axis([Resource.Parameters.theta(1),Resource.Parameters.theta(end),depth(lines2skip),depth(end)])
colormap('gray')
colorbar
xlabel('Angle (deg)')
ylabel('Depth (mm)')
makeFigureBig(h);
set(h,'position',[2    42   958   954]);
drawnow

if ~isfield(Resource.Parameters,'soniqLib')
    error('You must provide a MATLAB alias to the Soniq library in Resource.Parameters.soniqLib')
end

%% Move back to start so that if freeze is pushed the system repeats the
% same scan instead of starting from the endpoint
theta = Resource.Parameters.theta;
radius = Resource.Parameters.radius;
lib = Resource.Parameters.soniqLib;
% Find where we currently are
Pos = getPositionerSettings(lib);
linAxis = Resource.Parameters.Axis;
rotAxis = Resource.Parameters.rotAxis;

% As a safety precaution, first go to raius on Z and 0 on the angle. This
% way if the circle went all the way to a z where a collision might occur
% we avoid that collision
movePositionerAbs(Resource.Parameters.soniqLib,Pos.Z.Axis,radius);
movePositionerAbs(Resource.Parameters.soniqLib,rotAxis,0);

movePositionerAbs(Resource.Parameters.soniqLib,Pos.Z.Axis,radius*cos(theta(1)));
movePositionerAbs(Resource.Parameters.soniqLib,rotAxis,180/pi*theta(1));
movePositionerAbs(Resource.Parameters.soniqLib,linAxis,radius*sin(theta(1)));

% closeSoniq(Resource.Parameters.soniqLib);
return