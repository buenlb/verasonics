% This file does simple processing on VEPs. It assumes that digital 1 has a
% rising edge trigger that corresponds to the digital stimulus. It takes as
% many trials as their are triggers, averages them, and processes the
% result. Currenlty, it does not filter the signal before averaging.

addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\lib');

digTriggerChannel = 1;

% expPath = 'C:\Users\Verasonics\Desktop\Taylor\Data\LStim\EEGTest\';
% fNameBase = 'gauss_beforeInj';

expPath = 'D:\Task\Boltz\eeg\';
fNameBase = 'boltzmannTask_220128';

[t,eeg,dig,alg] = concatIntan(expPath,fNameBase);

idx = findDigitalTriggers(dig(digTriggerChannel,:));

tWindow = 200e-3;
dt = t(2)-t(1);
tIdx = 1:ceil(tWindow/dt);
vepsLeft = zeros(length(idx),length(tIdx));
vepsRight = vepsLeft;
for ii = 1:length(idx)
    if idx(ii)+tIdx(end)>size(eeg,2)
        break;
    end
    vepsLeft(ii,:) = eeg(1,(idx(ii)+1):(idx(ii)+tIdx(end)));
    vepsRight(ii,:) = eeg(2,(idx(ii)+1):(idx(ii)+tIdx(end)));
end

h = figure;
vepLeft = mean(vepsLeft,1);
vepRight = mean(vepsRight,1);
plot(t(tIdx)*1e3,vepLeft,t(tIdx)*1e3,vepRight,'linewidth',2);
xlabel('Time (ms)')
ylabel('Voltage (\muV)')
legend('Left','Right')
makeFigureBig(h);