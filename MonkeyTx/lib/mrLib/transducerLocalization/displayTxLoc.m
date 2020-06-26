function tmplt3d = displayTxLoc(sys)
img = sys.aImg;
x = sys.ax;
y = sys.ay;
z = sys.az;
txCenter = sys.txCenterIdx;
theta = sys.txTheta;
res = sys.aRes;

%% Show images
tmplt3d = drawTransducer(size(img),txCenter,theta,res,1);
tmplt2d = sum(tmplt3d,3);
tmplt2d(tmplt2d > 1) = 1;
zDist = 9.03e-3;
zIdx = txCenter(3)+round(zDist/res(3));
img2d = squeeze(img(:,:,zIdx));
figure;
ax = gca;
overlayImages2(img2d',tmplt2d',[0,max(img2d(:))],[0,1],x,y,ax,0.4,'winter');

yIdx = txCenter(2);
img2d = squeeze(img(:,yIdx,:));
tmplt2d = squeeze(tmplt3d(:,round(yIdx),:));
figure;
ax = gca;
overlayImages2(img2d',tmplt2d',[0,max(img2d(:))],[0,1],x,z,ax,0.4,'winter');
axis('equal')

%% Print location in MR coordinates
if sys.txCenter(1) > 0
    xLabel = 'left';
else
    xLabel = 'right';
end

if sys.txCenter(2) > 0
    yLabel = 'head';
else
    yLabel = 'foot';
end

if sys.txCenter(1) > 0
    zLabel = 'posterior';
else
    zLabel = 'anterior';
end
disp(['Tx is located at ', num2str(sys.txCenter(1)*1e3,3), 'mm ', xLabel,...
        ', ', num2str(sys.txCenter(2)*1e3,3), 'mm ',  yLabel,...
        ', ', num2str(sys.txCenter(3)*1e3,3), 'mm ',  zLabel]);