% Creates a 3 dimensional color image that can be displayed using imshow.
% The color image is an overlay of sys.tInterp on sys.aImg. This allows
% faster scrolling through the resulting data
% 
% @INPUTS
%   sys: Must have fields tInterp and aImg and they must be the same size
%   tWindow: A 2 X 1 vector representing the desired temperature window
%       ([tMin, tMax])
% 
% @OUTPUTS
%   cImg: The resulting color img which will have size [size(sys.aImg), 3]
% 
% Taylor Webb
% University of Utah
% September 2020

function sys = draw3dTempOverlay(sys,tWindow)
d = waitbar(0,'Gray Image');
tic
window = [min(sys.aImg(:)),max(sys.aImg(:))];
if window(1) < 0
    window(1) = 0;
end

sys.aImg(sys.aImg>window(2)) = window(2);
sys.aImg(sys.aImg<window(1)) = window(1);

grayValue = sys.aImg/max(sys.aImg(:));
gImg = repmat(grayValue,[1,1,1,size(sys.tInterp,4)]);
% grayValue = 1/sqrt(3)*intensity;

cMap = colormap('hot');

tImg = sys.tInterp;
tImg(tImg<tWindow(1)) = tWindow(1);
tImg(tImg>tWindow(2)) = tWindow(2);
tImg = round(((tImg-tWindow(1))/(diff(tWindow)))*size(cMap,1));

cImg = zeros([size(sys.tInterp),3]);
waitbar(1/4,d,'Color Channel: 1 of 3');
for ii = 1:3
    tmpColor = cMap(:,ii);

    f_cImg = gImg;
    f_cImg(tImg>0) = tmpColor(tImg(tImg>0));
    cImg(:,:,:,:,ii) = f_cImg;
    waitbar((ii+1)/4,d,['Color Channel: ', num2str(ii+1), ' of 3']);
end
sys.colorTempImg = cImg;
sys.tWindow = tWindow;
close(d)
toc