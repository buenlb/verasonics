function slice = loopThroughImage(img,dim,res,range,h)

if ~exist('range','var')
    range = [];
end
if ~exist('res','var')
    res = [1,1,1];
end

if ~exist('h','var')
    h = figure;
end
figure(h);
img = shiftdim(img,dim-1);
sz = size(img);
res = circshift(res,[0,-(dim-1)]);
idx = ceil(size(img)/2);

% x = 0:res(1):res(1)*(sz(1)-1);
y = 0:res(2):res(2)*(sz(2)-1);
z = 0:res(3):res(3)*(sz(3)-1);

idx = idx(1);

imshow(squeeze(img(idx,:,:)),range,'initialmagnification','fit','xData',z,'yData',y)
title(num2str(idx));


while 1
    [~,~,button] = ginput(1);
    switch button
        case 30
            if idx < size(img,1)
                idx = idx+1;
            end
        case 31
            if idx > 1
                idx = idx-1;
            end
        case 28
            if idx > 1
                idx = idx-1;
            end
        case 29
            if idx < size(img,1)
                idx = idx+1;
            end
        case 27
            slice = idx;
            return;
    end
    imshow(squeeze(img(idx,:,:)),range,'initialmagnification','fit','xData',z,'yData',y)
    title(num2str(idx));
end