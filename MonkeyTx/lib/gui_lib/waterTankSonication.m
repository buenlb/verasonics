clear all; close all; clc;
x = 0;
y = -2:0.5:2;
z = 15:30;
[X,Y,Z] = ndgrid(x,y,z);
save C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\setupScripts\gridInfo.mat;
%%
filename = 'L74_waterTank.mat';
VSX
%%
grid = load(Resource.Parameters.gridInfoFile);
for ii = 1:length(grid.X(:))
    [t,v] = readWaveform(['C:\Users\verasonics\Desktop\Taylor\L74Prep\test', num2str(ii),'.snq']);
    [x,y,z] = ind2sub(size(grid.X),ii);
    vMax(x,y,z) = max(v); 
end

figure
imagesc(squeeze(vMax(1,:,:)));