% eegSpectra finds delta, theta, alpha, gamma, and a generic FFT for the
% eeg data in eeg. The time vectors should be aligned to the ultrasound
% stimulus so that the results can be easily averaged. The window in which
% the ultrasound begins begins at windowTime==0
% 
% @INPUTS
%   t: cell array of time vectors corresponding to eeg data. Should be
%     centereed such that the US onset is at t=0
%   eeg: Cell array of eeg vectors (can be 2D)
%   window: Desired length of window over which to perform the FFT
% 
% @OUTPUTS
%   spectra: Struct of the same length as t with the following fields
%       windowTime: The beginning of each of the windows across which the
%         FFT was computed. This is relative to the onset of US.
%       delta: Measure of delta band at windowTime
%       theta: Measure of theta band at windowTime
%       alpha: Measure of alpha band at windowTime 
%       beta: Measure of beta band at windowTime
%       gamma: Measure of gamma band at windowTime
%       all0to100: All FFT values between 0 and 100 Hz at windowTime
%       frequencies: The frequencies corresponding to all0to100
% 
% Taylor Webb
% 20 May 2022
function spectra = eegSpectra(t,eeg,window,overlap)
if ~exist('overlap','var')
    overlap = 0;
end
if ~iscell(t)
    error('Expected cell array')
end

if length(t) ~= length(eeg)
    error('t and eeg must have the same length');
end

for hh = 1:length(t)
    disp(['Session ',num2str(hh),' of ',num2str(length(t))])
    if length(t{hh}) == 1
        continue;
    end
    if length(t{hh}) ~= size(eeg{hh},2)
        error('Length of t must equal the size of the first dimension of eeg')
    end
    
    windowTimeMin = ceil(t{hh}(1)/window)+1;
    windowTimeMax = floor(t{hh}(end)/window)-1;
    windowTime = (window*windowTimeMin):window*(1-overlap):(window*windowTimeMax);
    nWindows = length(windowTime)-1;
    
    delta = nan(size(eeg{hh},1),nWindows);
    theta = nan(size(eeg{hh},1),nWindows);
    alpha = nan(size(eeg{hh},1),nWindows);
    beta = nan(size(eeg{hh},1),nWindows);
    gamma = nan(size(eeg{hh},1),nWindows);
    
    dt = abs(t{hh}(2)-t{hh}(1));
    nSamples = floor(window/dt);
    nSampleJump = ceil(nSamples*(1-overlap))
    if ~mod(nSamples,2)
        nSamples = nSamples-1;
    end
    
    f = linspace(-1/(2*dt),1/(2*dt),nSamples);
    deltaIdx = find(f>0 & f<=3);
    thetaIdx = find(f>3 & f<=7);
    alphaIdx = find(f>7 & f<=12);
    betaIdx = find(f>12 & f<=30);
    gammaIdx = find(f>30 & f<=100);
    genericIdx = find(f>=0 & f<=320);
    generic = nan(size(eeg{hh},1),nWindows,length(genericIdx));
    fGeneric = f(genericIdx);
    if isempty(deltaIdx)
    %     keyboard
        warning('Insufficient resolution to measure delta');
        delta = nan;
    end
    if isempty(thetaIdx)
        warning('Insufficient resolution to measure theta');
        theta = nan;
    end
    if isempty(alphaIdx)
        warning('Insufficient resolution to measure alpha');
        alpha = nan;
    end
    if isempty(betaIdx)
        warning('Insufficient resolution to measure beta');
        beta = nan;
    end
    if isempty(gammaIdx)
        warning('Insufficient resolution to measure gamma');
        gamma = nan;
    end
    curT = t{hh};
    curEegTot = eeg{hh};
    wt2 = zeros(1,nWindows);
    [~,curOffset] = min(abs(windowTime(1)-curT));
    for ii = 1:size(eeg{hh},1)
        disp(['  Channel ', num2str(ii), ' of ', num2str(size(eeg{hh},1))])
        if sum(isnan(eeg{hh}(ii,:)))
            continue;
        end
        tic
        for jj = 1:nWindows
            if ~mod(jj,1e3)
                disp(['    Window ', num2str(jj), ' of ', num2str(nWindows)])
                disp(['      Elapsed Time: ', num2str(toc), ' s'])
            end
            curIdx = (((jj-1)*nSampleJump+1):(jj-1)*nSampleJump+nSamples)+curOffset;
            wt2(jj) = curT(curIdx(1));
            curEeg = curEegTot(ii,curIdx);
            if isempty(curEeg)
                continue
            end
            if max(abs(curEeg))>100
                continue
            end
            curFft = fftshift(fft(curEeg));
            curFft = 1/length(curEeg)*curFft.*conj(curFft);
            delta(ii,jj) = mean(curFft(deltaIdx));
            theta(ii,jj) = mean(curFft(thetaIdx));
            alpha(ii,jj) = mean(curFft(alphaIdx));
            beta(ii,jj) = mean(curFft(betaIdx));
            gamma(ii,jj) = mean(curFft(gammaIdx));
            if gamma(ii,jj)>1e6
                keyboard
            end
            generic(ii,jj,:) = curFft(genericIdx);
            keyboard
        end
    end
    
    if max(abs(wt2-windowTime(1:end-1))>1e-3)
        warning('Something is wrong in the timing!')
    end

    spectra(hh) = struct('delta',delta,'theta',theta,'alpha',alpha,'beta',beta,...
        'gamma',gamma,'all0to100',generic,'frequencies',fGeneric,...
        'windowTime',wt2);
end

if ~exist('spectra','var')
    spectra(hh) = struct('delta',nan,'theta',nan,'alpha',nan,'beta',nan,...
        'gamma',nan,'all0to100',nan,'frequencies',nan,...
        'windowTime',nan);
end