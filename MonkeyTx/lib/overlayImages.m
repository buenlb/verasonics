% Overlays an intensity image in color over a gray scale image. For
% example, you can overlay a simulation on a medical image.
% 
% @INPUTS
%   gImg: Grayscale image (MxN matrix)
%   cImg: intensity image (MxN matrix). This will be converted into a true
%       color image and overlaid on gImg
%   handle: handle to figure on which to generate the image
%   xAx: Nx2 vector containing x-limits of image
%   yAx: Nx2 vector containing y-limits of image
%   threshold: Selects which values of cImg to display. Anything less than
%       threshold will be set to full transparency and will therefore be
%       invisible
%   window: Optional input specifying a window for the gray image data
%   transparency: optional input specifying percent transparency. Default:
%       0.8
%   C: optional input, string specifying desired colormap. Default: hot
% 
% @OUTPUTS
%   none
% 
% Taylor Webb
% University of Utah
% Summer 2019

function overlayImages(gImg,cImg,handle,xAx,yAx,threshold,window,transparency,C)
if ~exist('C','var')
    C = colormap(handle,'hot');
else
    C = colormap(handle,C);
end
L = size(C,1);

if size(gImg)~=size(cImg)
    error('Images must be the same size!')
end

try
    Gs = round(interp1(linspace(min(cImg(:)),max(cImg(:)),L),1:L,cImg));
    rgbImage = reshape(C(Gs,:),[size(Gs) 3]);
catch
    rgbImage = zeros([size(cImg),3]);
end

if ~exist('window','var')
    window = [min(gImg(:)),max(gImg(:))];
end
if ~exist('transparency','var')
    transparency = 0.8;
end

% Display the gray scale image
imshow(gImg,window,'Parent',handle,'xData',xAx,'yData',yAx,'InitialMagnification','fit');
hold(handle,'on')

% Display the color image
cHandle = imshow(rgbImage,'Parent',handle,'xData',xAx,'yData',yAx,'InitialMagnification','fit');
aData = zeros(size(cImg));
aData(cImg > threshold) = transparency;
set(cHandle,'AlphaData',aData);