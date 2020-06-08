% Creates a color overlay of the transducer on an MR image and returns a 4D
% matrix with red, green, blue values for the 3d Image data set. The
% returned matrix, colorImg, is [size(img), 3].
% 
% @INPUTS
%   img: The 3D MR dataset
%   txImg: A 3D image of transducer elements and fiducials to be overlaid
%     on img
%   window: Window in which to display gray MR data. Optional, defaults to
%     [min(img(:)), max(img(:))]
% 
% @OUTPUTS
%   colorImg: unit8 matrix with color values representing an overlay of the
%     transducer on the MR dataset.
% 
% Taylor Webb
% University of Utah

function colorImg = drawTransducerColor(img,txImg,window)

if nargin < 3
    window = [min(img(:)),max(img(:))];
end

img(img>window(2)) = window(2);
img(img<window(1)) = window(1);
img = img-min(img(:));

intensity = 443.4*img/max(img(:));
grayValue = round(1/sqrt(3)*intensity);

colorImg = zeros([size(img),3]);
colorImg(:,:,:,1) = grayValue;
colorImg(:,:,:,2) = grayValue;
colorImg(:,:,:,3) = grayValue;

txColorImg = zeros(size(txImg));
txColorImg(txImg>0) = 255;
colorImg(:,:,:,2) = colorImg(:,:,:,2)+txColorImg;
colorImg(colorImg>255) = 150;

colorImg = uint8(colorImg);