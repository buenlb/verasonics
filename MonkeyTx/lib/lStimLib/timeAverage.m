% Averages the variable, v, over time in windows of size window. Assumes a
% temporal seperation between the elements of v as dt. If overlap is
% greater than zero it slides the window with an overlap percentage of
% overlap (default is zero).
% 
% Taylor Webb
% University of Utah
% Spring 2023


function [m,sDev,sError] = timeAverage(v,dt,window,overlap)
if ~exist('overlap','var')
    overlap = 0;
end

windowIdx = ceil(window/dt);

nWindows = floor(length(v)/windowIdx);
m = nan(nWindows,1);
sDev = m;
sError = m;
for ii = 1:nWindows
    m(ii) = mean(v(((ii-1)*windowIdx+1):(ii*windowIdx)));
    sDev(ii) = std(v(((ii-1)*windowIdx+1):(ii*windowIdx)));
    sError(ii) = std(v(((ii-1)*windowIdx+1):(ii*windowIdx)))/sqrt(windowIdx);
end