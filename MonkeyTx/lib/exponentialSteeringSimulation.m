function [p,x,y,z] = exponentialSteeringSimulation(target,frequency)
Trans = transducerGeometry(0);
Trans.frequency = frequency;

xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

elements.x = xTx*1e-3;
elements.y = yTx*1e-3;
elements.z = zTx*1e-3;

if isempty(target)
%     elements.phi = randn(size(elements.x))*pi;
    load('D:\Task\randomPhases.mat');
    elements.phi = phs;
else
    elements = steerArray(elements,target*1e-3,frequency);
end

dx = 0.5e-3;

x = min(elements.x):dx:max(elements.x);
y = min(elements.y):dx:max(elements.y);
z = 0:dx:0.08;

[X,Y,Z] = ndgrid(x,y,z);

% Material constants
c = 1540;
w = 2*pi*frequency*1e6;
k = w/c;

% figure
p = zeros(size(X));
for ii = 1:length(elements.x)
    R = sqrt((X-elements.x(ii)).^2+(Y-elements.y(ii)).^2+(Z-elements.z(ii)).^2);
%     field = exp(-1j*k*R);
%     imshow(real(squeeze(field(:,29,:)))',[]);
%     drawnow
    p = exp(-1j*(k*R+elements.phi(ii))) + p;
end
