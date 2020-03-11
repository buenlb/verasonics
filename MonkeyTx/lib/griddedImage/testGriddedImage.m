%% Test griddedImage Processing
clear all; close all; clc;

%% User Defined Variables
frequency = 0.65; % Frequency in MHz
nCycles = 1/2; % number of cycles with which to excite Tx (can integer multiples of 1/2). If zero an impulse (1/8 of the period) will be used.
focalSpotsX = -2:1:2; % The x,y locations relative to the center of the grid that should be scanned by each grid.
focalSpotsY = -7:7:7;
focalSpotsZ = 20:5:40; % The z locations relative to the center of the grid that should be scanned by each grid.
gridSize = 3; % Array will be divided into grids that are gridSize elements X gridSize elements
saveDir = 'C:\Users\Verasonics\Desktop\Taylor\Data\Coupling\GridOfElements\20200310\test1\'; % Where raw data will be stored

%% Specify system parameters
Resource.Parameters.numTransmit = 256; % no. of xmit chnls (V64LE,V128 or V256).
Resource.Parameters.numRcvChannels = 256; % change to 64 for Vantage 64 or 64LE
Resource.Parameters.connector = 0; % trans. connector to use (V256).
Resource.Parameters.speedOfSound = 1490; % speed of sound in m/sec
Resource.Parameters.focalSpotsX = focalSpotsX;
Resource.Parameters.focalSpotsY = focalSpotsY;
Resource.Parameters.focalSpotsZ = focalSpotsZ;
Resource.Parameters.curGridIdx = 1;
Resource.Parameters.gridSize = gridSize;
Resource.Parameters.saveDir = saveDir;
Resource.Parameters.logFileName = 'log.mat';

blocks = selectElementBlocks(gridSize);

Trans = transducerGeometry(0);

xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);
allElements.x = xTx*1e-3;
allElements.y = yTx*1e-3;
allElements.z = zTx*1e-3;

%% Define array coordinate space
xa = -156/2:1:156/2;
ya = -56/2:1:56/2;
za = 0:1:60;
[Ya,Xa,Za] = meshgrid(ya,xa,za);
Resource.Parameters.Xa = Xa;
Resource.Parameters.Ya = Ya;
Resource.Parameters.Za = Za;
Resource.Parameters.img = zeros(size(Xa));
Resource.Parameters.imgAvg = zeros(size(Xa));

%% Generate a signal
ptSource = [0,0,40]*1e-3;

c = 1490;
dt = 1/13e6;
t = (0:dt:1664*dt)';
d = c*t/2;
elSignal = zeros(size(t));
nS = length(d);

T = 1/650e3;
elSignalLength = 3*T;
elSignal(t<elSignalLength) = sin(t(t<elSignalLength)*2*pi*650e3);

for ii = 1:length(xTx)
    dPtSource = norm(ptSource-[xTx(ii),yTx(ii),zTx(ii)]);
    tShift(ii) = 2*dPtSource*1e-3/c;
    elData(:,ii) = circshift(elSignal,[round(tShift(ii)/dt),0]);
end

totFocalSpots = length(focalSpotsX)*length(focalSpotsY)*length(focalSpotsZ);

%% Specify Receive structure array -
Receive(1).Apod = zeros(1,256);
Receive(1).startDepth = 0;
Receive(1).endDepth = 40;
Receive(1).TGC = 1; % Use the first TGC waveform defined above
Receive(1).mode = 0;
Receive(1).bufnum = 1;
Receive(1).framenum = 1;
Receive(1).acqNum = 1;
Receive(1).sampleMode = 'custom';
Receive(1).decimSampleRate = 20*Trans.frequency;
Receive(1).ADCRate = 20*Trans.frequency;
Receive(1).decimFactor = 1;
Receive(1).LowPassCoef = [];
Receive(1).InputFilter = [];

for ii = 1:totFocalSpots
    Receive(ii) = Receive(1);
    Receive(ii).Apod(blocks{1}) = 1;
    Receive(ii).acqNum = ii;
    Receive(ii).startSample = (ii-1)*nS+1;
    Receive(ii).endSample = ii*nS;
end

%% Simulate
RData = zeros(totFocalSpots*length(elSignal),256);
for hh = 1:length(blocks)
    curBlock = blocks{hh};
    idx = 1;
    disp(['Block ', num2str(hh) ' of ', num2str(length(blocks))])
    for ii = 1:length(focalSpotsX)
        for jj = 1:length(focalSpotsY)
            for kk = 1:length(focalSpotsZ)
                centerElementPos = Trans.ElementPos(blocks{1}(ceil(gridSize^2/2)),:);
                [xa,ya,za] = element2arrayCoords(focalSpotsX(ii),...
                    focalSpotsY(jj),focalSpotsZ(kk), centerElementPos);
                
                elements.x = xTx(curBlock)*1e-3;
                elements.y = yTx(curBlock)*1e-3;
                elements.z = zTx(curBlock)*1e-3;
                elements = steerArray(elements,...
                    [xa,ya,za]*1e-3,...
                    frequency,0);
                delays = [elements.t]';
                curS = zeros(size(elSignal));
                for ll = 1:length(curBlock)
                    rcElLocation = [xTx(curBlock(ll)),yTx(curBlock(ll)),zTx(curBlock(ll))];
                    for mm = 1:length(curBlock)
                        txElLocation = [xTx(curBlock(mm)),yTx(curBlock(mm)),zTx(curBlock(mm))];
                        % The multiplication by 1e-6 puts the delays in
                        % seconds instead of microseconds
                        tShift = delays(mm)*1e-6+(norm(txElLocation-ptSource)+norm(rcElLocation-ptSource))/(c*1e3);
                        curSel = circshift(elSignal,[round(tShift/dt),0]);
                        curS = curS+curSel;
                    end
                    RData(((idx-1)*nS+1):idx*nS,curBlock(ll)) = curS;
                end
                idx = idx+1;
            end
        end
    end
    img = processImage_griddedImage(RData);
    figure
    for ii = 1:size(img,2)
        subplot(1,size(img,2),ii);
        imagesc(squeeze(img(:,ii,:)))
    end
    keyboard
    Resource.Parameters.curGridIdx = Resource.Parameters.curGridIdx+1;
end