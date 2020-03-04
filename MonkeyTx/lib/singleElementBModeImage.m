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

function [img,xa,ya,za] = singleElementBModeImage(RcvData,Receive,distOfInterest)
% Set up time/distance vectors corresponding to data
t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);
d = t*1.492/2;

% Determine ROI based on distOfInterest
if ~exist('distOfInterest','var')
    distOfInterest = [d(1),d(end)];
elseif length(distOfInterest) == 1
    distOfInterest = [distOfInterest, d(end)];
elseif length(distOfInterest) ~= 2
    error('distOfInterest must be either 1 or 2 elements in length')
end

% Set up the element coordinate system
elWidth = 5;
dx = 1/3;
xe = -elWidth/2:dx:elWidth/2;
ye = xe;
ze = d;
[Ye,Xe,Ze] = meshgrid(ye,xe,ze);

% Set up the array coordinate system
xa = -156/2:dx:156/2;
ya = -56/2:dx:56/2;
za = 0:dx:70;
[Ya,Xa,Za] = meshgrid(ya,xa,za);

%% Interpolate data from element coordinate system to array coordinates
elements = transducerGeometry(0);   
sArray = zeros(size(Xa));
nElements = sArray;
for ii = 1:size(elements.ElementPos,1)
    disp(['Element ', num2str(ii), ' of ', num2str(size(elements.ElementPos,1))])
    [Xar,Yar,Zar] = array2elementCoords(Xa,Ya,Za,elements.ElementPos(ii,:));
    
    s = RcvData{1}(Receive(ii).startSample:Receive(ii).endSample,ii);
    s = log10(abs(hilbert(s)));
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
h = figure;
imshow(squeeze(sArray(:,ceil(length(ya)/2),:)),[0,3],'xdata',za,'ydata',xa)
colorbar
axis('equal')
axis('tight')
ax = gca;
ax.Visible = 'on';
set(h,'position',[1          41        1920        1083]);
xlabel('z (mm)')
ylabel('x (mm)')
title('Received signal (a.u.)')
makeFigureBig(h)

img = sArray;
