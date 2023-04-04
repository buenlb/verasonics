% behaviorOverTime returns the equal probability point, the choices at a
% baseline equal probability point (if that baseline, p0, is provided), the
% average leftward choices at delay equals zero and the average leftward
% choices across all delays during the windows specified by tm and
% timeWindow. 
% 
% @INPUTS
%   tData: Struct returned by processTaskDataDurable
%   tm: Time vector. The function will return results in windows defined by
%     a combination of tm and timeVector. Each window starts at each value
%     of tm and extends timeWindow into the future. tm should be given in
%     seconds and is centered around t=0 as defined by usBlock in tData.
%   timeWindow: extend of each window in seconds
%   p0: Optional. Sets the baseline point for computing the bias returned
%     in y
% 
% @OUTPUTS
%   p50: equal probability point
%   y: Bias at p0. If p0 is not provided this will be nan
%   m: bias at delay=0
%   all: bias across all delays
% 
% Taylor Webb
% University of Utah
% 5th October, 2022

function [p50,y,m,all,chVectors,dVectors,err] = behaviorOverTime2(tData,tm,timeWindow,p0,verbose)
if ~exist('verbose','var')
    verbose = 0;
end
if exist('p0','var')
    if isempty(p0)
        clear p0;
    end
end
m = nan(size(tm));
y = nan(size(tm));
p50 = nan(size(tm));
all = nan(size(tm));
err = all;
chVectors = nan(5,length(tm));
dVectors = chVectors;
for ii = 1:length(tm)
    curWindow = [tm(ii)-timeWindow,tm(ii)];
    idx = getTrialsByTime(tData,curWindow);
    correctDelays = logical(tData.correctDelay);
    idx = idx(correctDelays(idx));
    if sum(~isnan(tData.ch(idx)))<timeWindow/10
        % disp('Not enough trials for sigmoid fit')
        continue
    end
    [~,slope,bias,downshift,scale,delays,yD,err(ii)] = plotSigmoid(tData,idx);
    if length(delays)~=5
%         disp('Incorrect number of delays for sigmoid fit')
    else
        chVectors(:,ii) = yD;
        dVectors(:,ii) = delays;
        p50(ii) = equalProbabilityPoint(slope,bias,downshift,scale);
        if exist('p0','var')
            y(ii) = sigmoid_ext(p0,slope,bias,downshift,scale);
    %         p50(ii) = p50(ii)-p0;
        end
    end
    if verbose
        x = linspace(min(delays),max(delays),1e3);
        tmpY = sigmoid_ext(x,slope,bias,downshift,scale);
        h = figure(99);
        clf;
        ax = gca;
        plot(x,100*tmpY,'-','linewidth',2);
        hold on
        ax.ColorOrderIndex = 1;
        plot(delays,100*yD,'o','linewidth',2,'markersize',8)
        if tm(ii)>0
            tmpIdx = find(tm==0);
            ch0 = chVectors(:,tmpIdx);
            d0 = dVectors(:,tmpIdx);
            [slope0, bias0, downshift0, scale0, err] = fitSigmoid(d0,ch0);
            tmpY = sigmoid_ext(x,slope0,bias0,downshift0,scale0);
            plot(x,100*tmpY,'k-','linewidth',2)
        end
        grid on
        xlabel('delays (ms)')
        ylabel('Leftward Choices (%)')
        title(['Time = ',num2str(tm(ii)/60), ' minutes.'])
        makeFigureBig(h);
        axis([min(delays),max(delays),0,100])
    end
    m(ii) = yD(delays==0);
    % all(ii) = mean(tData.ch(idx),'omitnan');
    all(ii) = mean(yD);
end