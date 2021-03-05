% target = right.target;
% load('C:\Users\Taylor\Documents\Data\MR\Thermometry\20201014\Logs\NormalizedPositions\rightLGN');
% load('C:\Users\Taylor\Documents\Data\MR\Thermometry\20201014\rightLGN');
% load('C:\Users\Taylor\Documents\Data\MR\Thermometry\20201014\Logs\NormalizedPositions\rightLGN_deNoised.mat')
h1 = figure;
hold on
ax1 = gca;

h = figure;
hold on
ax = gca;

clear plt
for ii = 1:length(target)
    disp(['Sonication ', num2str(target(ii).sonNo)]);
    disp(['  Requested Focus: ', num2str(target(ii).sonication.focalSpot(1)), ', ',num2str(target(ii).sonication.focalSpot(2)), ', ',num2str(target(ii).sonication.focalSpot(3)), ', ']);
    disp(['  Center Of Mass: ', num2str(1e3*target(ii).cmUs(1),3), ', ',num2str(1e3*target(ii).cmUs(2),3), ', ',num2str(1e3*target(ii).cmUs(3),3), ', ']);
    disp(['  Voxel of Max Intensity: ', num2str(1e3*target(ii).maxUS2(1),3), ', ',num2str(1e3*target(ii).maxUS2(2),3), ', ',num2str(1e3*target(ii).maxUS2(3),3), ', ']);
    disp(['  Max Heating: ', num2str(target(ii).maxT2)])
    
    figure(h)
    ax.ColorOrderIndex = ii;
    plot3(1e3*target(ii).cmUs(1),1e3*target(ii).cmUs(2),1e3*target(ii).cmUs(3),'*','linewidth',2,'markersize',12)
    ax.ColorOrderIndex = ii;
    plot3(1e3*target(ii).maxUS(1),1e3*target(ii).maxUS(2),1e3*target(ii).maxUS(3),'^','linewidth',2,'markersize',12)
    
    clear x y z
    curSys = load(target(ii).logfile);
    for jj = 1:size(target(ii).st.PixelIdxList)
        [a,b,c] = ind2sub(size(target(ii).roi),target(ii).st.PixelIdxList(jj));
        x1 = target(ii).tx(a);
        y1 = target(ii).ty(b);
        z1 = target(ii).tz(c);
        
        tmp = thermometry2usCoords(curSys.sys,[x1,y1,z1]);
        x(jj) = tmp(1)*1e3;
        y(jj) = tmp(2)*1e3;
        z(jj) = tmp(3)*1e3;
    end
    
    figure(h1)
    ax1.ColorOrderIndex = ii;
    plt(ii) = plot3(x,y,z,'.','linewidth',2,'markersize',105);
    ax1.ColorOrderIndex = ii;
    plot3(1e3*target(ii).cmUs(1),1e3*target(ii).cmUs(2),1e3*target(ii).cmUs(3),'*','linewidth',2,'markersize',12)
    ax1.ColorOrderIndex = ii;
    plot3(1e3*target(ii).maxUS(1),1e3*target(ii).maxUS(2),1e3*target(ii).maxUS(3),'^','linewidth',2,'markersize',12)
    hold on
end
%%
figure(h)
plot3(-12,3,61,'kx','linewidth',3,'markersize',12)
xlabel('x (mm)')
ylabel('y (mm)')
zlabel('z (mm)')
makeFigureBig(h);

figure(h1)
% Plot the LGN
% curSys = load('C:\Users\Taylor\Documents\Data\MR\Thermometry\20201014\Logs\segmentedLGN\Euler1.mat');
curSys = load('C:\Users\Taylor\Documents\Data\MR\Thermometry\20201202\Logs\Euler_20201202.mat');
idx = find(curSys.sys.rightLgnRoi);
for ii = 1:length(idx)
    [a,b,c] = ind2sub(size(curSys.sys.aImg),idx(ii));
    
    x(ii) = curSys.sys.ux(a)*1e3;
    y(ii) = curSys.sys.uy(b)*1e3;
    z(ii) = curSys.sys.uz(c)*1e3;
end
plt(end+1) = plot3(x,y,z,'k.','linewidth',2,'markersize',105);

idx = find(curSys.sys.leftLgnRoi);
for ii = 1:length(idx)
    [a,b,c] = ind2sub(size(curSys.sys.aImg),idx(ii));
    
    x(ii) = curSys.sys.ux(a)*1e3;
    y(ii) = curSys.sys.uy(b)*1e3;
    z(ii) = curSys.sys.uz(c)*1e3;
end
plt(end+1) = plot3(x,y,z,'k.','linewidth',2,'markersize',105);

% plot3(-12,3,61,'kx','linewidth',3,'markersize',12)
for ii = 2:length(target)+1
%     label{ii} = [num2str(target(ii-1).sonication.focalSpot(1)), ', ', num2str(target(ii-1).sonication.focalSpot(2))];
    if ii == 2
        label{ii} = 'Current Right';
    elseif ii == 10
        label{ii} = 'Current Left';
    elseif target(ii-1).sonication.focalSpot(1) < 0
        label{ii} = 'Left';
    else
        label{ii} = 'Right';
    end
end
label{end+1} = 'LGN';
label{1} = 'x, y target (mm)';
plt2 = plot3(10,-1,55,'.','markersize',1);
legend([plt2,plt],label)
xlabel('x (mm)')
ylabel('y (mm)')
zlabel('z (mm)')
axis('tight')
axis('equal')
makeFigureBig(h);

