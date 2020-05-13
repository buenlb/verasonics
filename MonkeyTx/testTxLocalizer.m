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
    addpath('lib\transducerLocalization')
end

%% Load dicoms 
dcmPath = 'C:\Users\Taylor\Documents\Projects\txLocCovid\004\';
[img,header] = loadDicomDir(dcmPath);
img = permuteImg(img,2,3,1);
res = [header{1}.PixelSpacing(1);header{1}.SpacingBetweenSlices;header{1}.PixelSpacing(2)]*1e-3;

%%
% The fiducials span a FOV of about 160 mm but this image set is only 120
% mm so I need to expand it in order to achieve a good simulation of what
% we will encounter with the actual scans
fov = res(1)*size(img,1);
expRows = round(190e-3/fov*size(img,1))-size(img,1);
expImg = 576+88*(randn(expRows+size(img,1),size(img,2),20+size(img,3)));
expImg(ceil(expRows/2):(ceil(expRows/2)+size(img,1)-1),:,...
    21:20+size(img,3)) = img;

%% Create Fiducials
img = expImg;

% Fiducial characteristics (locations relative to center of transducer)
xDist = 78e-3;
yDist = 31.5e-3;

txLocationIdx = [200,50,50];
txAngle = 7*pi/180;

[fiducialShape,~,fdIdx] = createFiducialTemplate(xDist,yDist,res,'sphere',txAngle,txLocationIdx,size(img));
fiducialShape = fiducialShape*3000;  % Make it approximately as bright as grey matter.
fiducialShape = imgaussfilt(fiducialShape,5);

img(fdIdx{1,1},fdIdx{1,2},fdIdx{1,3}) = fiducialShape+576+88*randn(size(fiducialShape));
img(fdIdx{2,1},fdIdx{2,2},fdIdx{2,3}) = fiducialShape+576+88*randn(size(fiducialShape));
img(fdIdx{3,1},fdIdx{3,2},fdIdx{3,3}) = fiducialShape+576+88*randn(size(fiducialShape));

x = 0:res(1):((size(img,1)-1)*res(1));
y = 0:res(2):((size(img,2)-1)*res(2));
z = 0:res(3):((size(img,3)-1)*res(3));

%% Test localization
tic 
[txCenter,theta] = findTx(img,res,txLocationIdx+[4,-2,8]);
toc
err = 1e3*norm(txLocationIdx.*res'-txCenter.*res');
disp(['Found with ', num2str(err), 'mm of position error and ', num2str(abs(theta-txAngle)*180/pi), ' degrees of angular error.'])
%% Display result
img2d = squeeze(img(:,:,150));
% img2d = sum(img,3);
tmplt3d = drawTransducer(size(img),txCenter,theta,res);
tmplt2d = sum(tmplt3d,3);
tmplt2d(tmplt2d > 1) = 1;
h = figure;
ax = gca;
mxWdw = max(img2d(:));
overlayImages(img2d',tmplt2d',ax,x,y,0.5,[0,mxWdw],0.3,'winter');
axis('equal')

yIdx = round((fdIdx{1,2}(end)-fdIdx{1,2}(1))/2+fdIdx{1,2}(1))-1;
img2d = squeeze(img(:,yIdx,:));
tmplt2d = squeeze(tmplt3d(:,round(yIdx),:));
h = figure;
ax = gca;
overlayImages(img2d',tmplt2d',ax,x,z,0.5,[0,0.5*mxWdw],0.3,'winter');
axis('equal')