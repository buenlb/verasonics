 % Overlay Images 2 overlays cImg on gImg using the colormap, map, to
% interpret the data in gImg.
% 
% Usage: overlayImages2(gImg,cImg,gWindow,cWindow,xData,yData,ax,transparency,map)
function overlayImages2(gImg,cImg,gWindow,cWindow,xData,yData,ax,transparency,map)
%% Process Inputs
defaultMap = 'hot';
if nargin < 3
    gWindow = [min(gImg(:)),max(gImg(:))];
    cWindow = [min(cImg(:)),max(cImg(:))];
    xData = 1:size(gImg,2);
    yData = 1:size(gImg,1);
    figure;
    ax = gca;
    transparency = 0.5;
    map = defaultMap;
elseif nargin < 4
    cWindow = [min(cImg(:)),max(cImg(:))];
    xData = 1:size(gImg,2);
    yData = 1:size(gImg,1);
    figure;
    ax = gca;
    transparency = 0.5;
    map = defaultMap;
elseif nargin < 5
    xData = 1:size(gImg,2);
    yData = 1:size(gImg,1);
    figure;
    ax = gca;
    transparency = 0.5;
    map = defaultMap;
elseif nargin < 6
    error('If you specify xData you must also specify yData')
elseif nargin < 7
    figure;
    ax = gca;
    transparency = 0.5;
    map = defaultMap;
elseif nargin < 8
    transparency = 0.5;
    map = defaultMap;
elseif nargin < 9
    map = defaultMap;
end

if isempty(cWindow)
    cWindow = [min(cImg(:)), max(cImg(:))];
end
if isempty(ax)
    ax = gca;
end
%% Gray Image
axis(ax);
imshow(gImg,gWindow,'xData',xData,'yData',yData,'parent',ax,'initialMagnification','fit');
axis('equal')
hold(ax,'on')

%% Color Image
h = figure;
cmap = colormap(map);
close(h);
m = length(cmap);
index = fix((cImg-min(cWindow))/(max(cWindow)-min(cWindow))*m)+1;
rgb = ind2rgb(index,cmap);
tPlot = imshow(rgb,'xData',xData,'yData',yData,'parent',ax,'initialMagnification','fit');
axis('equal')

%% Transparency
alpha = zeros(size(cImg));
alpha(cImg>min(cWindow)) = transparency;
set(tPlot,'AlphaData',alpha)
