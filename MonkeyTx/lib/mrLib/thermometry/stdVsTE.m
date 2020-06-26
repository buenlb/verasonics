% This script characterizes temperature std with TE
clear all; close all; clc;
paths = {'C:\Users\Taylor\Documents\Data\MR\Thermometry\phantom_20200623\s000031 seg_EPI3D_HIFU2_ETL5_TR25_TE13_stdTest',...
         'C:\Users\Taylor\Documents\Data\MR\Thermometry\phantom_20200623\s000033 seg_EPI3D_HIFU2_ETL5_TR25_TE12_stdTest',...
         'C:\Users\Taylor\Documents\Data\MR\Thermometry\phantom_20200623\s000035 seg_EPI3D_HIFU2_ETL5_TR25_TE11_stdTest',...
         'C:\Users\Taylor\Documents\Data\MR\Thermometry\phantom_20200623\s000037 seg_EPI3D_HIFU2_ETL5_TR25_TE10_stdTest',...
         'C:\Users\Taylor\Documents\Data\MR\Thermometry\phantom_20200623\s000039 seg_EPI3D_HIFU2_ETL5_TR25_TE9p6_stdTest'};
     
te = [13,12,11,10,9.6];
window = 3;
     
for ii = 1:length(paths)
    sys.path = paths{ii};
    sys.baseline = 1;
    sys.nSlices = 8;
    [img,header] = loadDicomDir(sys.path);
    
    sys.img = img;
    
    res(1) = double(header{1}.PixelSpacing(1));
    res(2) = double(header{1}.PixelSpacing(1));
    res(3) = header{1}.SliceThickness;
    sys.res = res;
    sys.imgHeader = header{1};
    
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
    
    % High SNR
    regionCenter = [79,91,4];
    
    x1 = x-x(regionCenter(1));
    y1 = y-y(regionCenter(2));
    z1 = z-z(regionCenter(3));

    [Y,X,Z] = meshgrid(y1,x1,z1);
    R = sqrt(X.^2+Y.^2+Z.^2);
    roiHighSnr = zeros(size(R));
    roiHighSnr(R<=window) = 1;
    
    % Low SNR
    regionCenter = [63,77,4];
    
    x1 = x-x(regionCenter(1));
    y1 = y-y(regionCenter(2));
    z1 = z-z(regionCenter(3));

    [Y,X,Z] = meshgrid(y1,x1,z1);
    R = sqrt(X.^2+Y.^2+Z.^2);
    roiLowSnr = zeros(size(R));
    roiLowSnr(R<=window) = 1;

    % Low SNR
    T = getTemperatureSeimens(sys,0);
    for jj = 2:size(T,4)
        tmp = squeeze(T(:,:,:,jj));
        avgT(jj-1) = mean(tmp(logical(roiLowSnr)));
        maxT(jj-1) = max(tmp(logical(roiLowSnr)));

        stdT(jj-1) = std(tmp(logical(roiLowSnr)));

        fullTmp = zeros(size(squeeze(T(:,:,:,jj))));
        fullTmp(logical(roiLowSnr)) = tmp(logical(roiLowSnr));
        [~,mxVox(jj-1)] = max(fullTmp(:));
    end
    spatialStdLowSnr(ii) = mean(stdT);
    
    stdTemporal = std(T,[],4);
    temporalStdLowSnr(ii) = mean(stdTemporal(logical(roiLowSnr)));
    
    % High SNR
    for jj = 2:size(T,4)
        tmp = squeeze(T(:,:,:,jj));
        avgT(jj-1) = mean(tmp(logical(roiHighSnr)));
        maxT(jj-1) = max(tmp(logical(roiHighSnr)));

        stdT(jj-1) = std(tmp(logical(roiHighSnr)));

        fullTmp = zeros(size(squeeze(T(:,:,:,jj))));
        fullTmp(logical(roiHighSnr)) = tmp(logical(roiHighSnr));
        [~,mxVox(jj-1)] = max(fullTmp(:));
    end
    spatialStdhighSnr(ii) = mean(stdT);
    
    stdTemporal = std(T,[],4);
    temporalStdHighSnr(ii) = mean(stdTemporal(logical(roiHighSnr)));
end

%%
h = figure;
ax = gca;
plot(te,spatialStdhighSnr,'--',te,temporalStdHighSnr,'-','Color',ax.ColorOrder(1,:),'linewidth',2);
hold on
plot(te,spatialStdLowSnr,'--',te,temporalStdLowSnr,'-','Color',ax.ColorOrder(2,:),'linewidth',2);
legend('Spatial Std, High SNR', 'Temporal Std, High SNR', 'Spatial Std, Low SNR', 'Temporal Std, Low SNR','location','northwest')
xlabel('TE (ms)');
ylabel('Standard Deviation (^\circ C)');
grid on;
makeFigureBig(h);