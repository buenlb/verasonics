% Creates a 3 dimensional color image that can be displayed using imshow.
% The color image is an overlay of sys.tInterp on sys.aImg. This allows
% faster scrolling through the resulting data
% 
% @INPUTS
%   sys: Must have fields tInterp and aImg and they must be the same size
%   tWindow: A 2 X 1 vector representing the desired temperature window
%       ([tMin, tMax])
%   transp: Desired transparency (must be a value between 0 and 1)
%   deNoised: A flag that determines which tInterp matrix to use.
% 
% @OUTPUTS
%   cImg: The resulting color img which will have size [size(sys.aImg), 3]
% 
% Taylor Webb
% University of Utah
% September 2020

function sys = draw3dTempOverlay(sys,tWindow,dynamics,transp,deNoised)
if nargin < 4
    transp = 1;
elseif transp < 0 || transp > 1
    error('transp must be between 0 and 1.')
end

if ~exist('deNoised','var')
    deNoised = 1;
end

d = waitbar(0,'Gray Image');
tic
if dynamics == 0
    grayValue = sys.aImg/max(sys.aImg(:));
    gImg = repmat(grayValue,[1,1,1,size(sys.tInterp,4)]);
    % grayValue = 1/sqrt(3)*intensity;

    cMap = colormap('hot');

    if deNoised
        tImg = sys.tInterp;
    else
        tImg = sys.tInterp_deNoised;
    end
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
else
    if deNoised
        tImg = mean(sys.tInterp_deNoised(:,:,:,dynamics),4);
    else
        tImg = mean(sys.tInterp(:,:,:,dynamics),4);
    end
    
    gImg = sys.aImg/max(sys.aImg(:));

    cMap = colormap('hot');

    tImg(tImg<tWindow(1)) = tWindow(1);
    tImg(tImg>tWindow(2)) = tWindow(2);
    tImg = round(((tImg-tWindow(1))/(diff(tWindow)))*size(cMap,1));
    cImg = zeros([size(sys.aImg),3]);
    waitbar(1/4,d,'Color Channel: 1 of 3');
    for ii = 1:3
        tmpColor = cMap(:,ii)*transp;

        f_cImg = gImg;
        if transp == 1
            f_cImg(tImg>0) = tmpColor(tImg(tImg>0));
        else
            f_cImg(tImg>0) = f_cImg(tImg>0)+tmpColor(tImg(tImg>0));
            f_cImg(tImg>0) = f_cImg(tImg>0)/2;
        end
        cImg(:,:,:,ii) = f_cImg;
        waitbar((ii+1)/4,d,['Color Channel: ', num2str(ii+1), ' of 3']);
    end
    sys.colorTempImg = cImg;
    sys.tWindow = tWindow;
end
close(d)
toc