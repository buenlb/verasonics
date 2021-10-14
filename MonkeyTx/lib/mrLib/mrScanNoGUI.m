% mrScanNoGUI loads an MR scan of a macaque head and doppler 256
% transducer, finds the transducer coordinates relative to the MR
% coordinate system, and returns the result in a struct that can be passed
% to simulate or sonicate.
% 
% @INPUTS
%   dcmDirectory: Directory where MR dicoms are stored. Optional, if not
%       passed then the user will be queried for the directory
%       NOTE: For testing purposes, dcmDirectory can also be a struct
%           already containing the img file and the resolution. This allows
%           for more rapid debugging since it avoids the slow loading of
%           the files.
% 
% @OUTPUTS
%   sys: Struct containing the following fields
%       img: 3D MR Image with dimensions corresponding to the x,y,z axes of
%         the transducer
%       centerIdx: center location of transducer relative to MR coordinates
%       res: resolution of MR image
%       txImg: Image with the same size as img thatis 1 where there is
%         transducer or fiducial
%       x: vector describing voxel locations in x
%       y: vector describing voxel locations in y
%       z: vector describing voxel locations in z
%       xyzAxes: 3x2 vector describing the limits of x, y, and z
% 
% Taylor Webb
% University of Utah

function sys = mrScanNoGUI(sys)

addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\mrLib\transducerLocalization')

%% Prompt user for location of MR scan if none was provided
if ~isfield(sys,aPath)
    sys.aPath = uigetdir();
    
    if ~dcmDirectory
        error('User cancelled')
    end
end

%% Load MR scan
[img,header] = loadDicomDir(dcmDirectory);

%% Re-configure image to match the Tx coordinate convention
% [xDim,yDim,zDim,xDir,yDir,zDir,res] =  assignTxAxes(header{1});
[ax,ay,az,res,dimOrder] = registerTx(header);
% dimOrder gives the dimension of the x,y,and z axes from the MR's
% perspective.
img = permute(img,[xDim,yDim,zDim]);
img = img(end:-1:1,:,:);
if xDir < 0
    img = img(end:-1:1,:,:);
end
if yDir < 0
    img = img(:,end:-1:1,:);
end
if zDir < 0
    img = img(:,:,end:-1:1);
end

res = res*1e-3;

sys.img = img;
sys.res = res;

xAx = [0,res(1)*(size(img,1)-1)];
yAx = [0,res(2)*(size(img,2)-1)];
zAx = [0,res(3)*(size(img,3)-1)];

x = linspace(xAx(1),xAx(2),size(img,1));
y = linspace(yAx(1),yAx(2),size(img,2));
z = linspace(zAx(1),zAx(2),size(img,3));

sys.xyzAxes = [xAx;yAx;zAx];
sys.x = x;
sys.y = y;
sys.z = z;

%% Register Transducer
waitfor(selectTxLocationGui(sys));
estimatedCenter = load('guiFileOutput');
delete('guiFileOutput.mat')
sys.userEstimateOfTxLocation = estimatedCenter.txCenter;

[txCenter,theta] = findTx(img,res,estimatedCenter.txCenter);
% txCenter = sys.userEstimateOfTxLocation
% theta = 0;

%% Display result
img2d = squeeze(img(:,:,txCenter(2)));
% img2d = sum(img,3);
tmplt3d = drawTransducer(sys,size(img),txCenter,theta,res,1);
tmplt2d = sum(tmplt3d,3);
tmplt2d(tmplt2d > 1) = 1;
h = figure;
ax = gca;
mxWdw = max(img2d(:));
overlayImages(img2d',tmplt2d',ax,x,y,0.5,[0,mxWdw],0.3,'winter');
axis('equal')

yIdx = txCenter(2);
img2d = squeeze(img(:,yIdx,:));
tmplt2d = squeeze(tmplt3d(:,round(yIdx),:));
figure;
ax = gca;
overlayImages(img2d',tmplt2d',ax,x,z,0.5,[0,0.5*mxWdw],0.3,'winter');
axis('equal')

%% Setup output
sys.centerIdx = txCenter;
sys.txImg = tmplt3d;