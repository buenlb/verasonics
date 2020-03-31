% This file, written during the corona pandemic, uses Jan's image of the
% macaque brain to add theoretical fiducial markers and then tests an
% algorithms ability to locate them
% 
% Taylor Webb
% March 30, 2020
% University of Utah

clear all; close all; clc;

if ~exist('loadDicomDir.m','file')
    addpath('lib')
    addpath('..\lib\gui_lib')
    addpath('lib\txLocalization')
end

%% Load dicoms 
dcmPath = 'C:\Users\Taylor\Documents\Projects\txLocCovid\004\';
[img,header] = loadDicomDir(dcmPath);
img = permuteImg(img,2,3,1);
res = [header{1}.PixelSpacing;header{1}.SpacingBetweenSlices]*1e-3;

%%
% The fiducials span a FOV of about 160 mm but this image set is only 120
% mm so I need to expand it in order to achieve a good simulation of what
% we will encounter with the actual scans
fov = res(1)*size(img,1);
expRows = round(170e-3/fov*size(img,1))-size(img,1);
expImg = 576+88*(randn(expRows+size(img,1),expRows+size(img,2),size(img,3)));
expImg(ceil(expRows/2):(ceil(expRows/2)+size(img,1)-1),...
    ceil(expRows/2):(ceil(expRows/2)+size(img,2)-1),:) = img;
img = expImg;

%% Create Fiducials
% Fiducial shape
tubeD = 8e-3;
tubeDSmall = 3e-3;
tubeLengthStraight= 35e-3;
tubeLengthAngled = 10e-3;

xf = (-tubeD/2):res(1):(tubeD/2);
yf = (-tubeD/2):res(2):(tubeD/2);
zf = 0:res(3):(tubeLengthStraight+tubeLengthAngled);

[YF,XF,ZF] = meshgrid(yf,xf,zf);

fiducialShape = 576+88*randn(size(XF));
r = sqrt(XF(:,:,1).^2+YF(:,:,1).^2);
for ii = 1:size(fiducialShape,3)
    curSlice = 576+88*randn(size(XF(:,:,1)));
    if ii*res(3)<tubeLengthStraight
        curSlice(r<tubeD/2) = 3500; % Make it approximately as bright as grey matter.
    else
        curZ = ii*res(3);
        curD = tubeD-(tubeD-tubeDSmall)*(curZ-tubeLengthStraight)/(tubeLengthAngled);
        curSlice(r<curD/2) = 3500;  % Make it approximately as bright as grey matter.
    end
    fiducialShape(:,:,ii) = curSlice;
end
fiducialShape = imgaussfilt(fiducialShape,3);

%% Set up image and Tx space
x = 0:res(1):((size(img,1)-1)*res(1));
y = 0:res(2):((size(img,2)-1)*res(2));
z = 0:res(3):((size(img,3)-1)*res(3));
[Y,X,Z] = meshgrid(y,x,z);

trans = transducerGeometry(0);
xTx = trans.ElementPos(:,1)*1e-3;
yTx = trans.ElementPos(:,2)*1e-3;
zTx = trans.ElementPos(:,3)*1e-3;

%% Place Fiducials
% Location of transducer center
TxLocationIdx = [182,103,30];
TxLocation = [x(TxLocationIdx(1)),y(TxLocationIdx(2)),z(TxLocationIdx(3))];

xDist = 78e-3;
yDist = 31.5e-3;

% First Fiducial
fid1 = [TxLocation(1)-xDist,TxLocation(2),TxLocation(3)];
[~,fid1Idx] = min((X(:)-fid1(1)).^2+(Y(:)-fid1(2)).^2+(Z(:)-fid1(3)).^2);
[fid1_xIdx,fid1_yIdx,fid1_zIdx] = ind2sub(size(X),fid1Idx);

szFd = size(fiducialShape);
xIdx = (fid1_xIdx-floor(szFd(1))/2):(fid1_xIdx+(ceil(szFd(1)/2))-1);
yIdx = (fid1_yIdx-floor(szFd(2))/2):(fid1_yIdx+(ceil(szFd(2)/2))-1);
zIdx = (fid1_zIdx-floor(szFd(3))/2):(fid1_zIdx+(ceil(szFd(3)/2))-1);
img(xIdx,yIdx,zIdx) = fiducialShape;


% Second Fiducial
fid2 = [TxLocation(1)+xDist,TxLocation(2)+yDist,TxLocation(3)];
[~,fid2Idx] = min((X(:)-fid2(1)).^2+(Y(:)-fid2(2)).^2+(Z(:)-fid2(3)).^2);
[fid2_xIdx,fid2_yIdx,fid2_zIdx] = ind2sub(size(X),fid2Idx);

szFd = size(fiducialShape);
xIdx = (fid2_xIdx-floor(szFd(1))/2):(fid2_xIdx+(ceil(szFd(1)/2))-1);
yIdx = (fid2_yIdx-floor(szFd(2))/2):(fid2_yIdx+(ceil(szFd(2)/2))-1);
zIdx = (fid2_zIdx-floor(szFd(3))/2):(fid2_zIdx+(ceil(szFd(3)/2))-1);
img(xIdx,yIdx,zIdx) = fiducialShape;


% Third Fiducial
fid3 = [TxLocation(1)+xDist,TxLocation(2)-yDist,TxLocation(3)];
[~,fid3Idx] = min((X(:)-fid3(1)).^2+(Y(:)-fid3(2)).^2+(Z(:)-fid3(3)).^2);
[fid3_xIdx,fid3_yIdx,fid3_zIdx] = ind2sub(size(X),fid3Idx);

szFd = size(fiducialShape);
xIdx = (fid3_xIdx-floor(szFd(1))/2):(fid3_xIdx+(ceil(szFd(1)/2))-1);
yIdx = (fid3_yIdx-floor(szFd(2))/2):(fid3_yIdx+(ceil(szFd(2)/2))-1);
zIdx = (fid3_zIdx-floor(szFd(3))/2):(fid3_zIdx+(ceil(szFd(3)/2))-1);
img(xIdx,yIdx,zIdx) = fiducialShape;
