%% Analyze EEG LSTIM Results: GAMMA
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\ProcessTask\EEGLib\');

if strcmp(sys.EEGSystem,'BCI')
    fName = 'C:\Users\Verasonics\Documents\OpenBCI_GUI\Recordings\OpenBCISession_gamma1_boltzmann20230131\OpenBCI-RAW-2023-01-31_13-18-46.txt';
    [t,eeg,digUs] = loadEegBci(fName,16);
    t = t-t(1);
elseif strcmp(sys.EEGSystem,'INTAN')
    pth = 'D:\calvin20230330\EEG\';
    fNameBase = 'test1p6V';
    [t,eeg,dig] = concatIntan(pth,fNameBase);
    digUs = dig(1,:)';
    eeg = mean(eeg,1)';
end
plotGamma_lstim(t,eeg,digUs,[8,13],'windowSize',0.1,'fftWindow',0.05,'verbose',0);
plotUeps(t,eeg,digUs,'notch',[59,61],'window',1,'verbose',1);
%% Analyze EEG LSTIM Results: VEPs
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\ProcessTask\EEGLib\');

if strcmp(sys.EEGSystem,'BCI')
    fName = {'C:\Users\Verasonics\Documents\OpenBCI_GUI\Recordings\OpenBCISession_2023-02-01_14-06-57\OpenBCI-RAW-2023-02-01_14-07-50.txt'};
    [t,eeg,digUs] = loadEegBci(fName,[14,16]);
    t = t-t(1);
    dt = 1/250;
    t = 0:dt:(length(t)-1)*dt;
    ledTrig = digUs(:,1);
    digUs = digUs(:,2);
elseif strcmp(sys.EEGSystem,'INTAN')
    pth = 'D:\calvin20230330\eeg\';
    fNameBase = 'calvin_2MPa_50pDC_Outside_VEPs_10msLED_3MinSonication';
    [t,eeg,dig,alg] = concatIntan(pth,fNameBase);

    % Low Pass Filter
%     disp('Low Pass Filtering...')
%     tic
%     wp = [300 450]; % Hz
%     mags = [1,0];
%     devs = [0.05 0.1];
%     [n,wn,beta,fType] = kaiserord(wp,mags,devs,20e3);
%     n = n+rem(n,2);
%     myFilt = fir1(n,wn,fType,kaiser(n+1,beta),'scale');
%     
%     for ii = 1:size(eeg,1)
%         tic
%         disp(['  Filtering Channel ', num2str(ii)])
%         eeg(ii,:) = filtfilt(myFilt,1,eeg(ii,:));
%         toc
%     end
%     toc
    digUs = dig(1,:)';
    alg(alg<3.3) = 0;
    alg(alg>=3.3) = 1;
    ledTrig = alg';
%     eeg = mean(eeg,1)';
eeg = eeg(2,:);
end
[vepB,vepP,tVep] = plotVeps(t,eeg,ledTrig,digUs,'notch',[59,61],'window',500e-3,'verbose',0);