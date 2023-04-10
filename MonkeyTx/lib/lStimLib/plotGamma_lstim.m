% plotGamm_lstim reads theeeg in the file fName and plots the power in the
% frequency band, band over time.
% 
% @Inputs
%   fName: Full location of the EEG data
%   band: 2 element vector with the first element representing the lower
%       bound of the desired band and the 2nd element representing the
%       upper bound.
%   name, value pairs:
%       fftWindow: window over which to perform FFT (ms). Default is 250 ms
%       windowSize: window over which to average the measured power in the
%           specified frequency band (s). The resulting data will five the
%           average power in the specified band across 
%           floor(windowSize/fftWindow) fftWindows. Default is 3.5 seconds.
%       tTestWindow: The function performs a ttest on changes in power
%           before and after sonication (s). floor(tTestWindow/windowSize)
%           windows will be included before/after sonication in that
%           comparison. Default is 20 seconds.
%       isi: inter stimulus interval in seconds. Defaults to 8 seconds.
%       verbose: If greater than one, data are plotted with greater
%           granularity and total power is ploted instead of percent
%           change.
% 
% @OUTPUTS
%   bnd: A struct with
%       @FIELDS:
%           tBefore: time vector for measured power in band before
%               sonication.
%           bndBefore: power measured in specified band at time points
%               tBefore
%           semBndBefore: standard error of the mean for the measurement in
%               bndBefore.
%           tDuring: time vector for measured power in band during
%               sonication.
%           bndDuring: power measured in specified band at time points
%               tDuring
%           semBndBefore: standard error of the mean for the measurement in
%               bndDuring.
%           tPost: time vector for measured power in band after
%               sonication.
%           bndPost: power measured in specified band at time points
%               tPost
%           semBndPost: standard error of the mean for the measurement in
%               bndPost.
%   rawEeg: raw eeg data aligned to US triggers
%   tRawEeg: time points corresponding to rawEeg
% 
% Taylor Webb
% University of Utah
% 2023

function [bnd,rawEeg,tRawEeg] = plotGamma_lstim(t,eeg,digUs,band,varargin)
% Error Checking
if mod(length(varargin),2)
    error('There must be an even number of inputs')
end

fftWindow = 0.25;
windowSize = 3.5;
tTestWindow = 20;
isi = 8;
VERBOSE = 0;
plotResults = 1;
for ii = 1:length(varargin)/2
    switch(varargin{(ii-1)*2+1})
        case 'fftWindow'
            fftWindow = varargin{ii*2};
        case 'windowSize'
            windowSize = varargin{ii*2};
        case ' tTestWindow'
            tTestWindow = varargin{ii*2};
        case 'isi'
            isi = varargin{ii*2};
        case 'verbose'
            VERBOSE = varargin{ii*2};
        case 'plotResults'
            plotResults = varargin{ii*2};
        otherwise
            error([varargin{(ii-1)*2+1}, ' is not a valid name for a name value pair.'])
    end
end

usIdx = find(diff(digUs)>0);

% There is a spurious trigger when the FGs turn off
if t(usIdx(end))-t(usIdx(end-1)) > 8
    usIdx = usIdx(1:end-1);
end

dt = mean(diff(t));
fs = round(1/dt);
% keyboard
% fs = 250;
% dt = 1/fs;
% t = 0:dt:(size(eeg,1)-1)*dt;
% t = t';

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

windowIdx = round(windowSize*fs);
fftx = linspace(-fs/2,fs/2,windowIdx);

%% Baseline
idx = windowIdx:usIdx(1); % There is always a large transient - skip the first window.
disp(['Found ', num2str(t(idx(end))), ' seconds of baseline'])
avgBand = averageFreqBandTime(eeg(idx),band,fs,fftWindow);
[avgBand,~,semBand] = timeAverage(avgBand,fftWindow,windowSize);
tBefore = t(idx(round(windowIdx/2):windowIdx:windowIdx*length(avgBand)));

if VERBOSE
    h = figure;
    shadedErrorBar(tBefore,avgBand,semBand);
    title('Baseline Epoch')
    xlabel('time')
    ylabel([num2str(band(1)), ' - ', num2str(band(2)),' Hz (\mu V)'])
    makeFigureBig(h);
end

%% During Stim
delay = 0.15;
delayIdx = round(delay*fs); % To avoid US artifact
avgBandDuring = [];
semBandDuring = [];
tDuring = [];
rawEeg = [];
for ii = 1:length(usIdx)
%     data(ii,:) = eeg((delayIdx+usIdx(ii)):(delayIdx+usIdx(ii)+windowIdx-1));
    trigCheck(ii,:) = digUs(usIdx(ii):(usIdx(ii)+windowIdx-1));
    rawEeg(ii,:) = eeg(usIdx(ii):(usIdx(ii)+windowIdx-1))-mean(eeg(usIdx(ii):(usIdx(ii)+windowIdx-1)));
    curIdx = (delayIdx+usIdx(ii)):(usIdx(ii)+isi/2*fs);
    data = eeg(curIdx);
    tmp = averageFreqBandTime(data,band,fs,fftWindow);
    [avgBandDuring(ii,:),~,semBandDuring(ii,:)] = timeAverage(tmp,fftWindow,windowSize);
    tDuring(ii,:) = t(curIdx(round(windowIdx/2):windowIdx:windowIdx*size(avgBandDuring,2)));
