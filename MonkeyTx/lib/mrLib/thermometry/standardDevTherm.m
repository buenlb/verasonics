function [temporal, spatial, mgImg] = standardDevTherm(sys,sonicationNo)
%% Temporal Standard Deviation
[T,~,mgImg,tx,ty,tz,phHeader] = loadTemperatureSonication(sys,sonicationNo);
temporalTherm = std(T,[],4);
nSlices = howManySlices(phHeader);

% Interpolate temperature data onto anatomical data
ax = sys.ax;
ay = sys.ay;
az = sys.az;
[tY,tX,tZ] = meshgrid(ty,tx,tz);
[aY,aX,aZ] = meshgrid(ay,ax,az);
temporal = interp3(tY,tX,tZ,temporalTherm,aY,aX,aZ);
mgImg = interp3(tY,tX,tZ,mgImg,aY,aX,aZ);
%% Spatial Standard Deviation
[~,sliceDim] = min(size(temporalTherm));
dims = 1:3;
dims = dims(dims~=sliceDim);

spatial = zeros(size(temporalTherm));
window = 3;
dynamics = 6;
for ii = (window+1):(size(T,dims(1))-(window+1))
    disp(['Row ', num2str(ii), ' of ', num2str(size(T,1))])
    for jj = (window+1):(size(T,dims(2))-(window+1))
        if sliceDim == 3
            xIdx = (ii-window):(ii+window);
            yIdx = (jj-window):(jj+window);
            zIdx = 1:size(T,3);
            spatial(ii,jj,:) = squeeze(std((std(mean(T(xIdx,yIdx,zIdx,dynamics),4),[],1)),[],2));
        elseif sliceDim == 2
            xIdx = (ii-window):(ii+window);
            yIdx = 1:size(T,2);
            zIdx = (jj-window):(jj+window);
            spatial(ii,:,jj) = squeeze(std((std(mean(T(xIdx,yIdx,zIdx,dynamics),4),[],1)),[],3));
        elseif sliceDim == 1
            xIdx = 1:size(T,1);
            yIdx = (ii-window):(ii+window);
            zIdx = (jj-window):(jj+window);
            spatial(:,ii,jj) = squeeze(std((std(mean(T(xIdx,yIdx,zIdx,dynamics),4),[],2)),[],3));
        end        
    end
end
spatial = interp3(tY,tX,tZ,spatial,aY,aX,aZ);
%% Display the results
% nSlices = howManySlices(phHeader);
% stdSys.ax = tx;
% stdSys.ay = ty;
% stdSys.az = tz;
% stdSys.ux = tx;
% stdSys.uy = ty;
% stdSys.uz = tz;
% stdSys.aImg = mgImg(:,:,1:nSlices);
% stdSys.tInterp = spatial;
% stdSys.tWindow = [0,2];
% stdSys.dynamic = 1;
% 
% [~,fSpot(1)] = min(abs(sys.tx-sys.focalSpotMr(1)));
% [~,fSpot(2)] = min(abs(sys.ty-sys.focalSpotMr(2)));
% [~,fSpot(3)] = min(abs(sys.tz-sys.focalSpotMr(3)));
% 
% stdSys.focalSpotIdx = fSpot;
% stdSys.xyzAxes = [tx(1),tx(end);ty(1),ty(end);tz(1),tz(end)];
% stdSys.txCenterIdx = [0,0,0];
% 
% stdSys = draw3dTempOverlay(stdSys,[0,5],1);
% orthogonalTemperatureViewsGui(stdSys);