function [f,windows] = averageFreqBandTime(eeg,band,fs,window)

VERBOSE = 0;

dt = 1/fs;
t = 0:dt:(length(eeg)-1)*dt;

nWindows = floor(t(end)/window);
windowIdx = floor(fs*window);
fftx = linspace(-fs/2,fs/2,windowIdx);

bandIdx = find(fftx>=band(1) & fftx<=band(2));
if isempty(bandIdx)
    error('The window and band settings are incompatible - there is no data in the desired frequency')
end

f = nan(nWindows,1);
for ii = 1:nWindows
    data = eeg(((ii-1)*windowIdx+1):(ii*windowIdx));
    DATA = abs(fftshift(fft(data)));
    windows(ii,:) = data;
    if VERBOSE
        h = figure(99);
        plot(fftx,DATA);
        ax = gca;
        ax.XLim = [30,70];
        xlabel('Frequency (Hz)')
        ylabel('Magnitude')
        makeFigureBig(h)
        keyboard
    end
    f(ii) = mean(DATA(bandIdx));
    if max(data) > 100
        f(ii) = nan;
    end
end