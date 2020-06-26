% Allows the user to visually select a focal spot using the MR data set
% that has been specified as the anatomical data.
% 
% @INPUTS:
%   sys: See runMrCode for details on this struct
%   
% @OUTPUTS
%   sys: With updated focalSpot field.
% 
% Taylor Webb
% University of Utah

function sys = selectFocus(sys)
%% Create a 3D data set with image for quick paging
% This should be replaced - it is obsolete with my improved overlayImages
% method but it will require major changes to the GUI.
colorImg = drawTransducerColor(sys.aImg,sys.txImg);
sys.colorImg = colorImg;

%% Allow user to visually select a focus
waitfor(selectFocusGui(sys));

%% Save choice
x = sys.ux;
y = sys.uy;
z = sys.uz;

tmp = load('guiFileOutput.mat');
delete('guiFileOutput.mat');
focalSpotIdx = tmp.focalSpotIdx;
focalSpot = ([x(focalSpotIdx(1)),y(focalSpotIdx(2)),z(focalSpotIdx(3))])*1e3;

sys.focalSpot = focalSpot;
sys.focalSpotIdx = focalSpotIdx;
sys.focalSpotMr = [sys.ax(focalSpotIdx(1)), sys.ay(focalSpotIdx(2)), sys.az(focalSpotIdx(3))]*1e3;

%% Print result in both Tx and MR coordinates
displayFocalCoordinates(sys);