end

tRawEeg = 0:dt:((size(rawEeg,2)-1)*dt);

if VERBOSE
    h = figure;
    plot(t(1:windowIdx),mean(trigCheck,1));
    title('Double Check Trigger Alignment')
    xlabel('time')
    ylabel('voltage (\mu V)')
    makeFigureBig(h);
end
% keyboard
if size(avgBandDuring,2)>1 && plotResults
    h = figure;
    xt = delay:windowSize:(isi/2-windowSize);
    shadedErrorBar(xt,mean(avgBandDuring,1),semOmitNan(avgBandDuring,1));
    xlabel('time (s)')
    ylabel([num2str(band(1)), ' - ', num2str(band(2)),' Hz (\mu V)']);
    title('During sonication')
    makeFigureBig(h)
end

%% Post Stim
idx = round(usIdx(end)+4*fs):length(eeg);
disp(['Found ', num2str(t(idx(end))-t(idx(1))), ' seconds of post stim recording'])

avgBandPost = averageFreqBandTime(eeg(idx),band,fs,fftWindow);
[avgBandPost,~,semBandPost] = timeAverage(avgBandPost,fftWindow,windowSize);

tAfter = t(idx(round(windowIdx/2):windowIdx:windowIdx*length(avgBandPost)));

if VERBOSE
    h = figure;
    shadedErrorBar(1:windowSize:length(avgBandPost)*windowSize,avgBandPost,semBandPost);
    title('Post Stim Epoch')
    xlabel('time (s)')
    ylabel([num2str(band(1)), ' - ', num2str(band(2)),' Hz (\mu V)'])
    makeFigureBig(h);
end

%% Plot all together
if plotResults
    h = figure;
    if VERBOSE
        divider = 1;
        subtractor = 0;
    else
        divider = mean(avgBand)/100;
        subtractor = 100;
    end
    ax = gca;
    bf = shadedErrorBar(tBefore,avgBand/divider-subtractor,semBand/divider,'lineprops',{'Color',ax.ColorOrder(1,:)});
    hold on
    if size(tDuring,2)>1
        for ii = 1:size(tDuring,1)
            dr = shadedErrorBar(tDuring(ii,:),avgBandDuring(ii,:)/divider-subtractor,semBandDuring(ii,:)/divider,'lineprops',{'Color',ax.ColorOrder(2,:)});
        end
    else
        dr = shadedErrorBar(tDuring,avgBandDuring/divider-subtractor,semBandDuring/divider,'lineprops',{'Color',ax.ColorOrder(2,:)});
    end
    ar = shadedErrorBar(tAfter,avgBandPost/divider-subtractor,semBandPost/divider,'lineprops',{'Color',ax.ColorOrder(3,:)});
    xlabel('time (s)')
    ylabel('% change')
    legend([bf.mainLine,dr.mainLine,ar.mainLine],'Before','During','After')
    makeFigureBig(h);
end

bnd = struct('tBefore',tBefore,'bndBefore',avgBand,'semBndBefore',semBand,...
    'tDuring',tDuring,'bndDuring',avgBandDuring,'semBndDuring',semBandDuring,...
    'tPost',tAfter,'bndPost',avgBandPost,'semBndPost',semBandPost);

%% T-test before and after
idxBefore = find(tBefore>=tBefore(end)-tTestWindow);
timePost = 0;
idxAfter = find(tAfter<=tAfter(1)+timePost+tTestWindow & tAfter>=timePost+tAfter(1));

disp('TTest:')
disp(['Before: ', num2str(tBefore(idxBefore(end))-tBefore(idxBefore(1)),2), '(Start: ', num2str(tBefore(idxBefore(1))), ')'])
disp(['After: ', num2str(tAfter(idxAfter(end))-tAfter(idxAfter(1)),2), '(Post Start: ', num2str(tAfter(idxAfter(1))),')'])

[~,p] = ttest2(avgBand(idxBefore),avgBandPost(idxAfter));

bnd.p = p;

if plotResults
    h = figure;
    ax = gca;
    bar(1:2,[mean(avgBand(idxBefore)),mean(avgBandPost(idxAfter))]);
    hold on
    eb = errorbar(1:2,[mean(avgBand(idxBefore)),mean(avgBandPost(idxAfter))],...
        [semOmitNan(avgBand(idxBefore)),semOmitNan(avgBandPost(idxAfter))]);
    set(eb,'linestyle','none','Color',ax.ColorOrder(1,:),'linewidth',2);
    sigstar([1,2],p);
    ax.XTick = [1:2];
    ax.XTickLabel = {'Before','After'};
    ax.XTickLabelRotation = 90;
    ylabel('Power in selected band')
    title(['p=', num2str(p,2)])
    makeFigureBig(h)
end