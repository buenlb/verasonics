function visualizeThermometry(sys,window,tWindow)
if nargin < 3
    tWindow = [0,3];
end

if length(tWindow)~=2
    error('tWindow must be a 2 element vector.')
end

img = sys.img;
res = sys.res;

xAx = [0,res(1)*(size(img,1)-1)];
yAx = [0,res(2)*(size(img,2)-1)];
zAx = [0,res(3)*(sys.nSlices-1)];

x = linspace(xAx(1),xAx(2),size(img,1));
y = linspace(yAx(1),yAx(2),size(img,2));
z = linspace(zAx(1),zAx(2),sys.nSlices);

sys.xyzAxes = [xAx;yAx;zAx];
sys.x = x;
sys.y = y;
sys.z = z;
sys.window = tWindow;

[T,treatmentTime] = getTemperatureSeimens(sys,0);

guiSys = sys;
guiSys.img = T;
waitfor(selectRegion(guiSys));
estimatedCenter = load('guiFileOutput');
delete('guiFileOutput.mat')
regionCenter = estimatedCenter.txCenter;

x = x-x(regionCenter(1));
y = y-y(regionCenter(2));
z = z-z(regionCenter(3));

[Y,X,Z] = meshgrid(y,x,z);
R = sqrt(X.^2+Y.^2+Z.^2);
roi = zeros(size(R));
roi(R<=window) = 1;

for ii = 2:size(T,4)
    tmp = squeeze(T(:,:,:,ii));
    avgT(ii-1) = mean(tmp(logical(roi)));
    maxT(ii-1) = max(tmp(logical(roi)));
    
    stdT(ii-1) = std(tmp(logical(roi)));
    
    fullTmp = zeros(size(squeeze(T(:,:,:,ii))));
    fullTmp(logical(roi)) = tmp(logical(roi));
    [~,mxVox(ii-1)] = max(fullTmp(:));
end
[~,mxIdx] = max(maxT);
mxVx = mxVox(mxIdx);
[mxA,mxB,mxC] = ind2sub(size(Z),mxVx);

stdTemporal = std(T,[],4);
stdTemporalAvg = mean(stdTemporal(logical(roi)));

h = figure;
subplot(221)
plot(1:length(avgT),avgT,1:length(avgT),maxT,'linewidth',2)
legend('Average', 'Max')
xlabel('Image Number')
ylabel('Temperature (C)')
grid on
makeFigureBig(h);

subplot(222)
plot(x,T(:,mxB,mxC,mxIdx),'linewidth',2)
hold on
plot(y,T(mxA,:,mxC,mxIdx),'linewidth',2)
% axis([min([x(mxA)-2*window,y(mxB)+2*window]),max([x(mxA)+2*window,y(mxB)+2*window]),0,20])
xlim([min([x(mxA)-2*window,y(mxB)+2*window]),max([x(mxA)+2*window,y(mxB)+2*window])]);
legend('x','y');
xlabel('Distance from ROI Center')
ylabel('Temperature (C)')
title('x,y Cuts through focus')
grid on
makeFigureBig(h);

subplot(223)
plot(z,squeeze(T(mxA,mxB,:,mxIdx)),'linewidth',2)
% axis([z(mxC)-2*window,z(mxC)+2*window,0,20])
xlim([z(mxC)-2*window,z(mxC)+2*window])
xlabel('Distance from ROI Center')
ylabel('Temperature (C)')
title('z cut through focus');
grid on
makeFigureBig(h)

subplot(224)
ax = gca;
bar(1:2,[mean(stdT),stdTemporalAvg])
ax.XTickLabel = {'Spatial Std','Temporal Std'};
axis('tight')
grid on
makeFigureBig(h)
pos = get(h,'position');
set(h,'position',[0,0,2*pos(3),2*pos(4)]);


h = figure;
subplot(121)
imagesc(x,y,T(:,:,mxC,mxIdx).',[0,max(maxT)])
xlabel('x')
ylabel('y')
title('Focal Image')

subplot(122)
imagesc(x,y,T(:,:,mxC,mxIdx).',[0,max(maxT)])
axis([-window,window,-window,window])
xlabel('x')
ylabel('y')
title('Zoomed In')
colorbar
pos = get(h,'position');
set(h,'position',[pos(1),pos(2),2*pos(3),pos(4)]);
