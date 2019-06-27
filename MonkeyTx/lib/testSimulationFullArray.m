clear; clc; close all;
% Unit test for simulation code
f = 680e3;
lambda = 1540/f;
gridMax = 80e-3;

[~,x,y,z] = transducerGeometry(0);

elements.x = x*1e-3;
elements.y = y*1e-3;
elements.z = z*1e-3;
elements.phi = zeros(size(x));
elements.p = ones(size(x));

x = linspace(-max(elements.x)/2,max(elements.x)/2,256);
y = 0;
z = linspace(max(elements.z),max(elements.z)+gridMax,256);
[X,Y,Z] = ndgrid(x,y,z);
% grid.X = X(:,50,:);
% grid.Y = Y(:,50,:);
% grid.Z = Z(:,50,:);

grid.X = X;
grid.Y = Y;
grid.Z = Z;

%% Show simulation grid
figure
plot3(grid.X(:),grid.Y(:),grid.Z(:),'.')
hold on
plot3(elements.x,elements.y,elements.z,'*')
axis('equal')
xlabel('x');
ylabel('y');
zlabel('z');
legend('Simulation points', 'Element Locations')

%% Simulate
p = simulateArray(elements,f,grid);

%% Plot Results
figure;
imshow(squeeze(abs(p)),[]);
colorbar

figure
pThresholded = p;
pThresholded(abs(p)<0.5*max((abs(p(:))))) = 0;
imshow(squeeze(abs(pThresholded)),[]);

%% Simulate with steering
focus = [6e-3,0,60e-3];
elements = steerArray(elements,focus,f);

%% Simulate
p = simulateArray(elements,f,grid);

%% Plot Results
figure;
imshow(squeeze(abs(p)),[]);
colorbar

figure
pThresholded = p;
pThresholded(abs(p)<0.5*max((abs(p(:))))) = 0;
imshow(squeeze(abs(pThresholded)),[]);