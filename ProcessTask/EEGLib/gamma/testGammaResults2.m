function [t,eeg,dig,testLog] = testGammaResults2()
%% Generate test data
log = load('D:\Gamma\Logs\boltzmann20230630.mat');

% Determine where to see results
gamma = [7,18];
alpha = [1,16];

% Setup fake EEG vectors
fs = 20e3;
t = 0:1/fs:3600;

gammaFreqs = 30:0.5:70;
lengthIncrease = 3;
gammaSig = zeros(1,lengthIncrease*fs);
for ii = 1:length(gammaFreqs)
    gammaSig = gammaSig+cos(2*pi*gammaFreqs(ii)*t(1:length(gammaSig))+randn(1)*pi);
end

alphaFreqs = 8:0.5:14;
lengthIncrease = 3;
alphaSig = zeros(1,lengthIncrease*fs);
for ii = 1:length(alphaFreqs)
    alphaSig = alphaSig+cos(2*pi*alphaFreqs(ii)*t(1:length(alphaSig))+randn(1)*pi);
end

nTargets = 12;
nSonicationsPerTarget = 10;
nSonications = nTargets*nSonicationsPerTarget*2;
tBetSonications = 12;

% Randomize targets
sonicationsLeft = 1:nTargets;
sonicationsLeft = repmat(sonicationsLeft,[10,1]);
sonicationsLeft = sonicationsLeft(:);
sonicationsLeft = sonicationsLeft(randperm(length(sonicationsLeft)));

sonicationsRight = (nTargets+1):(2*nTargets);
sonicationsRight = repmat(sonicationsRight,[10,1]);
sonicationsRight = sonicationsRight(:);
sonicationsRight = sonicationsRight(randperm(length(sonicationsRight)));

sonications = zeros(1,length(sonicationsLeft)*2);
sonications(1:2:end) = sonicationsLeft;
sonications(2:2:end) = sonicationsRight;

% Double check that I have the right number of sonications
if length(sonications)~=nSonications
    error('nSonications and length(sonications) must match!')
end

%% Set up a base eeg signal that we will add to after each sonication
eegLeft = randn(size(t));
eegRight = randn(size(t));

bitwidth = 1e-3*fs;
usTrigger = zeros(size(t));
binNum = zeros(size(t));

% Set up log structure to match data.
testLog = struct();
testLog.paramTable = log.paramTable;
tabId = 55;
for ii = 1:length(testLog.paramTable)
    testLog.paramTable(ii).TableID = tabId;
end
bNum = dec2bin(tabId);
bArray = zeros(1,10);
bArray(1) = 1;
bArray(end) = 1;
for jj = 1:length(bNum)
    bArray(end-length(bNum)+jj-1) = str2double(bNum(jj));
end
for jj = 1:length(bArray)
if bArray(jj)
    binNum(((jj-1)*bitwidth+2):(jj*bitwidth+1)) = 1;
end
end

% The code assumes one throwaway trigger
usTimeIdx = 2;
usTrigger(usTimeIdx:(usTimeIdx+100e-3*fs)) = 1;

for ii = 1:nSonications
    testLog.log(ii) = log.log(ii);
    if ~mod(ii,2)
        testLog.log(ii).leftIdx = nan;
        testLog.log(ii).rightIdx = sonications(ii);
    else
        testLog.log(ii).leftIdx = sonications(ii);
        testLog.log(ii).rightIdx = nan;
    end
    testLog.log(ii).params = rmfield(log.paramTable(sonications(ii)),'TableID');
    % Create signal for recorded sonication number sent by the arduino
    bTime = ii*tBetSonications-tBetSonications/2;
    bTimeIdx = round(bTime*fs);
    bNum = dec2bin(sonications(ii));
    bArray = zeros(1,10);
    bArray(1) = 1;
    bArray(end) = 1;
    for jj = 1:length(bNum)
        bArray(end-length(bNum)+jj-1) = str2double(bNum(jj));
    end
    for jj = 1:length(bArray)
        if bArray(jj)
            binNum((bTimeIdx+(jj-1)*bitwidth):(bTimeIdx+jj*bitwidth-1)) = 1;
        end
    end

    % Create signal for ultrasound trigger
    usTime = ii*tBetSonications;
    usTimeIdx = round(usTime*fs);
    usTrigger(usTimeIdx:(usTimeIdx+100e-3*fs)) = 1;
    
    % Add fake changes in EEG rhythms for certain sonication targets to
    % validate that we see this in the appropriate locations
    if ismember(sonications(ii),gamma)
%         eegLeft(usTimeIdx:(usTimeIdx+length(gammaSig)-1)) = eegLeft(usTimeIdx:(usTimeIdx+length(gammaSig)-1))+gammaSig;
        eegRight(usTimeIdx:(usTimeIdx+length(gammaSig)-1)) = eegRight(usTimeIdx:(usTimeIdx+length(gammaSig)-1))+gammaSig;
    end

    if ismember(sonications(ii),alpha)
%         eegLeft(usTimeIdx:(usTimeIdx+length(alphaSig)-1)) = eegLeft(usTimeIdx:(usTimeIdx+length(alphaSig)-1))+alphaSig;
        eegRight(usTimeIdx:(usTimeIdx+length(alphaSig)-1)) = eegRight(usTimeIdx:(usTimeIdx+length(alphaSig)-1))+alphaSig;
    end
end
eeg = [eegLeft;eegRight];
dig = [usTrigger;binNum];

save testLog testLog