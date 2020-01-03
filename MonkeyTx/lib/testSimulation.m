clc; close all;
% Unit test for simulation code
f = 680e3;
lambda = 1540/f;
gridMax = 30*lambda;

elements.x = zeros(1,5)+gridMax/2;
elements.y = [-1,-0.5,0,0.5,1]*lambda+gridMax/2;
elements.z = zeros(1,5);
elements.phi = zeros(1,5);
elements.p = ones(1,5);

x = linspace(0,gridMax,100);
y = linspace(0,gridMax,100);
z = linspace(10*lambda,gridMax,100);
[X,Y,Z] = ndgrid(x,y,z);
grid.X = X;
grid.Y = Y;
grid.Z = Z;

p = simulateArray(elements,f,grid);

figure;
subplot(331)
imshow(squeeze(abs(X(50,:,:))),[])
subplot(332)
imshow(squeeze(abs(X(:,50,:))),[])
title('X')
subplot(333)
imshow(squeeze(abs(X(:,:,50))),[])

subplot(334)
imshow(squeeze(abs(Y(50,:,:))),[])
subplot(335)
imshow(squeeze(abs(Y(:,50,:))),[])
title('Y')
subplot(336)
imshow(squeeze(abs(Y(:,:,50))),[])

subplot(337)
imshow(squeeze(abs(Z(50,:,:))),[])
subplot(338)
imshow(squeeze(abs(Z(:,50,:))),[])
title('Z')
subplot(339)
imshow(squeeze(abs(Z(:,:,50))),[])

figure;
subplot(231)
imshow(squeeze(abs(p(50,:,:))),[])
xlabel('yz')
subplot(232)
imshow(squeeze(abs(p(:,50,:))),[])
title('Pressure without steering')
xlabel('xz')
subplot(233)
imshow(squeeze(abs(p(:,:,50))),[])
xlabel('xy')

[phi,elements] = steerArray(elements,[50,20,100],f);
% elements.phi = -phi;
p = simulateArray(elements,f,grid);

subplot(234)
imshow(squeeze(abs(p(50,:,:))),[])
xlabel('yz')
subplot(235)
imshow(squeeze(abs(p(:,50,:))),[])
xlabel('xz')
title('Pressure with steering')
subplot(236)
imshow(squeeze(abs(p(:,:,50))),[])
xlabel('xy')