function plotGamma_lstim(t,eeg,digUs)
% raw = readmatrix(fName);
% eeg = mean(raw(:,[2,5]),2);
% digUs = raw(:,15);

usIdx = find(diff(digUs)>0);

dt = mean(diff(t));
fs = 1/dt;

% All led triggers should be separated by 250 ms (+/- 1 sample). Error 
% check this.
% if sum((diff(t(ledStim))-1)>2*dt)
%     keyboard
%     error('The trigger for the LEDs is not 250 ms')
% end

disp('Filtering...')
tic
d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
               'DesignMethod','butter','SampleRate',fs);
eeg = filtfilt(d,eeg);
toc

fftWindow = 0.25;
windowSize = 1;
windowIdx = round(windowSize*fs);
fftx = linspace(-fs/2,fs/2,windowIdx);
freqBandIdx = find(fftx>=band(1) & fftx<=band(2));
x = t(1:windowIdx);

%% Baseline
idx = 1:usIdx(1);
disp(['Found ', num2str(t(idx(end))), ' seconds of baseline'])

avgBand = averageFreqBandTime(eeg(idx),band,fs,fftWindow);
[avgBand,~,semBand] = timeAverage(avgBand,fftWindow,windowSize);

h = figure;
shadedErrorBar(1:windowSize:t(idx(end)),avgBand,semBand);
title('Baseline Epoch')
xlabel('time')
ylabel([num2str(band(1)), ' - ', num2str(band(2)),' Hz (\mu V)'])
makeFigureBig(h);

%% During Stim
delay = 0.2;
delayIdx = delay*fs; % To avoid US artifact
data = [];
for ii = 1:length(usIdx)
    data(ii,:) = eeg((delayIdx+usIdx(ii)):(delayIdx+usIdx(ii)+windowIdx-1));
    trigCheck(ii,:) = digUs(usIdx(ii):(usIdx(ii)+windowIdx-1));
end
% keyboard
h = figure;
subplot(211)
shadedErrorBar(x,mean(data,1),semOmitNan(data,1));
title('Average during US')
xlabel('time')
ylabel('voltage (\mu V)')
makeFigureBig(h);

subplot(212)
plot(t(1:windowIdx),mean(trigCheck,1));
title('Double Check Trigger Alignment')
xlabel('time')
ylabel('voltage (\mu V)')
makeFigureBig(h);

h = figure;
keyboard

%% Post Stim
idx = (usIdx(end)+4*fs):length(eeg);

disp(['Found ', num2str(t(idx(end))-t(idx(1))), ' seconds of baseline'])

nWindows = floor((t(idx(end))-t(idx(1)))/windowSize);
bData = [];
for ii = 1:nWindows
    pData(ii,:) = eeg((idx((ii-1)*windowIdx+1)):idx(ii*(windowIdx)));
    PDATA(ii,:) = abs(fftshift(fft(pData(ii,:))));
end

h = figure;
shadedErrorBar(x,mean(pData,1),semOmitNan(pData,1));
title('Post Epoch')
xlabel('time')
ylabel('voltage (\mu V)')
makeFigureBig(h);