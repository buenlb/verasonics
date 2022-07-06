% Plots temperature over time at the loc, loc. Loc must be in US
% coordinates. sys must have the temperature matrix for the sonication of
% interest (use sys = processAndDisplaySonication(sys,sonNo))

function [maxT,meanT] = plotTemperatureOverTime(sys,loc)

window = [1,1,0];

[~,idxX] = min(abs(sys.ux-loc(1)));
[~,idxY] = min(abs(sys.uy-loc(2)));
[~,idxZ] = min(abs(sys.uz-loc(3)));

[~,idxX] = min(abs(sys.tx-sys.ax(idxX)));
[~,idxY] = min(abs(sys.ty-sys.ay(idxY)));
[~,idxZ] = min(abs(sys.tz-sys.az(idxZ)));

wIdxX = (idxX-window(1)):(idxX+window(1));
wIdxY = (idxY-window(2)):(idxY+window(2));
wIdxZ = (idxZ-window(3)):(idxZ+window(3));

maxT = squeeze(sys.T(idxX,idxY,idxZ,:));
meanT = zeros(size(maxT));
for ii = 1:length(meanT)
    meanT(ii) = mean(mean(mean(sys.T(wIdxX,wIdxY,wIdxZ,ii))));
end

t = 0:sys.dynamicLength:(sys.dynamicLength*(size(sys.T,4)-1));

h = figure;
plot(t, maxT, t, meanT,'linewidth',2)
hold on
plot([t(sys.dynamic),t(sys.dynamic)],[0,max(maxT)],'k--','LineWidth',2)
xlabel('time (s)')
ylabel('Temperature (C)')
legend('Max','Mean')
axis([min(t),max(t),min(maxT),max(maxT)])
makeFigureBig(h)