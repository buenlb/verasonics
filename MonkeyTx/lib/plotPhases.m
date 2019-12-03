function plotPhases(xTx,yTx,zTx,delays)

h = figure;
hold on
for ii = 1:length(xTx)
    cm = colormap('jet'); % returns the current color map
    colorID = max(1, sum(delays(ii)/max(abs(delays)) > [0:1/length(cm(:,1)):1]));

    myColor = cm(colorID, :); % returns your color
    plot3(xTx(ii),yTx(ii),zTx(ii),'o','Color',myColor)
end
axis('equal')
axis('tight')
xlabel('x')
ylabel('y')
zlabel('z')
title(['Max Phase: ', num2str(max(delays),2)]);
colorbar;
makeFigureBig(h);