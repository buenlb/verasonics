function showActualFocus(sys,sonicationNo,centerLoc,expectedPeakIdx,pbw,flags,saveName)
findMax = 0;
plotFS = 0;
plotMax = 0;
plotTarget = 0;
plotLeftLgnRoi = 0;
plotRightLgnRoi = 0;
DENOISE = 0;
if flags(1)
    plotFS = 1;
end
if flags(2)
    plotMax = 1;
end
if flags(3)
    plotTarget = 1;
    if ~isfield(sys,'pastTargets')
        msgbox('Error: Past Targets Flag is on but no targets are specified.!')
        return
    end
end
if flags(4)
    findMax = 1;
end
if flags(5)
    plotLeftLgnRoi = 1;
end
if flags(6)
    plotRightLgnRoi = 1;
end
if flags(7)
    DENOISE = 1;
end

%% Find the peak temperature within a range around the desired focus
tx = sys.tx;
ty = sys.ty;
tz = sys.tz;

radiusOfInterest = 2.5e-3;
[TY,TX,TZ] = meshgrid(ty,tx,tz);
if nargin < 3
    fs = sys.sonication(sonicationNo).focalSpotMr*1e-3;
else
    fs = [sys.ax(centerLoc(1)),sys.ay(centerLoc(2)),sys.az(centerLoc(3))];
end
R = sqrt((TX-fs(1)).^2+(TY-fs(2)).^2+(TZ-fs(3)).^2);
roi = false(size(R));
roi(R<=radiusOfInterest) = true;

curT = squeeze(sys.T(:,:,:,expectedPeakIdx));
[maxT,maxIdx] = max(curT(roi));
idx = find(roi);
[xIdx,yIdx,zIdx] = ind2sub(size(curT),idx(maxIdx));

if findMax
    [~,xIdx] = min(abs(sys.ax-tx(xIdx)));
    [~,yIdx] = min(abs(sys.ay-ty(yIdx)));
    [~,zIdx] = min(abs(sys.az-tz(zIdx)));
else
    xIdx = centerLoc(1);
    yIdx = centerLoc(2);
    zIdx = centerLoc(3);
end

tLims = [pbw*maxT,maxT];

%% Use magnitude of anatomy image to clean up the result
if DENOISE
    tImage = sys.tInterp_deNoised;
else
    tImage = sys.tInterp;
end
tmp = tImage(:,:,:,expectedPeakIdx);
tmp(sys.aImg<mean(sys.aImg(:))) = 0;
tImage(:,:,:,expectedPeakIdx) = tmp;
clear tmp

%% Display the result
fovX = (sys.ux(end)-sys.ux(1));
fovY = abs(sys.uy(end)-sys.uy(1));
fovZ = abs(sys.uz(end)-sys.uz(1));

zSize = 6;
ySize = fovY/fovZ*zSize;
xSize = fovX/fovZ*zSize;

h = figure;
h.Units = 'Inches';
h.Position = [1.7,0.4,2*xSize+ySize,zSize+1];
h.InvertHardcopy = 'off';

% Depending on flags, add in LGN ROIs
curImg = squeeze(sys.aImg(:,yIdx,:));
if plotLeftLgnRoi
    edgeRoi = edge(squeeze(sys.leftLgnRoi(:,yIdx,:)));
    curImg(edgeRoi) = max(curImg(:));
end
if plotRightLgnRoi
    edgeRoi = edge(squeeze(sys.rightLgnRoi(:,yIdx,:)));
    curImg(edgeRoi) = max(curImg(:));
end
mkSize = 4;
ax1 = subplot(131);
ax1.Units = 'Inches';
overlayImages2(curImg',squeeze(tImage(:,yIdx,:,expectedPeakIdx))',[],tLims,sys.ux*1e3,sys.uz*1e3,ax1,0.5,'hot')

% Depending on flags, plot focus, maximum, and target
hold on
if plotFS
    plot(sys.focalSpot(1),sys.focalSpot(3),'^w','markersize',mkSize)
