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

function sys = registerTx(sys)

addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\mrLib\transducerLocalization')

%% Prompt user for location of MR scan if none was provided
if ~isfield(sys,'mrPath')
    sys.aPath = uigetdir();
    
    if ~sys.aPath
        error('User cancelled')
    end
end
aPath = [sys.mrPath,num2str(sys.aSeriesNo,'%03d'),'\'];

if ~exist(aPath,'dir')
    sortDicoms(sys.incomingDcms,sys.mrPath)
end
%% Load MR scan
[img,header] = loadDicomDir(aPath);

%% Re-configure image to match the Tx coordinate convention

% dimOrder gives the dimension of the x,y,and z axes from the MR's
% perspective. There is no center for the transducer yet. Thus, adopting
% isocenter as the center for Tx coords, ux=-ax, uy=-az, and uz=-ay. Here
% ax, ay, and az are set in the transducer mindset resulting in ux=-ax,
% uy=-ay, and uz=-az. This avoids having to keep more careful track of the
% conversion going forward.
[ax,az,ay,res,dimOrderMr] = findMrCoordinates(header);
res = [res(1),res(3),res(2)];
dimOrderTx = [dimOrderMr(1),dimOrderMr(3),dimOrderMr(2)];
img = permute(img,dimOrderTx);

% Get the direction of axes correct. Note that increasing ax, ay, or az
% means decreasing ux, uy, or uz. Therefore it is a positively oriented
% anatomical axis that results in a reversing of the ultrasound axis.
if ax(2)-ax(1) > 0
    img = img(end:-1:1,:,:);
    ax = ax(end:-1:1);
end
if ay(2)-ay(1) > 0 
    img = img(:,end:-1:1,:);
    ay = ay(end:-1:1);
end
if az(2)-az(1) > 0 
    img = img(:,:,end:-1:1);
    az = az(end:-1:1);
end

%% This code switchs the axes for phantom scans done upside down to eliminate coupling issues
if sys.invertTx
    warning('Assuming upside down Tx!')
    img = img(:,:,end:-1:1);
    az = az(end:-1:1);

    img = img(end:-1:1,:,:);
    ax = ax(end:-1:1);
end

%%
res = res*1e-3;

sys.aImg = img;
sys.aRes = res;

% Temporarily set these for the gui - they will need to be reset after we
% find the center.
xAx = [0,res(1)*(size(img,1)-1)];
yAx = [0,res(2)*(size(img,2)-1)];
zAx = [0,res(3)*(size(img,3)-1)];

x = linspace(xAx(1),xAx(2),size(img,1));
y = linspace(yAx(1),yAx(2),size(img,2));
z = linspace(zAx(1),zAx(2),size(img,3));

sys.xyzAxes = [xAx;yAx;zAx];
sys.ux = x;
sys.uy = y;
sys.uz = z;

%% Save MR Coordinates
sys.ax = ax*1e-3;
sys.ay = ay*1e-3;
sys.az = az*1e-3;

%% Register Transducer
waitfor(selectTxLocationGui(sys));
estimatedCenter = load('guiFileOutput');
delete('guiFileOutput.mat')
sys.userEstimateOfTxLocation = estimatedCenter.txCenter;

[txCenter,theta] = findTx(img,res,estimatedCenter.txCenter,sys.xDist,sys.yDist,sys.zDist);
% txCenter = sys.userEstimateOfTxLocation
% theta = 0;

%% Recenter Tx Coordinates
sys.ux = x-x(txCenter(1));
sys.uy = y-y(txCenter(2));
sys.uz = z-z(txCenter(3));
sys.xyzAxes = [sys.ux(1),sys.ux(end);sys.uy(1),sys.uy(end);sys.uz(1),sys.uz(end)];

sys.txCenterIdx = txCenter;
sys.txTheta = theta;
sys.txCenter = [sys.ax(txCenter(1)),sys.ay(txCenter(2)),sys.az(txCenter(3))];
%% Display result
tmplt3d = displayTxLoc(sys);
sys.txImg = tmplt3d;