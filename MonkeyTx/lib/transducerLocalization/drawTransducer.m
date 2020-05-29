function img = drawTransducer(imgSz,txLoc,txAngle,res)
%% Fiducial characteristics (locations relative to center of transducer)
xDist = (172/2)*1e-3;
yDist = (35/2)*1e-3;

%% Create image
[~,img] = createFiducialTemplate(xDist,yDist,res,'vitE',txAngle,txLoc,imgSz);

trans = transducerGeometry(0);

x = 0:res(1):((size(img,1)-1)*res(1));
y = 0:res(2):((size(img,2)-1)*res(2));
z = 0:res(3):((size(img,3)-1)*res(3));

x = x-x(txLoc(1));
y = y-y(txLoc(2));
z = z-z(txLoc(3));

xTx = trans.ElementPos(:,1)*1e-3;%+x(txLoc(1));
yTx = trans.ElementPos(:,2)*1e-3;%+y(txLoc(2));
zTx = trans.ElementPos(:,3)*1e-3;%+z(txLoc(3));

[Y,X,Z] = meshgrid(y,x,z);

disp('  Drawing Transducer:' )
tic
[xTxMr,yTxMr,zTxMr] = array2MrCoords(xTx,yTx,zTx,[x(txLoc(1)),y(txLoc(2)),z(txLoc(3)),txAngle]);
elWidth = 5e-3;
d = waitbar(0,'Painting Transducer');
for ii = 1:length(xTx)
    waitbar((ii-1)/length(xTx),d,['Element ', num2str(ii), ' of ', num2str(length(xTx))]);
    [~,idx] = min((X(:)-xTxMr(ii)).^2+(Y(:)-yTxMr(ii)).^2+(Z(:)-zTxMr(ii)).^2);
    [xIdx,yIdx,zIdx] = ind2sub(size(img),idx);
    wdwLength = ceil(elWidth/res(1));
    curYidx = yIdx-2*floor(wdwLength/2):yIdx+2*floor(wdwLength/2);
    if ~mod(wdwLength,2)
        wdwLength = wdwLength+1;
    end
    for jj = 1:wdwLength
        curZ = z(zIdx);
        curZ = curZ-sin(trans.ElementPos(ii,4))*res(1)*(jj-ceil(wdwLength/2));

        curXidx = xIdx+(jj-ceil(wdwLength/2));
        
        [~,curZidx] = min(abs(z-curZ));
        img(curXidx,curYidx,curZidx) = 1;
    end
end
close(d);
toc