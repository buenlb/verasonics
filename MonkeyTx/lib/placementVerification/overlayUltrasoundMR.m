function overlayUltrasoundMR(sys)

data = load(sys.couplingFile);
gImg = data.griddedElRaw;

[usImg,xa,ya,za] = griddedElementBModeImage(gImg.RcvData,gImg.Receive);
xa = xa*1e-3;
ya = ya*1e-3;
za = za*1e-3;

usImg = log10(usImg);

elements = transducerGeometry(0);
% h = figure;
% set(h,'position',[1         161        1920         963]);
% h2 = figure;
% set(h2,'position',[1         161        1920         963]);
% 
% % These images were produced with grids of elements so there won't be data
% % at the edges of the array. Find where we expect data.
% yFrames = unique(elements.ElementPos(:,2))*1e-3;
% yFrames = yFrames(2:end-1);
% width = 0.30;
% height = 0.45;

[YA,XA,ZA] = meshgrid(ya,xa,za);
[YM,XM,ZM] = meshgrid(sys.uy,sys.ux,sys.uz);

usImgInterp = interp3(YA,XA,ZA,usImg,YM,XM,ZM);
usImgInterp(sys.txImg>0) = max(usImgInterp(:));

ov = figure;
subplot(121)
[~,yIdx] = min(abs(sys.uy));
overlayImages2(squeeze(sys.aImg(:,yIdx,:)).',squeeze(usImgInterp(:,yIdx,:)).',...
        [0,1/2*max(sys.aImg(:))],[1.5/2*max(usImg(:)),max(usImg(:))],sys.ux,sys.uz,[],0.5);
title('Coronal')

subplot(122)
[~,xIdx] = min(abs(sys.ux));
overlayImages2(squeeze(sys.aImg(xIdx,:,:)).',squeeze(usImgInterp(xIdx,:,:)).',...
        [0,1/2*max(sys.aImg(:))],[1.5/2*max(usImg(:)),max(usImg(:))],sys.uy,sys.uz,[],0.5);
title('Sagittal')    
% 
% subplot(223)
% [~,zIdx] = min(abs(sys.uz-40e-3));
% overlayImages2(squeeze(sys.aImg(:,:,zIdx)).',squeeze(usImgInterp(:,:,zIdx)).',...
%         [0,1*max(sys.aImg(:))],[1.5/2*max(usImg(:)),max(usImg(:))],sys.ux,sys.uy,[],0.3);
% title('Axial (z=40)')
%     
% subplot(224)
% [~,zIdx] = min(abs(sys.uz-50e-3));
% overlayImages2(squeeze(sys.aImg(:,:,zIdx)).',squeeze(usImgInterp(:,:,zIdx)).',...
%         [0,1*max(sys.aImg(:))],[1.5/2*max(usImg(:)),max(usImg(:))],sys.ux,sys.uy,[],0.3);
% title('Axial (z=50)')
set(ov,'position',[1         161        1920         963]);
makeFigureBig(ov);

% for ii = 1:length(yFrames)
%     figure(h)
%     if ii < 4
%         sp(ii) = axes('Position',[(ii-1)*width,0.5,width,height]);
%     else
%         sp(ii) = axes('Position',[(ii-4)*width,0,width,height]);
%     end
%     [~,yIdx] = min(abs(sys.uy-yFrames(ii)));
%     curImg = squeeze(usImgInterp(:,yIdx-1,:)).';
%     overlayImages2(squeeze(sys.aImg(:,yIdx-1,:)).',curImg,...
%         [0,1*max(sys.aImg(:))],[1.5/2*max(usImg(:)),max(usImg(:))],sys.ux,sys.uz,[],0.3);
%     axis('equal')
%     axis('tight')
%     makeFigureBig(h);
%     
%     figure(h2)
%     if ii < 4
%         sp2(ii) = axes('Position',[(ii-1)*width,0.5,width,height]);
%     else
%         sp2(ii) = axes('Position',[(ii-4)*width,0,width,height]);
%     end
%     [~,yIdx] = min(abs(sys.uy-yFrames(ii)));
%     imshow(squeeze(sys.aImg(:,yIdx-1,:)).',[]);
%     hold all
%     contour(sp2(ii),curImg,1,'w');
%     axis('equal')
%     axis('tight')
%     makeFigureBig(h2);
% end
% 
% figure
% [~,yIdx] = min(abs(sys.uy));
% curImg = exp(squeeze(usImgInterp(:,yIdx,:)).');
% overlayImages2(squeeze(sys.aImg(:,yIdx,:)).',curImg,...
%         [0,1*max(sys.aImg(:))],[1/10*max(exp(usImg(:))),max(exp(usImg(:)))],sys.ux,sys.uz,[],0.8);