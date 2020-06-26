% Plots orthogonal views of the temperature overlaid on the anatomical
% image specified by sys.
% 
% @INPTUS
%   sys: System struct created by overlayTemperatureAnatomy
%   dynamic: Temperature dynamic (thermometry image number)
%   tWindow: minimum and maximum temperature to display
% 
% Taylor Webb
% University of Utah

function orthogonalTemperatureViews(sys,dynamic,tWindow)
if nargin < 3
    tWindow = [0,5];
end
%% Pull relevant variables out of sys
focus = sys.focalSpotMr*1e-3;
focalRadius = 5e-3;

ax = sys.ax;
ay = sys.ay;
az = sys.az;
[aY,aX,aZ] = meshgrid(ay,ax,az);

aImg = sys.aImg;
tInterp = sys.tInterp;
tInterp(isnan(tInterp)) = 0;

%% Find the index of the focus (given in MR coords)
[~,focalIdx] = min(sqrt((aX(:)-focus(1)).^2+(aY(:)-focus(2)).^2+(aZ(:)-focus(3)).^2));
[fX,fY,fZ] = ind2sub(size(aX),focalIdx);

%% Overlay images
% Coronal
h = figure;
sp2 = subplot(231);
overlayImages2(squeeze(aImg(:,fY,:)).',squeeze(tInterp(:,fY,:,dynamic)).',[],tWindow,ax,az,sp2,0.8);
xlabel('x')
ylabel('z')
title('Coronal')
makeFigureBig(h);

% Sagital
sp3 = subplot(232);
overlayImages2(squeeze(aImg(fX,:,:)).',squeeze(tInterp(fX,:,:,dynamic)).',[],tWindow,ay,az,sp3,0.8);
xlabel('y')
ylabel('z')
title('Sagital')
makeFigureBig(h);

% Axial
sp1 = subplot(233);
overlayImages2(aImg(:,:,fZ),squeeze(tInterp(:,:,fZ,dynamic)),[],tWindow,ay,ax,sp1,0.8);
xlabel('y')
ylabel('x')
title('Axial')
makeFigureBig(h);

%% Show temperature over time
R = sqrt((aX-focus(1)).^2+(aY-focus(2)).^2+(aZ-focus(3)).^2);
roi = zeros(size(aX));
roi(R<focalRadius) = 1;
roi = logical(roi);

tTimeAvg = zeros(1,size(tInterp,4));
tTimeMax = zeros(1,size(tInterp,4));
for ii = 1:size(tInterp,4)
    curT = tInterp(:,:,:,ii);
    tTimeAvg(ii) = mean(curT(roi));
    tTimeMax(ii) = max(curT(roi));
end

subplot(234)
plot(1:size(tInterp,4),tTimeAvg,'-',1:size(tInterp,4),tTimeMax,'--','linewidth',2)
legend('Mean','Max','location','northwest');
xlabel('Dynamic')
ylabel('Temperature (degrees)')
title('Temperature Over Time')
grid on
makeFigureBig(h);

subplot(235)
plot(ax-focus(1),tInterp(:,fY,fZ,dynamic),'-','linewidth',2);
hold on
plot(ay-focus(2),squeeze(tInterp(fX,:,fZ,dynamic)),'-','linewidth',2);
axis([focus(1)-focalRadius,focus(1)+focalRadius,tWindow])
plot(az-focus(3),squeeze(tInterp(fX,fY,:,dynamic)),'-','linewidth',2);
legend('x','y','z');
axis([-focalRadius,focalRadius,-tWindow(2),tWindow(2)])
title('Cuts through the focus')
xlabel('mm')
ylabel('Temperature(C)')
grid on
makeFigureBig(h);

% subplot(236)
% roiSag = squeeze(double(roi(:,fY,:)));
% roiCor = squeeze(double(roi(fX,:,:)));
% roiAx = squeeze(double(roi(:,:,fZ)));
% roiTot = zeros(size(roiSag)+size(roiCor)+size(roiAx));
% 
% aSag = squeeze(double(aImg(:,fY,:)));
% aCor = squeeze(double(aImg(fX,:,:)));
% aAx = squeeze(double(aImg(:,:,fZ)));
% aTot = zeros(size(roiTot));
% aTot(1:size(aSag,1),1:size(aSag,2)
% overlayImages2(squeeze(aImg(:,fY,:)),tmpRoi,[],[0.1,1],az,ax,sp2,0.8);
% title('ROI')

% pos = get(h,'position');
set(h,'position',[1          41        1920         963]);