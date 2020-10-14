function [T,phImg,mgImg,tx,ty,tz,phHeader,mgHeader,treatmentTime] = loadTemperatureSonication(sys,sonicationNo)
%% Load Images
[phImg,phHeader] = loadDicomDir([sys.mrPath,num2str(sys.sonication(sonicationNo).phaseSeriesNo,'%03d')]);
[mgImg,mgHeader] = loadDicomDir([sys.mrPath,num2str(sys.sonication(sonicationNo).magSeriesNo,'%03d')]);

% phImg(mgImg<30) = 0;
nSlices = howManySlices(phHeader);
treatmentTime = findAcquisitionTime(phHeader);

%% Put images in system coordinates
[tx,tz,ty,~,tDimOrder] = findMrCoordinates(phHeader(nSlices+1:2*nSlices));
dimOrderTx = [tDimOrder(1),tDimOrder(3),tDimOrder(2)];
tSys = sys;
tSys.img = phImg;
tSys.path = [sys.mrPath,num2str(sys.sonication(sonicationNo).phaseSeriesNo,'%03d')];
tSys.imgHeader = phHeader{nSlices+1};
T = getTemperatureSeimens(tSys,nSlices,0);
phImg = permute(phImg,dimOrderTx);
mgImg = mgImg(:,:,1:nSlices);
mgImg = permute(mgImg,dimOrderTx);
T = permute(T,[dimOrderTx,4]);

tx = tx*1e-3;
ty = ty*1e-3;
tz = tz*1e-3;

% Get the direction of axes correct. Note that increasing ax, ay, or az
% means decreasing ux, uy, or uz. Therefore it is a positively oriented
% anatomical axis that results in a reversing of the ultrasound axis.
if tx(2)-tx(1) > 0
    phImg = phImg(end:-1:1,:,:);
    mgImg = mgImg(end:-1:1,:,:);
    T = T(end:-1:1,:,:,:);
    tx = tx(end:-1:1);
end
if ty(2)-ty(1) > 0 
    phImg = phImg(:,end:-1:1,:);
    mgImg = mgImg(:,end:-1:1,:);
    T = T(:,end:-1:1,:,:);
    ty = ty(end:-1:1);
end
if tz(2)-tz(1) > 0 
    phImg = phImg(:,:,end:-1:1);
    mgImg = mgImg(:,:,end:-1:1);
    T = T(:,:,end:-1:1,:);
    tz = tz(end:-1:1);
end

if sys.invertTx
    warning('Inverting Tx!')
    phImg = phImg(:,:,end:-1:1);
    mgImg = mgImg(:,:,end:-1:1);
    T = T(:,:,end:-1:1,:);
    tz = tz(end:-1:1);

    phImg = phImg(end:-1:1,:,:);
    mgImg = mgImg(end:-1:1,:,:);
    T = T(end:-1:1,:,:,:);
    tx = tx(end:-1:1);
end