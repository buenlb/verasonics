
% This file processes LSTIM data

addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\lib');
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\ProcessTask\EEGLib');
addpath('C:\Users\Taylor\Documents\Projects\verasonics\verasonics\ProcessTask\EEGLib');

ledDig = 1;
usDig = 2;

expPath = 'C:\Users\Verasonics\Desktop\Taylor\Data\LStim\Calvin\';
fNameBase = 'Pulsed_480kHz_prf400_Final_';

[t,eeg,dig,alg] = concatIntan(expPath,fNameBase);

%% Filter
lp = 55;
hp = 1;
wp = [lp 75];
mags = [1,0];
devs = [0.05 0.1];
[n,wn,beta,fType] = kaiserord(wp,mags,devs,20e3);
n = n+rem(n,2);
myFilt = fir1(n,wn,fType,kaiser(n+1,beta),'scale');

for ii = 1:size(eeg,1)
    tic
    disp(['  Filtering Channel ', num2str(ii)])
    eeg(ii,:) = filtfilt(myFilt,1,eeg(ii,:));
    toc
end

idxLEDs = findDigitalTriggers(dig(ledDig,:));
idxUS = findDigitalTriggers(dig(usDig,:));

<<<<<<< HEAD
idxLEDs = idxLEDs(2:end);
idxUS = idxUS(2:end);

=======
if t(idxLEDs(2))-t(idxLEDs(1)) < 1
    idxLEDs = idxLEDs(3:end);
%     idxUS = idxUS(3:end);
else
    idxLEDs = idxLEDs(2:end);
end

idxUS = idxUS(2:end);
>>>>>>> 146de6f206ed9fb3dd51d7d78b091a4a51ba6b08
ledPerBlock = 60;
usPerBlock = 15;
nBlocks = length(idxLEDs)/(2*ledPerBlock);
if mod(nBlocks,1)
    error('Wrong number of LED triggers!')
end
%% LED Only VEPs
<<<<<<< HEAD
tWindow = 500e-3;
=======
tWindow = 250e-3;
>>>>>>> 146de6f206ed9fb3dd51d7d78b091a4a51ba6b08
dt = t(2)-t(1);
tIdx = 1:ceil(tWindow/dt);
vepsLeftLED = zeros(length(idxLEDs)/2,2*length(tIdx));
vepsRightLED = vepsLeftLED;
vepIdx = 1;
for ii = 1:nBlocks
    curIdx = ((ii-1)*ledPerBlock*2+1):(2*(ii-1)+1)*ledPerBlock;
    disp(['Min: ', num2str(curIdx(1)), ', max:', num2str(curIdx(end))]);
    for jj = 1:length(curIdx)
<<<<<<< HEAD
        vepsLeftLED(vepIdx,:) = dig(1,((idxLEDs(curIdx(jj))+1)-tIdx(end)):(idxLEDs(curIdx(jj))+tIdx(end)));
        vepsRightLED(vepIdx,:) = dig(2,((idxLEDs(curIdx(jj))+1)-tIdx(end)):(idxLEDs(curIdx(jj))+tIdx(end)));
=======
        vepsLeftLED(vepIdx,:) = eeg(1,((idxLEDs(curIdx(jj))+1)-tIdx(end)):(idxLEDs(curIdx(jj))+tIdx(end)));
        vepsRightLED(vepIdx,:) = eeg(2,((idxLEDs(curIdx(jj))+1)-tIdx(end)):(idxLEDs(curIdx(jj))+tIdx(end)));
>>>>>>> 146de6f206ed9fb3dd51d7d78b091a4a51ba6b08
%         vepsLeftLED(vepIdx,:) = dig(1,((idxLEDs(curIdx(jj))+1)-tIdx(end)):(idxLEDs(curIdx(jj))+tIdx(end)));
%         vepsRightLED(vepIdx,:) = dig(2,((idxLEDs(curIdx(jj))+1)-tIdx(end)):(idxLEDs(curIdx(jj))+tIdx(end)));

        vepIdx = vepIdx+1;
    end
end
%% LED and US VEPs
vepsLeftLED_US = zeros(length(idxLEDs)/2,2*length(tIdx));
vepsRightLED_US = vepsLeftLED_US;
vepIdx = 1;
for ii = 1:nBlocks
    curIdx = ((2*(ii-1)+1)*ledPerBlock+1):(2*(ii))*ledPerBlock;
    disp(['Min: ', num2str(curIdx(1)), ', max:', num2str(curIdx(end))]);
    for jj = 1:length(curIdx)
<<<<<<< HEAD
        vepsLeftLED_US(vepIdx,:) = dig(1,((idxLEDs(curIdx(jj))+1)-tIdx(end)):(idxLEDs(curIdx(jj))+tIdx(end)));
        vepsRightLED_US(vepIdx,:) = dig(2,((idxLEDs(curIdx(jj))+1)-tIdx(end)):(idxLEDs(curIdx(jj))+tIdx(end)));
=======
        vepsLeftLED_US(vepIdx,:) = eeg(1,((idxLEDs(curIdx(jj))+1)-tIdx(end)):(idxLEDs(curIdx(jj))+tIdx(end)));
        vepsRightLED_US(vepIdx,:) = eeg(2,((idxLEDs(curIdx(jj))+1)-tIdx(end)):(idxLEDs(curIdx(jj))+tIdx(end)));
