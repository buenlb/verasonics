for ii = 1:size(sys.aImg,2)
    tmp = sys.tMagImgInterp(:,ii,:);
    if sum(tmp(:))
        overlayImages2(squeeze(sys.aImg(:,ii,:)),...
            squeeze(sys.tMagImgInterp(:,ii,:)),...
            [],[0,0.5*max(sys.tMagImgInterp(:))])
    end
end