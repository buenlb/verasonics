% This code compares two ultrasound acquired images of the skull to
% determine if the transducer is in the same place
function compareSkullImages(img1, img2, xa, ya, za)
Trans = transducerGeometry(0);
h = figure;
yFrames = unique(Trans.ElementPos(:,2));
rows = floor(sqrt(length(yFrames)));
cols = ceil(sqrt(length(yFrames)));
if rows*cols < length(yFrames)
    cols = cols+1;
end

h = figure;

for ii = 1:rows*cols
    sp = subplot(rows,cols,ii);
    [~,yIdx] = min(abs(ya-yFrames(ii)));
    imshowpair(squeeze(img1(:,yIdx,:)),squeeze(img2(:,yIdx,:)));
%     imshow(squeeze(img1(:,yIdx,:)),[])
    title(['y=',num2str(ya(yIdx))]);
    drawnow
    sp.Visible = 'on';
    set(h,'position',[1         -79        1920        1083]);
end
drawnow