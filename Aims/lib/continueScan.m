% continueScan uses parameters in Resource.Parameters.Axis and
% Resource.Parameters.locs to compute a step size and move the positioner
% 
% The program finds MATLAB's alias for the soniq library in
% Resource.Parameters.soniqLib
% 
% Taylor Webb
% University of Utah

function continueScan(RData)


Resource = evalin('base','Resource');
Receive = evalin('base','Receive');

% Make sure relevant fields are present
if ~isfield(Resource.Parameters,'soniqLib')
    error('You must provide a MATLAB alias to the Soniq library in Resource.Parameters.soniqLib')
end
if ~isfield(Resource.Parameters,'Axis')
    error('You must provide the scan axis in Resource.Parameters.Axis')
end
if ~isfield(Resource.Parameters,'locs')
    error('You must provide grid locations in Resource.Parameters.locs')
end

% Move the positioner
step = Resource.Parameters.locs(2)-Resource.Parameters.locs(1);
movePositioner(Resource.Parameters.soniqLib,...
    Resource.Parameters.Axis,step)

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
axis([50,100,min(mean(accumEnv,2)),max(mean(accum,2))])
drawnow
pause(0.1)
return