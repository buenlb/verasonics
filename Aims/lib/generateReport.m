function generateReport(Grid,Tx,FgParams,Hydrophone,xy,xz,yz,imgpath)
mkdir(imgpath)

cal = findCalibration(Tx.frequency,Hydrophone.calibrationFile,0);

h = figure(100);
imagesc(xy.x,xy.y,-xy.data/cal*1e-6);
xlabel(xy.xLabel);
ylabel(xy.yLabel);
colormap('hot')
colorbar;
title('PNP in XY Plane (MPa)')
axis('equal')
axis([xy.x(1) xy.x(end) xy.y(1) xy.y(end)])
makeFigureBig(h)
print([imgpath,'xy'],'-dpng')

h = figure(101);
imagesc(xz.y,xz.x,-xz.data'/cal*1e-6);
xlabel(xz.yLabel);
ylabel(xz.xLabel);
colormap('hot')
colorbar;
title('PNP in XY Plane (MPa)')
axis('equal')
axis([xz.y(1) xz.y(end) xz.x(1) xz.x(end)])
makeFigureBig(h)
print([imgpath,'xz'],'-dpng')

h = figure(102);
imagesc(yz.y,yz.x,-yz.data'/cal*1e-6);
xlabel(yz.yLabel);
ylabel(yz.xLabel);
colormap('hot')
colorbar;
title('PNP in XY Plane (MPa)')
axis('equal')
axis([yz.y(1) yz.y(end) yz.x(1) yz.x(end)])
makeFigureBig(h)
print([imgpath,'yz'],'-dpng')

%% Efficiency Curve
fileBase = 'wv_';
folder = [imgpath,'..\efficiencyCurve\'];

[vpp,vIn,v1,t] = readEfficiencyData(folder,fileBase);

figure;
ax = gca;
colorOrder = ax.ColorOrder;

h = figure(103);
clf
set(h,'defaultAxesColorOrder',[colorOrder(1,:); colorOrder(1,:)]);

yyaxis('left')
plot(vIn,vpp/cal*1e-6,'^','linewidth',3,'markersize',8)
ax1 = gca;
ylim1 = get(ax1,'ylim');
ylabel('Measured PNP (MPa))','FontSize',18)

yyaxis('right')
plot(vIn,vpp*1e3,'^','linewidth',3,'markersize',8)
ylim(ylim1*cal*1e9);
xlabel('Input Voltage (mV)','FontSize',18)
ylabel('Measured PNV (mV)','FontSize',18,'color',colorOrder(1,:))
title('Efficiency','FontSize',18)
makeFigureBig(h);
axT = gca;
% set(axT,'fontcolor',colorOrder(1,:));
axis('tight')
grid on
print([imgpath,'eff'],'-dpng')

h = figure(104);
clf
set(h,'defaultAxesColorOrder',[colorOrder(1,:); colorOrder(1,:)]);

yyaxis('left')
plot(t,v1/cal*1e-6,'linewidth',1)
ax1 = gca;
ylim1 = get(ax1,'ylim');
ylabel('Pressure (MPa)','FontSize',18)

yyaxis('right')
plot(t,v1*1e3,'linewidth',1)
ylim(ylim1*cal*1e9);
grid on
xlabel('time (\mus)','FontSize',18)
ylabel('Voltage (mV)','FontSize',18)
title('Waveform','FontSize',18)
makeFigureBig(h);
axis('tight')
print([imgpath,'wv'],'-dpng')

writeLatex(Grid,Tx,FgParams,imgpath);
writeBatchFile(imgpath);

command = ['"', imgpath, 'pdflatexScript.bat"&'];
dos(command);

