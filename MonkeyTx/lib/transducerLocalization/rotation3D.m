function [xr,yr,zr] = rotation3D(x,y,z,theta,phi)

% Check Inputs
if length(x) ~= length(y) || length(x) ~= length(z)
    error('x, y, and z must be the same length!')
end

%% First rotate by phi around the z axis.
rz = [cos(thetaZ),-sin(thetaZ),0;sin(thetaZ),cos(thetaZ),0;0,0,1];

%% Now rotate 
% thetaX = acos(cos(theta)/sqrt(sin(theta)^2*sin(phi)^2+cos(theta)^2))
% thetaY = -acos(cos(theta)/sqrt(sin(theta)^2*cos(phi)^2+cos(theta)^2))
% thetaZ = phi
% 
% thetaZ = 45*pi/180;
% thetaY = 45*pi/180;
% thetaX = 45*pi/180;
% 
% rx = [1,0,0;0,cos(thetaX),-sin(thetaX);0,sin(thetaX),cos(thetaX)];
% ry = [cos(thetaY),0,-sin(thetaY);0,1,0;sin(thetaY),0,cos(thetaY)];
% rz = [cos(thetaZ),-sin(thetaZ),0;sin(thetaZ),cos(thetaZ),0;0,0,1];
% 
% xr = zeros(size(x));
% yr = zeros(size(x));
% zr = zeros(size(x));
% for ii = 1:length(x)
%     v = [x(ii);y(ii);z(ii)];
%     vR = rx*ry*rz*v;
%     xr(ii) = vR(1);
%     yr(ii) = vR(2);
%     zr(ii) = vR(3);
% end