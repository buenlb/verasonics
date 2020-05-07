% traceSkullSurfaces finds the front edge of the signal from each element
% in order to estimate the location of the skull surface
% 
% @INPUTS
%   RcvData: Received data from verasonics
%   Receive: Receive struct from verasonics
%   gs: Struct containing relevant data from a "gold standard" file
%      (created by createGoldStandardFile.m). Must have the range of
%      distances in which the skull could be found and a template for a
%      matched filter search of the signal.
%   plotResult: If plotResult is true the resulting image is displayed.
% 
% @OUTPUTS
%   img: A stack of 8 images, one for each row of transducers, showing the
%     estimated surface of the skull
% 
% Taylor Webb
% University of Utah
% March 2020

function [sArray,skullLoc,xa,ya,za] = skullSurfaceGrid(RcvData,Receive,gs,plotResult)
if nargin < 4
    plotResult = 1;
end
%% Set up grids
gridSize = 3;
blocks = selectElementBlocks(gridSize);

%% Set up time/distance vectors corresponding to data
t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);
dt = t(2)-t(1);
d = t*1.492/2;

%% Set up the array coordinate system
dx = 0.5;
xa = -80/2:dx:80/2;
za = 10:dx:60;
[Za,Xa] = meshgrid(za,xa);

%% Set up the element coordinate system
elWidth = 1;
xe = -elWidth/2:dx:elWidth/2;
ze = d;
[Ze,Xe] = meshgrid(ze,xe);

%% Interpolate data from element coordinate system to array coordinates
elements = transducerGeometry(0);
sArray = zeros(size(Xa,1),8-(gridSize-1),size(Xa,2));
nElements = sArray;
tmplt = double(gs.tmplt);
skullLoc = zeros(length(blocks),3);
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
%         s = (abs(hilbert(s)));
        s(d<gs.powerRange(1) | d>gs.powerRange(2)) = 0;
        sTot = sTot+s;
    end
    s = sTot;
%     sAll(:,ii) = s;
    
    fe = frontEdgeMatchedFilter(s,tmplt,dt);
    [skullLoc(ii,1),skullLoc(ii,2),skullLoc(ii,3)] = element2arrayCoords(0,0,d(fe),centerElement);
    
    s = zeros(size(s));
    s(fe-5:fe+5) = 1;
    
    sExpanded = zeros(size(Xe));
    for jj = 1:length(xe)
        sExpanded(jj,:) = s;
    end
    
    curS = interp2(Ze,Xe,sExpanded,Zar,Xar,'spline',0);
    sArray(:,row,:) = squeeze(sArray(:,row,:)) + curS;
    
    nElements(curS~=0) = nElements(curS~=0)+1;

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
