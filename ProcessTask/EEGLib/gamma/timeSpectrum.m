function [ts,fftX] = timeSpectrum(eeg,t,window,tDesired,freqsOfInterest)

fs = 1/(t(2)-t(1));

fftX = linspace(-fs/2,fs/2,round(fs*window-1));
freqs = find(fftX>=freqsOfInterest(1) & fftX<=freqsOfInterest(2));

ts = nan(length(freqs),length(tDesired));

for ii = 1:length(tDesired)
    curTime = [tDesired(ii)-window,tDesired(ii)];
    idx = find(t>=curTime(1) & t < curTime(2));

    if max(eeg(idx))>200
        continue;
    end
    EEG = fftshift(abs(fft(eeg(idx))));

    ts(:,ii) = EEG(freqs)';
end
fftX = fftX(freqs);