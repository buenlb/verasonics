addpath('C:\Users\Taylor\Documents\Projects\txLocCovid\verasonics\lib\gui_lib\')

load 'C:\Users\Taylor\Documents\Projects\txLocCovid\test2_zInf.mat';

gs = load('C:\Users\Taylor\Documents\Projects\txLocCovid\goldStandard_test1_zInf.mat');


[sf,~,xa,ya,za] = skullSurfaceGrid(griddedElRaw.RcvData,griddedElRaw.Receive,gs);

img = griddedElementBModeImage_2D(griddedElRaw.RcvData,griddedElRaw.Receive,gs.powerRange,1);

%%
h = figure;
for ii = 1:6
    ax = subplot(2,3,ii);
    overlayImages(squeeze(img(:,ii,:)),squeeze(sf(:,ii,:)),ax,za,xa,0.9);
end