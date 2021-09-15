% Takes the recevie data made by VSX running imaging_singleElement.mat and
% produces a b-mode image based on the data
% 
% @INPUTS
%   RcvData: Raw data created by VSX (pass as RcvData{1} to eliminate the
%       uneccesary cell array)
%   Receive: Receive struct used by VSX
%   distOfInterest: Optional. If length(distOfInterest) = 1 then all the
%       signal arriving before distOfInterest is set to zero. if
%       length(distOfInterest) = 2 then only signal between
%       distOfInterest(1) and distOfInterest(2) is displayed. Distances are
%       computed by assuming a speed of sound in water of 1492 m/s.
%       distOfInterest should be given in mm.
%	txSn: serial number of transducer used to acquire data. Defaults to
%		JAB800;
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

function [sArray,xa,ya,za] = singleElementBModeImage(RcvData,Receive,distOfInterest,txSn,plotResult)
if ~exist('plotResult','var')
    plotResult = 0;
end
if ~exist('txSn','var')
	warning('Serial number not passed to griddedElementBModeImage, assuming JAB800');
	txSn = 'JAB800';
end

% Set up time/distance vectors corresponding to data
t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);
d = t*1.492/2;

% Determine ROI based on distOfInterest
if ~exist('distOfInterest','var')
    distOfInterest = [d(1),d(end)];
elseif isempty(distOfInterest)
    distOfInterest = [d(1),d(end)];
elseif length(distOfInterest) == 1
    distOfInterest = [distOfInterest, d(end)];
elseif length(distOfInterest) ~= 2
    error('distOfInterest must be either 1 or 2 elements in length')
end

% Set up the element coordinate system
elWidth = 5;
dx = 2;
xe = -elWidth/2:dx:elWidth/2;
ye = xe;
ze = d;
[Ye,Xe,Ze] = meshgrid(ye,xe,ze);

% Set up the array coordinate system
xa = -60/2:dx:60/2;
ya = -56/2:dx:56/2;
za = 10:dx:60;
[Ya,Xa,Za] = meshgrid(ya,xa,za);

%% Interpolate data from element coordinate system to array coordinates
elements = transducerGeometry(0,txSn);   
sArray = zeros(size(Xa));
nElements = sArray;
for ii = 1:size(elements.ElementPos,1)
    disp(['Element ', num2str(ii), ' of ', num2str(size(elements.ElementPos,1))])
    [Xar,Yar,Zar] = array2elementCoords(Xa,Ya,Za,elements.ElementPos(ii,:));
    
    s = RcvData(Receive(ii).startSample:Receive(ii).endSample,ii);
    s = (abs(hilbert(s)));
    s(d<distOfInterest(1) | d>distOfInterest(2)) = 0;

    sExpanded = zeros(size(Xe));
    for jj = 1:length(xe)
        for kk = 1:length(ye)
            sExpanded(jj,kk,:) = s;
        end
    end
    
    curS = interp3(Ye,Xe,Ze,sExpanded,Yar,Xar,Zar,'spline',0);
    sArray = sArray + curS;
    
    nElements(curS~=0) = nElements(curS~=0)+1;

end
% Account for voxels that have signal from multiple elements
sArray = sArray./nElements;

%% Display results
if plotResult
    h = figure;
    yFrames = unique(elements.ElementPos(:,2));
    rows = floor(sqrt(length(yFrames)));
    cols = ceil(sqrt(length(yFrames)));
    if rows*cols < length(yFrames)
        cols = cols+1;
    end

    for ii = 1:rows*cols
        subplot(rows,cols,ii)
        [~,yIdx] = min(abs(ya-yFrames(ii)));
        imshow(squeeze(sArray(:,yIdx,:)),[0,max(sArray(:))],'xdata',za,'ydata',xa);
        title(['y=',num2str(ya(yIdx))]);
        colorbar
        drawnow
    end
    set(h,'position',[1          41        1920        1083]);
    drawnow
end