>>>>>>> 146de6f206ed9fb3dd51d7d78b091a4a51ba6b08
%         vepsLeftLED_US(vepIdx,:) = dig(1,((idxLEDs(curIdx(jj))+1)-tIdx(end)):(idxLEDs(curIdx(jj))+tIdx(end)));
%         vepsRightLED_US(vepIdx,:) = dig(2,((idxLEDs(curIdx(jj))+1)-tIdx(end)):(idxLEDs(curIdx(jj))+tIdx(end)));
        vepIdx = vepIdx+1;
    end
end

<<<<<<< HEAD
%% US Only VEPs
vepsLeftUS = zeros(length(idxUS)/2,length(tIdx));
=======

%% US Only VEPs
vepsLeftUS = zeros(length(idxUS)/2,2*length(tIdx));
>>>>>>> 146de6f206ed9fb3dd51d7d78b091a4a51ba6b08
vepsRightUS = vepsLeftUS;
vepIdx = 1;
for ii = 1:nBlocks
    curIdx = ((2*(ii-1)+1)*usPerBlock+1):(2*(ii))*usPerBlock;
    disp(['Min: ', num2str(curIdx(1)), ', max:', num2str(curIdx(end))]);
    for jj = 1:length(curIdx)
<<<<<<< HEAD
        vepsLeftUS(vepIdx,:) = eeg(1,(idxUS(curIdx(jj))+1):(idxUS(curIdx(jj))+tIdx(end)));
        vepsRightUS(vepIdx,:) = eeg(2,(idxUS(curIdx(jj))+1):(idxUS(curIdx(jj))+tIdx(end)));
=======
        vepsLeftUS(vepIdx,:) = eeg(1,(idxUS(curIdx(jj))+1-tIdx(end)):(idxUS(curIdx(jj))+tIdx(end)));
        vepsRightUS(vepIdx,:) = eeg(2,(idxUS(curIdx(jj))+1-tIdx(end)):(idxUS(curIdx(jj))+tIdx(end)));
>>>>>>> 146de6f206ed9fb3dd51d7d78b091a4a51ba6b08
        vepIdx = vepIdx+1;
    end
end

%% Plot

t = sort([0-t(tIdx),t(tIdx)]);

h = figure;
ax = gca;
hold on;
vepLeftLED = mean(vepsLeftLED,1);
vepRightLED = mean(vepsRightLED,1);
stdLeft = std(vepsLeftLED,[],1)/sqrt(sum(~isnan(vepsLeftLED(:,1))));
stdRight = std(vepsLeftLED,[],1)/sqrt(sum(~isnan(vepsLeftLED(:,1))));
cIdx = ax.ColorOrder;
shadedErrorBar(t*1e3,vepLeftLED,stdLeft,'lineprops',{'Color',cIdx(1,:),'linewidth',2})
shadedErrorBar(t*1e3,vepRightLED,stdRight,'lineprops',{'Color',cIdx(2,:),'linewidth',2})

<<<<<<< HEAD

LED_US_idx = true(size(vepsLeftLED_US,1),1);
LED_US_idx(1:4:end) = false;
LED_US_idx(2:4:end) = false;
% LED_US_idx(3:8:end) = false;
% LED_US_idx(4:8:end) = false;
vepLeftLED_US = mean(vepsLeftLED_US(LED_US_idx,:),1);
vepRightLED_US = mean(vepsRightLED_US(LED_US_idx,:),1);
stdLeft = std(vepsLeftLED_US,[],1)/sqrt(sum(~isnan(LED_US_idx)));
stdRight = std(vepsLeftLED_US,[],1)/sqrt(sum(~isnan(LED_US_idx)));
=======
% The following two lines exclude any trials in which the US is on
LED_US_idx = true(size(vepsLeftLED_US,1),1);
LED_US_idx(2:4:end) = false;

vepLeftLED_US = mean(vepsLeftLED_US(LED_US_idx,:),1);
vepRightLED_US = mean(vepsRightLED_US(LED_US_idx,:),1);
stdLeft = std(vepsLeftLED_US(LED_US_idx,:),[],1)/sqrt(sum(~isnan(LED_US_idx)));
stdRight = std(vepsLeftLED_US(LED_US_idx,:),[],1)/sqrt(sum(~isnan(LED_US_idx)));
>>>>>>> 146de6f206ed9fb3dd51d7d78b091a4a51ba6b08
shadedErrorBar(t*1e3,vepLeftLED_US,stdLeft,'lineprops',{'linestyle','--','Color',cIdx(3,:),'linewidth',2})
shadedErrorBar(t*1e3,vepRightLED_US,stdRight,'lineprops',{'linestyle','--','Color',cIdx(4,:),'linewidth',2})

% vepLeftUS = mean(vepsLeftUS,1);
% vepRightUS = mean(vepsRightUS,1);
% stdLeft = std(vepsLeftUS,[],1)/sqrt(sum(~isnan(vepsLeftUS(:,1))));
% stdRight = std(vepsLeftUS,[],1)/sqrt(sum(~isnan(vepsLeftUS(:,1))));
% shadedErrorBar(t*1e3,vepLeftUS,stdLeft,'lineprops',{'linestyle','-.','Color',cIdx(5,:),'linewidth',2})
% shadedErrorBar(t*1e3,vepRightUS,stdRight,'lineprops',{'linestyle','-.','Color',cIdx(6,:),'linewidth',2})
% plot(t*1e3,vepLeftUS,'-.',t*1e3,vepRightUS,'-.','linewidth',2);

xlabel('Time (ms)')
ylabel('Voltage (\muV)')
legend('Left LED','Right LED','Left LED+US','Right LED+US','Left US','Right US')
makeFigureBig(h);