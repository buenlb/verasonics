function [m,sDev,sError] = timeAverage(v,dt,window)
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