%% Filter EEG signal
% [eeg,idx]=filterEEG(eeg,BANDPASS)
% 
% @INPUTS
%   eeg: eeg data
%   BANDPASS: if true a bandpass filter is used, otherwise it is a low pass
% 
% @OUTPUTS
%   eeg: Filtered Signal
%   idx: Index to use to match the filter delay on other recorded vectors
% 
% Taylor Webb
% University of Utah
% 4 May, 2022

function [eeg,idx] = filterEEG(eeg,BANDPASS)
if ~exist('BANDPASS','var')
    BANDPASS = 0;
end

if BANDPASS
    lp = 40;
    hp = 5;
    wp = [2 hp lp 50];
    mags = [0,1,0];
    devs = [0.2 0.01 0.2];
    [n,wn,beta,fType] = kaiserord(wp,mags,devs,20e3);
    n = n+rem(n,2);
    myFilt = fir1(n,wn,fType,kaiser(n+1,beta),'scale');
    delay = mean(grpdelay(myFilt,size(eeg,2),20e3));

    %% Filter
    eegFilt = zeros(size(eeg));
    eegFiltCorrected = zeros(size(eeg,1),size(eeg,2)-delay);
    for ii = 1:size(eeg,1)
        tic
        disp(['  Filtering Channel ', num2str(ii)])
        eegFilt(ii,:) = filter(myFilt,1,eeg(ii,:));
        eegFiltCorrected(ii,:) = eegFilt(ii,delay+1:end);
        toc
    end
    clear eegFilt;
    idx = 1:(size(eeg,2)-delay);
    eeg = eegFiltCorrected;
else
    lp = 200;
    wp = [lp 250];
    mags = [1,0];
    devs = [0.05 0.1];
    [n,wn,beta,fType] = kaiserord(wp,mags,devs,20e3);
    n = n+rem(n,2);
    myFilt = fir1(n,wn,fType,kaiser(n+1,beta),'scale');
    
    eegFiltCorrected = zeros(size(eeg));
    for ii = 1:size(eeg,1)
        tic
        disp(['  Filtering Channel ', num2str(ii)])
        eegFiltCorrected(ii,:) = filtfilt(myFilt,1,eeg(ii,:));
        toc
    end
    idx = 1:size(eeg,2);
    eeg = eegFiltCorrected;
end