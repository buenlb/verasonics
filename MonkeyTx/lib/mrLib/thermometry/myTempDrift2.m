%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calc temperature - simple call, no GUI
% TempDrift2 uses baseline images at the same slice location to asses 
% accumulation of temperature over the course of a treatment.
% 
% Author:   Rachelle Bitton
% Date:     6/15/2013      
% 
% Modified by Taylor Webb to be a function
% 7/10/2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tempDiff = myTempDrift2(B0, baselineImg, img, TE, roi)
% Calc Temp difference
% imdiff = angle(img./baselineImg);
imdiff = img-baselineImg;
if exist('roi', 'var')
%     if ~exist('GoldsteinUnwrap2D', 'file')
%         addpath('/Users/Webb/Dropbox/Work/MATLAB/dicoms/PhaseUnwrapping2D/')
%     end
    IM = img./baselineImg;
    IM_mask = roi;
    save /Users/Webb/Dropbox/Work/MATLAB/dicoms/PhaseUnwrapping2D/IM.mat IM IM_mask
    GoldsteinUnwrap2D
    roivec = find(roi>0);
    imdiff(roivec) = temp_IM(roivec);
end
tempDiff = phase2temp(imdiff,0,TE,B0); % just calculate temperature difference T0=0
% imshow(tempdiff,[0 30]); colormap jet;

