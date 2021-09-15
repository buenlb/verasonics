% Takes the recevie data made by VSX running imaging_singleElement.mat and
% produces a b-mode image based on the data
% 
% @INPUTS
%   RcvData: Raw data created by VSX
%   Receive: Receive struct used by VSX
%   distOfInterest: Optional. If length(distOfInterest) = 1 then all the
%       signal arriving before distOfInterest is set to zero. if
%       length(distOfInterest) = 2 then only signal between
%       distOfInterest(1) and distOfInterest(2) is displayed. Distances are
%       computed by assuming a speed of sound in water of 1492 m/s.
%       distOfInterest should be given in mm.
%   plotResult: If plotResult is true the resulting image is displayed.
% 
% @OUTPUTS
%   img: a 3D bMode image.
%   xa: x axis of 3D image
%   ya: y axis of 3D image
%   za: z axis of 3D image
% 
% Taylor Webb
% University of Utah
% March 2020

function [sArray,xa,ya,za] = griddedElementBModeImage_2D(RcvData,Receive,distOfInterest,txSn,plotResult)
if ~exist('plotResult','var')
    plotResult = 0;
end
if ~exist('txSn','var')
	warning('Serial number not passed to griddedElementBModeImage_2D, assuming JAB800');
	txSn = 'JAB800';
end

%% Set up grids
gridSize = 3;
blocks = selectElementBlocks(gridSize);

%% Set up time/distance vectors corresponding to data
t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);
d = t*1.492/2;

%% Set up the array coordinate system
dx = 0.5;
xa = -80/2:dx:80/2;
za = 10:dx:60;
[Za,Xa] = meshgrid(za,xa);

%% Set up the element coordinate system
elWidth = 2.5;
xe = -elWidth/2:dx:elWidth/2;
ze = d;
[Ze,Xe] = meshgrid(ze,xe);

%% Interpolate data from element coordinate system to array coordinates
elements = transducerGeometry(0,txSn);

sArray = zeros(size(Xa,1),8-(gridSize-1),size(Xa,2));
nElements = sArray;
gridPos = zeros(length(blocks),5);
for ii = 1:length(blocks)
    disp(['Block ', num2str(ii), ' of ', num2str(length(blocks))])
    centerElNo = blocks{ii}(ceil(gridSize/2));
    centerElement = elements.ElementPos(centerElNo,:);
    gridPos(ii,:) = centerElement;
    [Xar,~,Zar] = array2elementCoords(Xa,0,Za,centerElement);
    
    row = mod(centerElNo,8)-1;
    
    sTot = zeros(size(Receive(ii).startSample:Receive(ii).endSample))';
    for jj = 1:length(blocks{ii})
        s = double(RcvData(Receive(ii).startSample:Receive(ii).endSample,blocks{ii}(jj)));
        s = (abs(hilbert(s)));
        s(d<distOfInterest(1) | d>distOfInterest(2)) = 0;
        sTot = sTot+s;
    end
    s = sTot;

    sExpanded = zeros(size(Xe));
    for jj = 1:length(xe)
        sExpanded(jj,:) = s;
    end
    
    curS = interp2(Ze,Xe,sExpanded,Zar,Xar,'spline',0);
    sArray(:,row,:) = squeeze(sArray(:,row,:)) + curS;
    
    nElCur = zeros(size(curS));
    nElCur(curS~=0) = 1;
    
    nElements(:,row,:) = squeeze(nElements(:,row,:))+nElCur;

end
ya = unique(gridPos(:,2));
% Account for voxels that have signal from multiple elements
nElements(nElements==0) = 1;
sArray = sArray./nElements;

%% Display results
if plotResult
    h = figure;
    rows = 2;
    cols = ceil(length(ya)/2);
    
    for ii = 1:length(ya)
        subplot(rows,cols,ii)
        imshow(squeeze(sArray(:,ii,:)),[0,max(sArray(:))],'xdata',za,'ydata',xa);
        title(['y=',num2str(ya(ii))]);
        colorbar
        drawnow
    end
    set(h,'position',[1          41        1920        1083]);
    drawnow
end