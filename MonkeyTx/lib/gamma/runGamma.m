% This file uses randomization without replacement to deliver a regular
% sonications across a specified range of acoustic parameters/target
% locations.
% 
% University of Utah
% Spring 2023

%% Add relevant paths
verasonicsPath = 'C:\Users\Taylor\Documents\Projects\verasonics\verasonics\';
addpath(genpath([verasonicsPath,'monkeyTx\']));

%% Sonication and Reward Timing
meanTimeBetweenSonications = 10; % seconds
jitterTimeBetweenSonications = 2; % seconds
rewardTime = 2; % seconds
jitterRewardTime = 0.5; % seconds
totalSessionTime = 60*60; % seconds

%% Sonication parameters
% Targeting
focalLocationLeft = [-9, -1.5, 57.5];
focalLocationRight = [9, -1.5, 58];
nFoci = [3,3,3];
focalDev = [2,4,4];

leftFoci = generateTargetBuckets(focalLocationLeft,nFoci,focalDev);
rightFoci = generateTargetBuckets(focalLocationRight,nFoci,focalDev);

totalParameters = numel(leftFoci)+numel(rightFoci);
nSonications = floor(totalSessionTime/(totalParameters*meanTimeBetweenSonications));

leftBuckets = nSonications*ones(size(leftFoci));
rightBuckets = nSonications*ones(size(rightFoci));

leftBuckets = leftBuckets(:);
rightBuckets = rightBuckets(:);

% Other parameters
dc = 100; % percent
duration = 100; % ms
voltage = 1.6;
prf = 100; % Hz
frequency = 0.480; % MHz
%% OUTPUT The resulting status
disp('**************Session INFO**************')
disp(['Total number of parameter sets: ', num2str(totalParameters)]);
disp(['Expected Session Time: ',...
    num2str(nSonications*totalParameters*meanTimeBetweenSonications/60,2),...
    ' mintues'])
disp(['Number of sonications per parameter: ', num2str(nSonications)])
disp('****************************************')

%% Set Function Generator
% FG694VISA = 'USB0::0x0957::0x2A07::MY52600694::0::INSTR';
FG694VISA = 'USB0::0x0957::0x2A07::MY52600670::0::INSTR';

if ~exist('fg1','var')
    fg1 = establishKeysightConnection(FG694VISA);
end
if strcmp(fg1.Status, 'closed')
    fopen(fg1);
end

% Set channel 1 (reward)
setFgWaveform(fg1,1,'SQU',1e-6,5e3,2.5e3,50,5);
setFgBurstMode(fg1,1,1);
outpOn(fg1,1);

% Set channel 2 (trigger)
isi = meanTimeBetweenSonications;
fgPRF = 2.1/(isi)*1e-6;
setFgWaveform(fg1,2,'SQU',fgPRF,3.3e3,1.65e3,'INF',duration*1e-3*fgPRF*1e6*100);

setFgBurstMode(fg1,2,1);
setFgTriggerMode(fg1,2,'EXT',0,'NEG'); 

outpOn(fg1,2);
return
%% Begin session!
logPath = 'C:\Users\Taylor\Documents\tmp\';
verasonicsLogName = [logPath, 'verasonicsLog.mat'];
logFile = [logPath, 'test20230504.mat'];
sonicationsRemain = 1;
if randi(2) == 1
    curTarget = -1;
else
    curTarget = 1;
end
while sonicationsRemain
    % Select parameters
    if curTarget == -1
        idx = selectSonication(leftBuckets);
        [a,b,c] = ind2sub(size(leftBuckets),idx);
        curFocus = leftFoci{a,b,c};
    elseif curTarget == 1
        idx = selectSonication(rightBuckets);
        [a,b,c] = ind2sub(size(rightBuckets),idx);
        curFocus = rightFoci{a,b,c};
    end

    % Setup Verasonics code
    % doppler256_neuromodulate2_spotlight(duration, voltage, curFocus, PRF, duty, frequency, verasonicsLogName, JAB800, [0,0,0], [0,0,0]);
    
    waitTime = meanTimeBetweenSonications+rand(1)*jitterTimeBetweenSonications*2-jitterTimeBetweenSonications;
    rewardWaitTime = waitTime-(rewardTime+rand(1)*2*jitterRewardTime-jitterRewardTime);
    
end