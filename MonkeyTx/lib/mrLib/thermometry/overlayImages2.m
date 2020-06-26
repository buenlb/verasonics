function overlayImages2(gImg,cImg,gWindow,cWindow,xData,yData,ax,transparency,map)
%% Process Inputs
if nargin < 3
    gWindow = [min(gImg(:)),max(gImg(:))];
    cWindow = [min(cImg(:)),max(cImg(:))];
    xData = 1:size(gImg,2);
    yData = 1:size(gImg,1);
    figure;
    ax = gca;
    transparency = 0.5;
    map = 'hot';
elseif nargin < 4
    cWindow = [min(cImg(:)),max(cImg(:))];
    xData = 1:size(gImg,2);
    yData = 1:size(gImg,1);
    figure;
    ax = gca;
    transparency = 0.5;
    map = 'hot';
elseif nargin < 5
    xData = 1:size(gImg,2);
    yData = 1:size(gImg,1);
    figure;
    ax = gca;
    transparency = 0.5;
    map = 'hot';
elseif nargin < 6
    error('If you specify xData you must also specify yData')
elseif nargin < 7
    figure;
    ax = gca;
    transparency = 0.5;
    map = 'hot';
elseif nargin < 8
    transparency = 0.5;
    map = 'hot';
elseif nargin < 9
    map = 'hot';
end

%% Gray Image
axis(ax);
imshow(gImg,gWindow,'xData',xData,'yData',yData);
axis('equal')
hold on

%% Color Image
h = figure;
cmap = colormap(map);
close(h);
m = length(cmap);
index = fix((cImg-min(cWindow))/(max(cWindow)-min(cWindow))*m)+1;
rgb = ind2rgb(index,cmap);
tPlot = imshow(rgb,'xData',xData,'yData',yData);
axis('equal')

%% Transparency
alpha = zeros(size(cImg));
alpha(cImg>min(cWindow)) = transparency;
set(tPlot,'AlphaData',alpha)