end
if plotMax
    plot(1e3*sys.ux(xIdx),1e3*sys.uz(zIdx),'xw','markersize',mkSize)
end
if plotTarget
    if ~isfield(sys,'pastTargets')
        error('Must specify past Targets!')
    end
    plot(sys.pastTargets(:,1),sys.pastTargets(:,3),'*b','markersize',mkSize)
end
axis('tight')
% ax1.Position = [0,0,xSize,zSize];

ax2 = subplot(132);
ax2.Units = 'Inches';

% Depending on flags, add in LGN ROIs
curImg = squeeze(sys.aImg(xIdx,:,:));
if plotLeftLgnRoi
    edgeRoi = edge(squeeze(sys.leftLgnRoi(xIdx,:,:)));
    curImg(edgeRoi) = max(curImg(:));
end
if plotRightLgnRoi
    edgeRoi = edge(squeeze(sys.rightLgnRoi(xIdx,:,:)));
    curImg(edgeRoi) = max(curImg(:));
end
overlayImages2(curImg',squeeze(tImage(xIdx,:,:,expectedPeakIdx))',[],tLims,sys.uy*1e3,sys.uz*1e3,ax2,0.5,'hot')
hold on
if plotFS
    plot(sys.focalSpot(2),sys.focalSpot(3),'^w','markersize',mkSize)
end
if plotMax
    plot(1e3*sys.uy(yIdx),1e3*sys.uz(zIdx),'xw','markersize',mkSize)
end
if plotTarget
    if ~isfield(sys,'pastTargets')
        error('Must specify past Targets!')
    end
    plot(sys.pastTargets(:,2),sys.pastTargets(:,3),'*b','markersize',mkSize)
end
axis('tight')
% ax2.Position = [xSize,0,ySize,zSize];

ttl = title(['Sonication: ', num2str(sys.curSonication),...
    ', Target: ', num2str(sys.sonication(sonicationNo).focalSpot(1)), ', ',...
    num2str(sys.sonication(sonicationNo).focalSpot(2)), ', ', num2str(sys.sonication(sonicationNo).focalSpot(3)),...
    ', Location: ', num2str(1e3*sys.ux(xIdx)), ', ', num2str(1e3*sys.uy(yIdx)), ', ', num2str(1e3*sys.uz(zIdx))]);
ttl.Color = 'w';
makeFigureBig(h,18,18,'k');

ax3 = subplot(133);
ax3.Units = 'Inches';

% Depending on flags, add in LGN ROIs
curImg = squeeze(sys.aImg(:,:,zIdx));
if plotLeftLgnRoi
    edgeRoi = edge(squeeze(sys.leftLgnRoi(:,:,zIdx)));
    curImg(edgeRoi) = max(curImg(:));
end
if plotRightLgnRoi
    edgeRoi = edge(squeeze(sys.rightLgnRoi(:,:,zIdx)));
    curImg(edgeRoi) = max(curImg(:));
end

overlayImages2(curImg',squeeze(tImage(:,:,zIdx,expectedPeakIdx))',[],tLims,sys.ux*1e3,sys.uy*1e3,ax3,0.5,'hot')
hold on
if plotFS
    plot(sys.focalSpot(1),sys.focalSpot(2),'^w','markersize',mkSize)
end
if plotMax
    plot(1e3*sys.ux(xIdx),1e3*sys.uy(yIdx),'xw','markersize',mkSize)
end
if plotTarget
    if ~isfield(sys,'pastTargets')
        error('Must specify past Targets!')
    end
    plot(sys.pastTargets(:,1),sys.pastTargets(:,2),'*b','markersize',mkSize)
end
axis('tight')
% ax3.Position = [xSize+ySize,0,xSize,zSize];

ax4 = axes('Visible','off');
colormap(ax4,'hot');
c = colorbar;
c.Units = 'Inches';
c.Position = [xSize*2+ySize-0.75,0.2,0.222,zSize-0.4];
c.Color = 'w';
caxis(tLims);
makeFigureBig(h,18,18,'k');

if exist('saveName','var')
    print(h,saveName,'-dpng');
end
