% Plots orthogonal views of the temperature overlaid on the anatomical
% image specified by sys.
% 
% @INPTUS
%   sys: System struct created by overlayTemperatureAnatomy
%   dynamic: Temperature dynamic (thermometry image number)
%   sonicationNo: Number of sonication to reconstruct
%   tWindow: minimum and maximum temperature to display
% 
% Taylor Webb
% University of Utah

function orthogonalTemperatureViews(sys,dynamic,sonicationNo,tWindow)
if nargin < 4
    tWindow = [0,5];
end
%% Pull relevant variables out of sys
focus = sys.sonication(sonicationNo).focalSpotMr*1e-3;
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

% Show ROIs
R = sqrt((aX-focus(1)).^2+(aY-focus(2)).^2+(aZ-focus(3)).^2);
roi = zeros(size(aX));
roi(R<focalRadius) = 1;
roi = logical(roi);

sp4 = subplot(234);
roiCor = squeeze(double(roi(:,fY,:)));
roiSag = squeeze(double(roi(fX,:,:)));
roiAx = squeeze(double(roi(:,:,fZ)));
 
aSag = squeeze(double(aImg(fX,:,:)));
aCor = squeeze(double(aImg(:,fY,:)));
aAx = squeeze(double(aImg(:,:,fZ)));

overlayImages2(aCor.',roiCor.',[],[0.1,1],ax,az,sp4,1);
makeFigureBig(h);

sp5 = subplot(235);
overlayImages2(aSag.',roiSag.',[],[0.1,1],ay,az,sp5,1);
makeFigureBig(h);

sp6 = subplot(236);
overlayImages2(aAx,roiAx,[],[0.1,1],ay,ax,sp6,1);
makeFigureBig(h);
set(h,'position',[1          41        1920         963])

%% Show temperature over time
h = figure;
tTimeAvg = zeros(1,size(tInterp,4));
tTimeMax = zeros(1,size(tInterp,4));
for ii = 1:size(tInterp,4)
    curT = tInterp(:,:,:,ii);
    tTimeAvg(ii) = mean(curT(roi));
    tTimeMax(ii) = max(curT(roi));
end

subplot(121)
plot(1:size(tInterp,4),tTimeAvg,'-',1:size(tInterp,4),tTimeMax,'--','linewidth',2)
legend('Mean','Max','location','northwest');
xlabel('Dynamic')
ylabel('Temperature (degrees)')
title('Temperature Over Time')
grid on
makeFigureBig(h);

subplot(122)
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
pos = get(h,'position');
set(h,'position',[pos(1),pos(2),2*pos(3),pos(4)]);