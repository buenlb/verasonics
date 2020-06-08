% tmp = zeros(size(img));
% 
% [~,tmplt,fd2] = createFiducialTemplate(xDist,yDist,res,'vitE',7*pi/180);
% tmp(xSearch(lags{idx}(1)):(xSearch(lags{idx}(1))+size(tmplt,1)-1),...
%     ySearch(lags{idx}(2)):(ySearch(lags{idx}(2))+size(tmplt,2)-1),...
%     zSearch(lags{idx}(3)):(zSearch(lags{idx}(3))+size(tmplt,3)-1)) = tmplt;

% [~,tmp,fd1] = createFiducialTemplate(xDist,yDist,res,'vitE',7*pi/180,[200,50,50],size(img));
% [~,tmp,fd2] = createFiducialTemplate(xDist,yDist,res,'vitE',7*pi/180);

x = 0:res(1):((size(img,1)-1)*res(1));
y = 0:res(2):((size(img,2)-1)*res(2));
z = 0:res(3):((size(img,3)-1)*res(3));

colorImg = drawTransducerColor(img,tmplt3d);

sys.colorImg = colorImg;
sys.res = res;
sys.xyzAxes = [0,res(1)*(size(img,1)-1);...
                0,res(2)*(size(img,2)-1);...
                0,res(3)*(size(img,3)-1);];
sys.img = img;
sys.centerIdx = txCenter;
sys.x = x;
sys.y = y;
sys.z = z;

selectFocusGui(sys)