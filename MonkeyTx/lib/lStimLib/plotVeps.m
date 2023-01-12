function vep = plotVeps(eeg,ledTrig,usTrig)

fs = 250;
dt = 1/fs;
t = 0:dt:(length(eeg)-1)*dt;

ledStim = find(diff(ledTrig)>0);

% All led triggers should be separated by 250 ms (+/- 1 sample). Error 
% check this.
if sum((diff(t(ledStim))-0.25)>dt)
    error('The trigger for the LEDs is not 250 ms')
end

disp('Filtering...')
tic
d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
               'DesignMethod','butter','SampleRate',fs);
eeg = filtfilt(d,eeg);
toc

window = 200e-3;
window = ceil(window/dt);

vep = nan(window+1,length(ledStim));
for ii = 1:length(ledStim)
    vep(:,ii) = eeg(ledStim(ii):(ledStim(ii)+window))-mean(eeg(ledStim(ii):(ledStim(ii)+window)));
end

h = figure;
shadedErrorBar(t(1:window+1)*1e3,mean(vep,2),semOmitNan(vep,2));
xlabel('time (ms)')
ylabel('voltage (\mu V)')
makeFigureBig(h);