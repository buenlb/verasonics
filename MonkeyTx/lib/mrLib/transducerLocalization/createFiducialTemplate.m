% createFiducialTemplate returns a template of fiducial markers for use as
% a matched filter.
%
% @INPUTS
%   xDist: x-distance between center of transducer and fiducial center
%   yDist: y-distance between center of transducer and fiducial center
%   res: desired resolution of resulting templates (m)
%   fiducialShape: string specifying shape of fiducial used.
%       Possible Values:
%           tube: epindorf centrifuge tube
%           sphere: spherical fiducial with radius 5.5 mm
%           vitE: Ellipsoid fiducial with dimensions of vitamin E pill. The
%               one I had at the time of this writing was a = b = 3.5 mm
%               and c = 7.75 mm.
%   theta: optional input. a two element vector representing the angle
%       between the transducer's x-axis and the x-axis of the image
%       (element 1) and the angle between the xy plane of the transducer
%       and the xy plane of the image (element 2). Both angles should be
%       given in radians
%   center: optional, location of Tx Center. Defaults to the center of the
%       image
%   szImg: optional. Size of image to create. Details to a size just large
%       enough to hold the transducer
% 
% @OUTPUTS
%   ind: individual fiducial shape at resolution res
%   complete: all fiducials at appropriate distance based on xDist, yDist,
%       and res.
%   fdIndices: The indices at which complete was set to an individual
%       fiducial, ind
%   txCenter: The index at which the center was placed. Useful for angled
%       templates that didn't get a center passed in.

function [ind,complete,fdIndices,txCenter] = createFiducialTemplate(xDist,yDist,zDist,res,fiducialShape,theta,txCenter,szImg)
%% Create individual markers
switch fiducialShape
    case 'tube'
        % Fiducial shape
        tubeD = 8e-3;
        tubeDSmall = 3e-3;
        tubeLengthStraight= 25e-3;
        tubeLengthAngled = 5e-3;

        xf = (-tubeD*3/4):res(1):(tubeD*3/4);
        yf = (-tubeD*3/4):res(2):(tubeD*3/4);
        zf = 0:res(3):(tubeLengthStraight+tubeLengthAngled);

        [YF,XF] = meshgrid(yf,xf,zf);

        fiducialShape = zeros(size(XF));
        r = sqrt(XF(:,:,1).^2+YF(:,:,1).^2);
        for ii = 1:size(fiducialShape,3)
            curSlice = zeros(size(XF(:,:,1)));
            if ii*res(3)<tubeLengthStraight
                curSlice(r<tubeD/2) = 1;
            else
                curZ = ii*res(3);
                curD = tubeD-(tubeD-tubeDSmall)*(curZ-tubeLengthStraight)/(tubeLengthAngled);
                curSlice(r<curD/2) = 1;
            end
            fiducialShape(:,:,ii) = curSlice;
        end
        ind = fiducialShape;
    case 'sphere'
         r = 5.5e-3;
         
         xf = -r:res(1):r;
         yf = -r:res(2):r;
         zf = -r:res(3):r;
         
         [YF,XF,ZF] = meshgrid(yf,xf,zf);
         
         fiducialShape = zeros(size(XF));
         fiducialShape(sqrt(YF.^2+XF.^2+ZF.^2)<r) = 1;
         
         ind = fiducialShape;
    case 'vitE'
        % Elipsoid semi-axes in m.
        a = (7/2)*1e-3;
        b = (7/2)*1e-3;
        c = (15.5/2)*1e-3;
        
        xf = -a:res(1):a;
        yf = -b:res(2):b;
        zf = -c:res(3):c;
        
        [YF,XF,ZF] = meshgrid(yf,xf,zf);
        
        fiducialShape = zeros(size(XF));
        fiducialShape(XF.^2/a^2+YF.^2/b^2+ZF.^2/c^2 < 1) = 1;
        ind = fiducialShape;
    otherwise
        error(['Fiducial Shape: ', fiducialShape, ' not recognized'])
end
%% Parse input
if nargin < 6
    theta = [0,0];
    szImg = [ceil(2*xDist/res(1)+2*size(ind,1)),ceil(2*yDist/res(2))+2*size(ind,2)+round(abs(sin(theta(1))*xDist)/res(2)),2*size(ind,3)+2*ceil(zDist/res(3))];
    txCenter = ceil(szImg/2)+1;
elseif nargin == 6
    szImg = [ceil(2*xDist/res(1)+2*size(ind,1)),ceil(2*yDist/res(2))+2*size(ind,2)+2*round(abs(sin(theta(1))*xDist)/res(2)),2*size(ind,3)+2*ceil(zDist/res(3))];
    txCenter = ceil(szImg/2)+1;
