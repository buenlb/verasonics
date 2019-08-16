function generateReport(Grid,Tx,FgParams,Hydrophone,xy,xz,yz,imgpath)
mkdir(imgpath)

cal = findCalibration(Tx.frequency,Hydrophone.calibrationFile,0);

h = figure(100);
imagesc(xy.x,xy.y,abs(xy.data)/cal*1e-6);
xlabel(xy.xLabel);
ylabel(xy.yLabel);
colormap('hot')
colorbar;
title('PNP in XY Plane (Mpa)')
axis('equal')
axis([xy.x(1) xy.x(end) xy.y(1) xy.y(end)])
makeFigureBig(h)
print([imgpath,'xy'],'-dpng')

h = figure(101);
imagesc(xz.y-Tx.coneEdge,xz.x,abs(xz.data')/cal*1e-6);
xlabel(xz.yLabel);
ylabel(xz.xLabel);
colormap('hot')
colorbar;
title('PNP in XZ Plane (Mpa)')
axis('equal')
axis([xz.y(1)-Tx.coneEdge xz.y(end)-Tx.coneEdge xz.x(1) xz.x(end)])
makeFigureBig(h)
print([imgpath,'xz'],'-dpng')

h = figure(102);
imagesc(yz.y-Tx.coneEdge,yz.x,abs(yz.data')/cal*1e-6);
xlabel(yz.yLabel);
ylabel(yz.xLabel);
colormap('hot')
colorbar;
title('PNP in YZ Plane (Mpa)')
axis('equal')
axis([yz.y(1)-Tx.coneEdge yz.y(end)-Tx.coneEdge yz.x(1) yz.x(end)])
makeFigureBig(h)
print([imgpath,'yz'],'-dpng')

%% Efficiency Curve
fileBase = 'wv_';
folder = [imgpath,'..\efficiencyCurve\'];

[vpp,vIn,v1,t,position] = readEfficiencyData(folder,fileBase,FgParams);
Grid.wvPosition = position;
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
ylabel('Measured PNP (Mpa)','FontSize',18)

yyaxis('right')
plot(vIn,vpp*1e3,'^','linewidth',3,'markersize',8)
ylim(ylim1*cal*1e9);
xlabel('Input Voltage (mVpp)','FontSize',18)
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
ylabel('Pressure (Mpa)','FontSize',18)

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

writeLatex(Grid,Tx,FgParams,Hydrophone,imgpath);
writeBatchFile(imgpath);

command = ['"', imgpath, 'pdflatexScript.bat"&'];
dos(command);

