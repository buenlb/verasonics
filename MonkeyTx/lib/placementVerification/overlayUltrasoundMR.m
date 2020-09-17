function overlayUltrasoundMR(sys)

data = load(['C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20200910\UltrasoundData\',...
    sys.couplingFile]);
gImg = data.griddedElRaw;

[usImg,xa,ya,za] = griddedElementBModeImage(gImg.RcvData,gImg.Receive);
xa = xa*1e-3;
ya = ya*1e-3;
za = za*1e-3;

[YA,XA,ZA] = meshgrid(ya,xa,za);
[YM,XM,ZM] = meshgrid(sys.uy,sys.ux,sys.uz);

usImgInterp = interp3(YA,XA,ZA,usImg,YM,XM,ZM);
[~,yIdx] = min(abs(sys.uy));
overlayImages2(squeeze(sys.aImg(:,yIdx,:)).',squeeze(usImgInterp(:,yIdx,:)).',...
    [],[0*1/20*max(usImgInterp(:)),max(usImgInterp(:))],sys.ux,sys.uz,[],0.8);