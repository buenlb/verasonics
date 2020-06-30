% Overlays thermometry data on a different anatomical MR image. Uses the
% headers to align the data automatically.
% 
% @INPUTS
%   sys: Struct containing the following fields
%     @MANDATORY FIELDS
%       anatomyPath: Directory in which Anatomical MR images are stored
%       thermPath: Directory in which thermometry images are held
%       thermMagPath: Directory in which magnitude images corresponding to
%         thermometry phase images are found.
%       nSlices: Number of slices in thermometry data
%     @OPTIONAL FIELDS
%       baseline: Baseline images in thermometry data set - defaults to 1
%       focus: focus in MR coordinates. This dictates which slice is shown.
%          If not provided then the function prompts the user to select one
%          using a GUI that shows the temperature results.
%   sonicationNo: Number of sonication to reconstruct
% @OUTPUTS
%   sys: Struct with the above fields and the addition of the following
%     fields
%       @Fields
%           aImg: Anatomy Image
%           tImg: phase image that has zeros where there is low magnitude
%           ax, ay, and az: x, y, and z axes of the anatomy Image in MR
%              coords
%           tx, ty, and tz: x, y, and z axes of the thermometry Image in MR
%              coords
%           T: Temperature results - zero where there is low magnitude
%           tInterp: Temperature results interpolated onto the anatomy
%              image dataset

% 
% Taylor Webb
% University of Utah

function sys = overlayTemperatureAnatomy(sys,sonicationNo)
%% Error check
if ~isfield(sys,'nSlices')
    error('You must provide the number of thermometry slices in the data.')
end
nSlices = sys.nSlices;

% if no sonication number is provided, default to the last one
if nargin < 2
    sonicationNo = length(sys.sonication);
end
%% Set baseline default if now baseline is provided
if ~isfield(sys,'baseline')
    sys.baseline = 1;
end

%% Anatomical Data
if ~isfield(sys,'aImg')
    [aImg,aHeader] = loadDicomDir([sys.mrPath,num2str(sys.aSeriesNo,'%03d')]);
    [ax,ay,az,~,aDimOrder] = findMrCoordinates(aHeader);
    dimOrderTx = [aDimOrder(1),aDimOrder(3),aDimOrder(2)];
    sys.aImg = permute(aImg,dimOrderTx);
else
    ax = sys.ax;
    ay = sys.ay;
    az = sys.az;
end

if ~isfield(sys,'tImg')
    [tImg,tHeader] = loadDicomDir([sys.mrPath,num2str(sys.sonication(sonicationNo).phaseSeriesNo,'%03d')]);
    tMagImg = loadDicomDir([sys.mrPath,num2str(sys.sonication(sonicationNo).magSeriesNo,'%03d')]);
else
    tImg = sys.tImg;
    tMagImg = sys.tMagImg;
    tHeader = sys.tHeader;
end
    tImg(tMagImg<30) = 0;
%% Get coordinates and reorient matrices along common axes
[tx,tz,ty,~,tDimOrder] = findMrCoordinates(tHeader(nSlices+1:2*nSlices));
dimOrderTx = [tDimOrder(1),tDimOrder(3),tDimOrder(2)];
tSys = sys;
tSys.img = tImg;
tSys.path = [sys.mrPath,num2str(sys.sonication(sonicationNo).phaseSeriesNo,'%03d')];
tSys.imgHeader = tHeader{nSlices+1};
T = getTemperatureSeimens(tSys,0);
tImg = permute(tImg,dimOrderTx);
T = permute(T,[dimOrderTx,4]);

tx = tx*1e-3;
ty = ty*1e-3;
tz = tz*1e-3;

% Get the direction of axes correct. Note that increasing ax, ay, or az
% means decreasing ux, uy, or uz. Therefore it is a positively oriented
% anatomical axis that results in a reversing of the ultrasound axis.
if tx(2)-tx(1) > 0
    tImg = tImg(end:-1:1,:,:);
    T = T(end:-1:1,:,:,:);
    tx = tx(end:-1:1);
end
if ty(2)-ty(1) > 0 
    tImg = tImg(:,end:-1:1,:);
    T = T(:,end:-1:1,:,:);
    ty = ty(end:-1:1);
end
if tz(2)-tz(1) > 0 
    tImg = tImg(:,:,end:-1:1);
    T = T(:,:,end:-1:1,:);
    tz = tz(end:-1:1);
end

if sys.invertTx
    warning('Inverting Tx!')
    tImg = tImg(:,:,end:-1:1);
    T = T(:,:,end:-1:1,:);
    tz = tz(end:-1:1);

    tImg = tImg(end:-1:1,:,:);
    T = T(end:-1:1,:,:,:);
    tx = tx(end:-1:1);
end

[tY,tX,tZ] = meshgrid(ty,tx,tz);
[aY,aX,aZ] = meshgrid(ay,ax,az);

%% Interpolate temperature data onto anatomical data
tInterp = zeros([size(aX),size(T,4)-1]);
for ii = 2:size(T,4)
    tInterp(:,:,:,ii-1) = interp3(tY,tX,tZ,T(:,:,:,ii),aY,aX,aZ);
end
%% Load results into sys
sys.tInterp = tInterp;

%% Plot Results
orthogonalTemperatureViews(sys,6,sonicationNo,[0,3]);
