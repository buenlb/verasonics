% Plots the parameter of interest (usually either power or delay) on a grid
% based on the element from which the signal came. This code assumes that
% delays is a 1x256 element array whose index corresponds to the element
% number from which the measurement was acquired. Thus it lays the
% parameter out on an 2x32 grid corresponding to the 256 element Tx
% acquired from Doppler. 
% 
% @INPUTS
%   delays: parameter to be plotted on grid
% 
% @OUTPUTS
%   None but it does create a plot with the parameter plotted in color
%       based on its magnitude relative to the max.
% 
% Taylor Webb
% University of Utah
% January 2020

function plotPhases2D(delays)
delays = delays-min(delays);
h = figure;
hold on
for ii = 1:length(delays)
    cm = colormap('hot'); % returns the current color map
    colorID = max(1, sum(delays(ii)/max(abs(delays)) > [0:1/length(cm(:,1)):1]));

    myColor = cm(colorID, :); % returns your color
    x = ceil(ii/8);
    if mod(ii,8)
        y = mod(ii,8);
    else
        y = 8;
    end
    plot(x,y,'o','Color',myColor)
end
axis('equal')
axis('tight')
ax = gca;
ax.XTick = [1,32];
ax.XTickLabel = {'1','249'};
xlabel('Element No')
ylabel('Element No')
title(['Max: ', num2str(max(delays),2)]);
colorbar;
makeFigureBig(h);