function eeg = notchFilter(eeg,fs,notch)
disp('Filtering...')
tic
d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',notch(1),'HalfPowerFrequency2',notch(2), ...
               'DesignMethod','butter','SampleRate',fs);
for ii = 1:size(eeg,1)
    eeg(ii,:) = filtfilt(d,eeg(ii,:));
end