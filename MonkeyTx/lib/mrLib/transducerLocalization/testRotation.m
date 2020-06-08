x = [-1,-1,1,1,1,-1,-1,1,1,1,1,1,1,-1,-1,1,-1,-1];
y = [-1,1,1,-1,-1,-1,-1,-1,1,1,-1,-1,1,1,1,1,1,-1];
z = [1,1,1,1,-1,-1,1,1,1,-1,-1,1,1,1,-1,-1,-1,-1];

theta = 0*pi/180;
phi = 45*pi/180;

[xr,yr,zr] = rotation3D(x,y,z,theta,phi);

theta = 45*pi/180;
phi = 45*pi/180;

[xr2,yr2,zr2] = rotation3D(x,y,z,theta,phi);

figure
plot3(x,y,z,'-o','linewidth',2)
hold on
plot3(xr,yr,zr,'-*','linewidth',2)
plot3(xr2,yr2,zr2,'-^','linewidth',2)
% Visualize axes
plot3([0,0],[0,0],[-2,2],'k--')
plot3([-2,2],[0,0],[0,0],'k--')
plot3([0,0],[-2,2],[0,0],'k--')
xlabel('x')
ylabel('y')
zlabel('z')
axis(2*[-1,1,-1,1,-1,1])

