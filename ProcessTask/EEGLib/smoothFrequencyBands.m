% smoothFrequencyBands takes the frequency bands in the struct bands and
% smooths the result in time by averaging across the smaller windows
% (specified by tWindow in the struct bands - see eegSpectra for a detailed
% explanation of fields in bands)
% 
% @INPUTS
%   bands: struct with frequency data (see eegSpectra for details)
%   window: size of window (in seconds) over which to average
%   windowSep: separation of windows in time (to allow for rolling
%     averages)
% 
% @OUTPUTS
%   bands: struct the same size and fields as bands but with smoothed
%     results
% 
% Taylor Webb
% 20 May 2022

function bands = smoothFrequencyBands(bands,window,windowSep)

for ii = 1:length(bands)
    disp(['Processing struct ', num2str(ii), ' of ', num2str(length(bands))])
    if length(bands(ii).windowTime)<2
        continue
    end
    dt = abs(bands(ii).windowTime(2)-bands(ii).windowTime(1));

    % Error Checking
    if abs(round(window/dt)-window/dt)>100e-3
%         keyboard
        warning(['Window should be an integer multiple of the FFT windows (',num2str(dt),'s)'])
    end
    if abs(round(windowSep/dt)-windowSep/dt)>100e-3
        error(['Window separation should be an integer multiple of the FFT windows (',num2str(dt),'s)'])
    end
    if mod(window,windowSep)
        error('Window must be an integer multiple of window separation');
    end

    curTm = bands(ii).windowTime;
    windowTimeMin = floor(curTm(1)/window);
    windowTimeMax = floor(curTm(end)/window);
    windowTime = (window*windowTimeMin):windowSep:(window*windowTimeMax);
    nWindows = length(windowTime)-1;
    
    delta = nan(size(bands(ii).delta,1),nWindows);
    theta = nan(size(bands(ii).delta,1),nWindows);
    alpha = nan(size(bands(ii).delta,1),nWindows);
    beta = nan(size(bands(ii).delta,1),nWindows);
    gamma = nan(size(bands(ii).delta,1),nWindows);
    hGamma = nan(size(bands(ii).delta,1),nWindows);
    all = nan(size(bands(ii).all0to100,1),nWindows,size(bands(ii).all0to100,3));
    for jj = 1:nWindows
        curIdx = find(curTm>windowTime(jj) & curTm<=windowTime(jj+1));
        for kk = 1:size(delta,1)
            delta(kk,jj) = mean(bands(ii).delta(kk,curIdx),'omitnan');
            theta(kk,jj) = mean(bands(ii).theta(kk,curIdx),'omitnan');
            alpha(kk,jj) = mean(bands(ii).alpha(kk,curIdx),'omitnan');
            beta(kk,jj) = mean(bands(ii).beta(kk,curIdx),'omitnan');
            gamma(kk,jj) = mean(bands(ii).gamma(kk,curIdx),'omitnan');
        end
        for kk = 1:size(all,1)
            for ll = 1:size(all,3)
                all(kk,jj,ll) = mean(bands(ii).all0to100(kk,curIdx,ll),'omitnan');
            end
        end
    end
    bands(ii).delta = delta;
    bands(ii).theta = theta;
    bands(ii).alpha = alpha;
    bands(ii).beta = beta;
    bands(ii).gamma = gamma;
    bands(ii).all0to100 = all;
    bands(ii).windowTime = windowTime(1:end-1);

%     bands(ii) = struct('delta',delta,'theta',theta,'alpha',alpha,'beta',beta,...
%         'gamma',gamma,'all0to100',all,'frequencies',bands(ii).frequencies,...
%         'windowTime',windowTime);
end