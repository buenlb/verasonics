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
%   vepB: eeg signal in relevant window after each led trigger that occurs
%       before the US
%   vepB: eeg signal in relevant window after each led trigger that occurs
%       after the US
%   t: time vector corresponding to vepB and vepP, referenced to the led
%       trigger (s)
% 
% Taylor Webb
% January, 2023

function [vepB,vepP,tVep] = plotVeps(t,eeg,ledTrig,usTrig,varargin)
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


ledStim = find(diff(ledTrig)>0);
% All led triggers should be separated by 250 ms (+/- 1 sample). Error 
% check this.
if sum(abs((diff(t(ledStim))-0.5))>2*dt)
    rmIdx = find(abs((diff(t(ledStim))-0.5))>2*dt);
    warning(['Removing ', num2str(length(rmIdx)), ' points from led trigger. (', num2str(rmIdx),')'])
    tmp = true(size(ledStim));
    tmp(rmIdx) = false;
    ledStim = ledStim(tmp);
%     error('The trigger for the LEDs is not 250 ms')
end

disp('Filtering...')
tic
for ii = 1:length(notch)/2
    disp(['Filtering ', num2str(notch((ii-1)*2+1)),'-',num2str(notch(ii*2))]);
    d = designfilt('bandstopiir','FilterOrder',2, ...
                   'HalfPowerFrequency1',notch((ii-1)*2+1),'HalfPowerFrequency2',notch(ii*2), ...
                   'DesignMethod','butter','SampleRate',fs);
    eeg = filtfilt(d,eeg);
end
toc

window = ceil(window/dt);

usIdx = find(diff(usTrig)>0);
if t(usIdx(end))-t(usIdx(end-1)) > 1
    warning('Removing last US trigger - it comes too late.')
    usIdx = usIdx(1:end-1);
end
disp(['Average time between US pulses: ', num2str(1e3*mean(diff(t(usIdx))),3), 'ms'])
%% Baseline Epoch
baselineLed = ledStim(ledStim<usIdx(1)-window);
vepB = nan(window+1,length(baselineLed));
ledB = vepB;
for ii = 1:length(baselineLed)
    vepB(:,ii) = eeg(baselineLed(ii):(baselineLed(ii)+window))-mean(eeg(baselineLed(ii):(baselineLed(ii)+window)));
    ledB(:,ii) = ledTrig(baselineLed(ii):(baselineLed(ii)+window));
end

%% Post Epoch
postLed = ledStim(ledStim>usIdx(end)+window);
vepP = nan(window+1,length(postLed));
ledP = vepP;
for ii = 1:length(postLed)
    if postLed(ii)+window>length(eeg)
        vepP = vepP(:,1:end-1);
        ledP = ledP(:,1:end-1);
        break
    end
    vepP(:,ii) = eeg(postLed(ii):(postLed(ii)+window))-mean(eeg(postLed(ii):(postLed(ii)+window)));
    ledP(:,ii) = ledTrig(postLed(ii):(postLed(ii)+window));
end

tVep = t(1:window+1);

h = figure;
ax = gca;
shadedErrorBar(tVep*1e3,mean(vepB,2),semOmitNan(vepB,2),'lineprops',{'Color',ax.ColorOrder(1,:)});
shadedErrorBar(tVep*1e3,mean(vepP,2),semOmitNan(vepP,2),'lineprops',{'Color',ax.ColorOrder(2,:)});
legend('Before','After')
xlabel('time (ms)')
ylabel('voltage (\mu V)')
makeFigureBig(h);

if VERBOSE
    h = figure;
    subplot(211)
    plot(tVep,mean(ledB,2))
    title('Double Check Triggers: Before')
    makeFigureBig(h);

    subplot(212)
    plot(tVep,mean(ledP,2))
    title('Double Check Triggers: After')
    makeFigureBig(h)
end