
function imgSpace_griddedImage(Resource,Trans,gridSize,focX,focY,focZ)
blocks = selectElementBlocks(gridSize);

Xa = Resource.Parameters.Xa;
Ya = Resource.Parameters.Ya;
Za = Resource.Parameters.Za;

xa = squeeze(Xa(:,1,1));
ya = squeeze(Ya(1,:,1));
za = squeeze(Za(1,1,:));

imgAvg = zeros(size(Xa));
%% Process Data
idx = 1;
for hh = 1:length(blocks)
    curBlock = blocks{hh};
    centerElementPos = Trans.ElementPos(curBlock(ceil(gridSize^2/2)),:);
    clear img;
    for ii = 1:length(focX)
        for jj = 1:length(focY)
            for kk = 1:length(focZ)
                % Find the correct delays
                img(ii,jj,kk) = 1;
                Xe(ii,jj,kk) = focX(ii);
                Ye(ii,jj,kk) = focY(jj);
                Ze(ii,jj,kk) = focZ(kk);
            end
        end
    end
    % Put the result in array space and add it to the img
    [Xar,Yar,Zar] = array2elementCoords(Xa,Ya,Za,centerElementPos);
    try
    img = interp3(Ye,Xe,Ze,img,Yar,Xar,Zar,'spline',0);
    catch
        keyboard
    end

    tmp = zeros(size(imgAvg));
    tmp(img ~= 0) = 1;
    imgAvg = imgAvg+tmp;
end
h = figure();
clf
rows = 5;
cols = 5;
nY = length(ya)/(rows*cols);
idx = 1;
for ii = 1:ceil(nY)
    h(ii) = figure;
    for jj = 1:rows*cols
        subplot(rows,cols,jj)
        imagesc(za,xa,squeeze(imgAvg(:,idx,:)),[0,max(imgAvg(:))]);
        title(['y=',num2str(ya(idx))]);
        axis('equal')
        colorbar
        drawnow
        idx = idx+1;
        if idx > length(ya)
            break;
        end
    end
    set(h(ii),'position',[1          41        1920        1083]);
    drawnow
end