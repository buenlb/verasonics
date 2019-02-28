% Notice:
%   This file is provided by Verasonics to end users as a programming
%   example for the Verasonics Vantage Research Ultrasound System.
%   Verasonics makes no claims as to the functionality or intended
%   application of this program and the user assumes all responsibility
%   for its use
%
% File name: SetUpL11_4vAcquireRF.m - Example of RF data acquisition
%
% Description:
%   Sequence programming file for L11-4v Linear array, acquiring RF data of
%   a single plane wave transmit and receive acquisition. All 128 transmit
%   and receive channels are active for each acquisition. External
%   processing is used asynchronous with respect to acquisition.
%
% Last update:
% 11/10/2015 - modified for SW 3.0

clear all

%% Set up path locations
srcDirectory = setPaths();

%% Specify system parameters
Resource.Parameters.numTransmit = 1;      % no. of transmit channels (2 brds).
Resource.Parameters.numRcvChannels = 1;    % no. of receive channels (2 brds).
Resource.Parameters.speedOfSound = 1540;    % speed of sound in m/sec
Resource.Parameters.verbose = 2;
Resource.Parameters.initializeOnly = 0;
Resource.Parameters.simulateMode = 0;       % runs script in simulate mode
%  Resource.Parameters.simulateMode = 1 forces simulate mode, even if hardware is present.
%  Resource.Parameters.simulateMode = 2 stops sequence and processes RcvData continuously.

% Specify media points
Media.MP(1,:) = [0,0,100,1.0]; % [x, y, z, reflectivity]
Media.function = 'movePoints';

% Specify Trans structure array.
% Specify Trans structure array.
Trans.name = 'Custom';
Trans.frequency = 2.25; % not needed if using default center frequency
Trans.units = 'mm';
Trans.lensCorrection = 1;
Trans.Bandwidth = [1.5,3];
Trans.type = 0;
Trans.numelements = 1;
Trans.elementWidth = 24;
Trans.ElementPos = ones(1,5);
Trans.ElementSens = ones(101,1);
Trans.connType = 1;
Trans.Connector = 1;

% Specify Resource buffers.
Resource.RcvBuffer(1).datatype = 'int16';
Resource.RcvBuffer(1).rowsPerFrame = 6400;  % this allows for 1/4 maximum range
Resource.RcvBuffer(1).colsPerFrame = Resource.Parameters.numRcvChannels;
Resource.RcvBuffer(1).numFrames = 10;       % allocate 10 frames.

% Specify Transmit waveform structure.
TW(1).type = 'parametric';
TW(1).Parameters = [Trans.frequency,.67,2,1];

% Specify TX structure array.
TX(1).waveform = 1;            % use 1st TW structure.
TX(1).focus = 0;
TX(1).Apod = ones(1,Trans.numelements);
TX(1).Delay = computeTXDelays(TX(1));

% Specify TGC Waveform structure.
TGC(1).CntrlPts = [500,590,650,710,770,830,890,950];
TGC(1).rangeMax = 200;
TGC(1).Waveform = computeTGCWaveform(TGC);

% Specify Receive structure array -
Receive = repmat(struct(...
                'Apod', ones(1,Trans.numelements), ...
                'startDepth', 0, ...
                'endDepth', 200, ...
                'TGC', 1, ...
                'mode', 0, ...
                'bufnum', 1, ...
                'framenum', 1, ...
                'acqNum', 1, ...
                'sampleMode', 'NS200BW'), ...
                1,Resource.RcvBuffer(1).numFrames);

% - Set event specific Receive attributes.
for i = 1:Resource.RcvBuffer(1).numFrames
    % -- full aperture acquisition.
    Receive(i).framenum = i;
    Receive(i).callMediaFunc=1;
end

% Specify an external processing event.
Process(1).classname = 'External';
Process(1).method = 'myProcFunction';
Process(1).Parameters = {'srcbuffer','receive',... % name of buffer to process.
                         'srcbufnum',1,...
                         'srcframenum',-1,... % process the most recent frame.
                         'dstbuffer','none'};

% Specify sequence events.
SeqControl(1).command = 'timeToNextAcq';
SeqControl(1).argument = 9800;
SeqControl(2).command = 'jump';
SeqControl(2).argument = 1;
nsc = 3; % start index for new SeqControl

n = 1;   % start index for Events
for i = 1:Resource.RcvBuffer(1).numFrames

	Event(n).info = 'Aquisition.';
	Event(n).tx = 1;
	Event(n).rcv = i;
	Event(n).recon = 0;
	Event(n).process = 0;
	Event(n).seqControl = [1,nsc];
	   SeqControl(nsc).command = 'transferToHost';
	   nsc = nsc + 1;
      n = n+1;

	Event(n).info = 'Call external Processing function.';
	Event(n).tx = 0;
	Event(n).rcv = 0;
	Event(n).recon = 0;
	Event(n).process = 1;
	Event(n).seqControl = 0;
	n = n+1;
end
Event(n).info = 'Jump back to Event 1.';
Event(n).tx = 0;
Event(n).rcv = 0;
Event(n).recon = 0;
Event(n).process = 0;
Event(n).seqControl = 2;

% - Create UI controls for channel selection
nr = Resource.Parameters.numRcvChannels;
UI(1).Control = {'UserB1','Style','VsSlider',...
                 'Label','Plot Channel',...
                 'SliderMinMaxVal',[1,128,64],...
                 'SliderStep', [1/nr,8/nr],...
                 'ValueFormat', '%3.0f'};
UI(1).Callback = {'assignin(''base'',''myPlotChnl'',round(UIValue));'};
EF(1).Function = text2cell('SetUpL11_4vAcquireRF.m','%EF#1');

% Save all the structures to a .mat file.
scriptName = mfilename('fullpath');
svName = matFileName(scriptName);
save(svName);

return

%EF#1
myProcFunction(RData)
persistent myHandle
Receive = evalin('base','Receive');
% If myPlotChnl exists, read it for the channel to plot.
if evalin('base','exist(''myPlotChnl'',''var'')')
    channel = evalin('base','myPlotChnl');
else
    channel = 1;  % Channel no. to plot
end
% Create the figure if it does not exist.
if isempty(myHandle)||~ishandle(myHandle)
    figure('name','Receive Signal','NumberTitle','off');
    myHandle = axes('XLim',[0,Receive(1).endSample],'YLim',[-2048 2048], ...
                    'NextPlot','replacechildren');
end
% Plot the element's RF data.
V = version;
MatlabV = V(end-5:end-1);
plot(myHandle,RData(1:Receive(1).endSample,channel));
if strcmp(MatlabV,'2014a') || str2double(MatlabV(1:end-1))<2014
    drawnow
else
    drawnow limitrate
end
return
%EF#1
