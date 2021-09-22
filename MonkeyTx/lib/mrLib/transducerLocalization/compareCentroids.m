function [meanErr,err1,err2,err3] = compareCentroids(aImg,txCenter,theta,res,xDist,yDist,zDist)

fidLoc = zeros(3,3);
fidLoc(:,3) = round(zDist/res(3)+txCenter(3));
fidLoc(1,1) = round(txCenter(1)-xDist/res(1)*cos(theta));
fidLoc(1,2) = round(txCenter(2)-xDist/res(2)*sin(theta));
fidLoc(2,1) = round(txCenter(1)+xDist/res(1)+xDist/res(1)*sin(theta));
fidLoc(2,2) = round(txCenter(2)+yDist/res(2)*cos(theta));
fidLoc(3,1) = round(txCenter(1)+xDist/res(1)-xDist/res(1)*sin(theta));
fidLoc(3,2) = round(txCenter(2)-yDist/res(2)*cos(theta));

wSize = [14,8,30];

fd1 = aImg((fidLoc(1,1)-wSize(1)):(fidLoc(1,1)+wSize(1)),(fidLoc(1,2)-wSize(2)):(fidLoc(1,2)+wSize(2)),(fidLoc(1,3)-wSize(3)):(fidLoc(1,3)+wSize(3)));
fd2 = aImg((fidLoc(2,1)-wSize(1)):(fidLoc(2,1)+wSize(1)),(fidLoc(2,2)-wSize(2)):(fidLoc(2,2)+wSize(2)),(fidLoc(2,3)-wSize(3)):(fidLoc(2,3)+wSize(3)));
fd3 = aImg((fidLoc(3,1)-wSize(1)):(fidLoc(3,1)+wSize(1)),(fidLoc(3,2)-wSize(2)):(fidLoc(3,2)+wSize(2)),(fidLoc(3,3)-wSize(3)):(fidLoc(3,3)+wSize(3)));

fd1(fd1<2*mean(fd1(:))) = 0;
fd1(fd1>0) = 1;
fd2(fd2<2*mean(fd2(:))) = 0;
fd2(fd2>0) = 1;
fd3(fd3<2*mean(fd3(:))) = 0;
fd3(fd3>0) = 1;

c1 = regionprops(fd1,'centroid');
c1 = [c1.Centroid(2),c1.Centroid(1),c1.Centroid(3)];
c2 = regionprops(fd2,'centroid');
c2 = [c2.Centroid(2),c2.Centroid(1),c2.Centroid(3)];
c3 = regionprops(fd3,'centroid');
c3 = [c3.Centroid(2),c3.Centroid(1),c3.Centroid(3)];

c1 = fidLoc(1,:)-wSize+1+c1;
c2 = fidLoc(2,:)-wSize+1+c2;
c3 = fidLoc(3,:)-wSize+1+c3;

err1 = norm((c1-fidLoc(1,:)).*res);
err2 = norm((c2-fidLoc(2,:)).*res);
err3 = norm((c3-fidLoc(3,:)).*res);

meanErr = mean([err1,err2,err3]);