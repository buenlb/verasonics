function plotElementValues(xTx,yTx,zTx,delays,cMap,h)
if ~exist('h','var')
    h = figure;
end
if ~exist('cMap','var')
    cMap = 'hot';
end

% The algorithm below only works for positive values. Set the color using a
% version of delays with only positive values then set the colorbar to
% reflect the actual values
cBarAxis = [min(delays),max(delays)];
if sum(delays<0)
    delays = delays-min(delays);
end


figure(h);
clf;
hold on
for ii = 1:length(xTx)
    cm = colormap(cMap); % returns the current color map
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
cb = colorbar;
caxis(cBarAxis)
makeFigureBig(h);