elseif nargin < 8
    error('If txCenter is specified then size must also be specified')
end
%% Place markers
complete = zeros(szImg);

x = 0:res(1):((size(complete,1)-1)*res(1));
y = 0:res(2):((size(complete,2)-1)*res(2));
z = 0:res(3):((size(complete,3)-1)*res(3));

center = [x(txCenter(1)),y(txCenter(2)),z(txCenter(3))];
[Y,X,Z] = meshgrid(y,x,z);
% First Fiducial
fid1 = [(center(1)-xDist*cos(theta(1))),center(2)-sin(theta(1))*xDist,center(3)+zDist];
[~,fid1Idx] = min((X(:)-fid1(1)).^2+(Y(:)-fid1(2)).^2+(Z(:)-fid1(3)).^2);
[fid1_xIdx,fid1_yIdx,fid1_zIdx] = ind2sub(size(X),fid1Idx);

szFd = size(fiducialShape);
xIdx = ((fid1_xIdx-floor(szFd(1)/2)):(fid1_xIdx+(ceil(szFd(1)/2))-1));
yIdx = ((fid1_yIdx-floor(szFd(2)/2)):(fid1_yIdx+(ceil(szFd(2)/2))-1));
zIdx = ((fid1_zIdx-floor(szFd(3)/2)):(fid1_zIdx+(ceil(szFd(3)/2))-1));
if max(xIdx)>size(complete,1) || max(yIdx)>size(complete,2) || max(zIdx)>size(complete,3)
    keyboard
    error('Exceeds dimensions of complete.')
end
complete(xIdx,yIdx,zIdx) = fiducialShape;

fdIndices{1,1} = xIdx;
fdIndices{1,2} = yIdx;
fdIndices{1,3} = zIdx;

% Second Fiducial
fid2 = [center(1)+xDist*cos(theta(1))-yDist*sin(theta(1)),center(2)+yDist*cos(theta(1))+xDist*sin(theta(1)),center(3)+zDist];
[~,fid2Idx] = min((X(:)-fid2(1)).^2+(Y(:)-fid2(2)).^2+(Z(:)-fid2(3)).^2);
[fid2_xIdx,fid2_yIdx,fid2_zIdx] = ind2sub(size(X),fid2Idx);

xIdx = ((fid2_xIdx-floor(szFd(1)/2)):(fid2_xIdx+(ceil(szFd(1)/2))-1));
yIdx = ((fid2_yIdx-floor(szFd(2)/2)):(fid2_yIdx+(ceil(szFd(2)/2))-1));
zIdx = ((fid2_zIdx-floor(szFd(3)/2)):(fid2_zIdx+(ceil(szFd(3)/2))-1));
if max(xIdx)>size(complete,1) || max(yIdx)>size(complete,2) || max(zIdx)>size(complete,3)
    keyboard
    error('Exceeds dimensions of complete.')
end
complete(xIdx,yIdx,zIdx) = fiducialShape;

fdIndices{2,1} = xIdx;
fdIndices{2,2} = yIdx;
fdIndices{2,3} = zIdx;

% Third Fiducial
fid3 = [center(1)+xDist*cos(theta(1))+yDist*sin(theta(1)),center(2)-yDist*cos(theta(1))+xDist*sin(theta(1)),center(3)+zDist];
[~,fid3Idx] = min((X(:)-fid3(1)).^2+(Y(:)-fid3(2)).^2+(Z(:)-fid3(3)).^2);
[fid3_xIdx,fid3_yIdx,fid3_zIdx] = ind2sub(size(X),fid3Idx);

xIdx = ((fid3_xIdx-floor(szFd(1)/2)):(fid3_xIdx+(ceil(szFd(1)/2))-1));
yIdx = ((fid3_yIdx-floor(szFd(2)/2)):(fid3_yIdx+(ceil(szFd(2)/2))-1));
zIdx = ((fid3_zIdx-floor(szFd(3)/2)):(fid3_zIdx+(ceil(szFd(3)/2))-1));
if max(xIdx)>size(complete,1) || max(yIdx)>size(complete,2) || max(zIdx)>size(complete,3)
    keyboard
    error('Exceeds dimensions of complete.')
end
complete(xIdx,yIdx,zIdx) = fiducialShape;

fdIndices{3,1} = xIdx;
fdIndices{3,2} = yIdx;
fdIndices{3,3} = zIdx;