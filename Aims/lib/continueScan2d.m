% continueScan uses parameters in Resource.Parameters.Axis and
% Resource.Parameters.locs1 and Resource.Parameters.locs2 to determine how
% to move.
% 
% The program finds MATLAB's alias for the soniq library in
% Resource.Parameters.soniqLib
% 
% Taylor Webb
% University of Utah

function continueScan2d(RData)


Resource = evalin('base','Resource');

% Make sure relevant fields are present
if ~isfield(Resource.Parameters,'soniqLib')
    error('You must provide a MATLAB alias to the Soniq library in Resource.Parameters.soniqLib')
end
if ~isfield(Resource.Parameters,'Axis')
    error('You must provide the scan axis in Resource.Parameters.Axis')
end
if ~isfield(Resource.Parameters,'LOCS1')
    error('You must provide grid locations in Resource.Parameters.locs')
end
if ~isfield(Resource.Parameters,'LOCS2')
    error('You must provide grid locations in Resource.Parameters.locs')
end
if ~isfield(Resource.Parameters,'fileLocation')
    error('You must provide desired file location in Resource.Parameters.fileLocation')
end

locs1 = Resource.Parameters.LOCS1;
locs2 = Resource.Parameters.LOCS2;

curPos1 = getPosition(Resource.Parameters.soniqLib, Resource.Parameters.Axis(1));
curPos2 = getPosition(Resource.Parameters.soniqLib, Resource.Parameters.Axis(2));

% Figure out where we are in the grid. Note that because step sizes can be
% non-integers there is sometimes an issue with finding an exact match.
% This code determines equals to be being less than a tenth of the step
% size away.
dl1 = max(diff(locs1(:)));
dl2 = max(diff(locs2(:)));

curIdx = find(abs(locs1(:)-curPos1) < dl1/10 & abs(locs2(:)-curPos2) < dl2/10);

% Move to the next position
axis = Resource.Parameters.Axis;
soniqLib = Resource.Parameters.soniqLib;
movePositionerAbs(soniqLib, axis(1), locs1(curIdx+1));
movePositionerAbs(soniqLib, axis(2), locs2(curIdx+1));

% pause(Resource.Parameters.positionerDelay/1e3);

[wv,t] = getSoniqWaveform(soniqLib,[Resource.Parameters.fileLocation,'wv_',...
    num2str(axis(1)),'_',num2str(locs1(curIdx+1)),'_',num2str(axis(2)),'_',num2str(locs2(curIdx+1)),'.snq']);
figure(100)
plot(t*1e3,wv*1e3,'linewidth',2);
ylabel('voltage (mV)')
xlabel('time (ms)');
return