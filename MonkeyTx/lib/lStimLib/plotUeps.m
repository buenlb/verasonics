% plotVeps plots visual evoked potentials before and after ultrasound
% stimulus.
% 
% @INPUTS:
%   t: time vector representing the time of each sample (s)
%   eeg: raw eeg data (expects only one averaged stream)
%   ledTrig: Trigger signal for LED stimulus (digital)
%   usTrig: Trigger signal for ultrasound (digital)
%   ARGUMENT PAIRS:
%       notch: A vector containing the frequencies 1 and 2 for a notch
%           filter. The user may provide more than one set of frequencies
%           but the vector must always have an even number of entries. (Hz;
%           defaults to [59,61])
%       verbose: toggle what to plot. Defaults to 0)
%       window: Lenght of window in which to plot VEPs (s; defaults to
%           250e-3)
% 
% @OUTPUTS:
%   vep: eeg signal in relevant window after each ultrasound pulse occurs
%   tVep: time vector corresponding to vep, referenced to the led
%       trigger (s)
% 
% Taylor Webb
% January, 2023

function [vep,tVep,h] = plotUeps(t,eeg,usTrig,varargin)
dt = mean(diff(t));
fs = round(1/dt);

if mod(length(varargin),2)
    error('There must be an even number of inputs')
end

VERBOSE = 0;
notch = [59,61];
window = 250e-3;
for ii = 1:length(varargin)/2
    switch(varargin{(ii-1)*2+1})
        case 'notch'
            notch = varargin{ii*2};
            if mod(length(notch),2)
                error('Argument paired with notch must be a multiple of 2')
            end
        case 'verbose'
            VERBOSE = varargin{ii*2};
        case 'window'
            window = varargin{ii*2};
        otherwise
            error([varargin{(ii-1)*2+1}, ' is not a valid name for a name value pair.'])
    end
end

ledStim = find(diff(usTrig)>0);

disp('Filtering...')
tic
for ii = 1:length(notch)/2
    d = designfilt('bandstopiir','FilterOrder',2, ...
                   'HalfPowerFrequency1',notch((ii-1)*2+1),'HalfPowerFrequency2',notch(ii*2), ...
                   'DesignMethod','butter','SampleRate',fs);
    eeg = filtfilt(d,eeg);
end
toc

window = ceil(window/dt);
%% Baseline Epoch
baselineLed = ledStim;
vep = nan(window+1,length(baselineLed));
ledB = vep;
for ii = 1:length(baselineLed)
    vep(:,ii) = eeg(baselineLed(ii):(baselineLed(ii)+window))-mean(eeg(baselineLed(ii):(baselineLed(ii)+window)));
    ledB(:,ii) = usTrig(baselineLed(ii):(baselineLed(ii)+window));
end

tVep = t(1:window+1);
h = figure;
ax = gca;
shadedErrorBar(tVep*1e3,mean(vep,2),semOmitNan(vep,2),'lineprops',{'Color',ax.ColorOrder(1,:)});
xlabel('time (ms)')
ylabel('voltage (\mu V)')
makeFigureBig(h);

if VERBOSE
    h1 = figure;
    subplot(211)
    plot(tVep,mean(ledB,2))
    title('Double Check Triggers: Before')
    makeFigureBig(h1);
end