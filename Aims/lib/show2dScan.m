% show2dScan takes the information from RData (populated by VSX) and shows
% a 2d image that represents the scan done using the AIMS water tank. In
% order to make the x-axis it reads the grid step size from aimsGrid.taylor
% in the working directory (see continueScan.m).
% 
% Taylor Webb
% University of Utah

function show2dScan(RData)

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
imagesc(Resource.Parameters.locs,depth(lines2skip:end),log10(beam(lines2skip:end,:)))
axis('equal')
axis([Resource.Parameters.locs(1),Resource.Parameters.locs(end),depth(lines2skip),depth(end)])
colormap('gray')
colorbar
xlabel('Tx Location (mm)')
ylabel('Depth (mm)')
makeFigureBig(h);
set(h,'position',[2    42   958   954]);
drawnow

if ~isfield(Resource.Parameters,'soniqLib')
    error('You must provide a MATLAB alias to the Soniq library in Resource.Parameters.soniqLib')
end

% Move back to start so that if freeze is pushed the system repeats the
% same scan instead of starting from the endpoint
movePositionerAbs(Resource.Parameters.soniqLib,Resource.Parameters.Axis,...
    Resource.Parameters.locs(1));

% closeSoniq(Resource.Parameters.soniqLib);
return