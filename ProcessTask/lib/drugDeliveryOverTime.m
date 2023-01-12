function [tm,chEpp,chZero,chZeroBaseline,trialTm] = drugDeliveryOverTime(tData,tm,window,baselineWindow,verbose)

minTrials = round(window/5); % Require at least 1 trial/4 seconds during the relevant window

if ~exist('verbose','var')
    verbose = 0;
end
trialTm = zeros(size(tData.timing));
for ii = 1:length(tData.timing)
    trialTm(ii) = tData.timing(ii).startTime;
end

endFullDelays = find(abs(tData.delay)==max(tData.delay));
endFullDelays = endFullDelays(end);
if endFullDelays>500
    endFullDelays = 1;
    SIGMOID = true;
else
    SIGMOID = false;
end

delays = unique(tData.delay(endFullDelays+1:end));

[~,sonicationIdx] = max(diff(trialTm));
sonicationIdx = sonicationIdx+1;

preUsIdx = endFullDelays:sonicationIdx-1;
preUs = tData.ch(preUsIdx);
postUs = tData.ch(sonicationIdx:end);

trialTm = trialTm-trialTm(sonicationIdx);
% Get rid of the time used during the injection
trialTm(1:sonicationIdx-1) = trialTm(1:sonicationIdx-1)+(trialTm(sonicationIdx)-trialTm(sonicationIdx-1));

%% Set baseline (find point of equal probability) using all pre-US data.
% If the user specified a different baseline window, adjust to that window.
% Otherwise, use all preUS data with the relevant delays

if exist('baselineWindow','var') 
    if ~isempty(baselineWindow)
        preUsIdx = find(trialTm<0 & trialTm>-baselineWindow);
    end
else
    baselineWindow = -trialTm(preUsIdx(1));
end
if isempty(baselineWindow)
    baselineWindow = -trialTm(preUsIdx(1));
end

if sum(~isnan(tData.ch(preUsIdx)))/(baselineWindow) < 1/7
    preUsIdx = 1:length(tData.ch);
end
% sum(~isnan(tData.ch(preUsIdx)))
curCh = tData.ch(preUsIdx);
curDelay = tData.delay(preUsIdx);
chLin = nan(size(delays));
semLin = chLin;
for jj = 1:length(delays)
    chLin(jj) = mean(curCh(curDelay == delays(jj)),'omitnan');
    semLin(jj) = semOmitNan(curCh(curDelay==delays(jj)));
end
chZeroBaseline = mean(curCh(curDelay ==0),'omitnan');
if length(chLin)<5
    warning('Could not compute Epp')
    Epp = nan;
elseif ~SIGMOID
    if sum(isnan(chLin))
        warning('Could not compute Epp')
        Epp = nan;
    else
        p = fit(delays,chLin,'poly1');
        Epp = (0.5-p(2))/p(1);
    end
else
    [slope, bias, downshift, scale] = fitSigmoid(delays, chLin);
    Epp = equalProbabilityPoint(slope,bias,downshift,scale);
end
if verbose
    h = figure;
    hold on
    errorbar(delays,100*chLin,100*semLin,'*','linewidth',2,'MarkerSize',8)
    ylabel('Leftward Choices (%)')
    xlabel('Delay')
    axis([-50,50,0,100])
    makeFigureBig(h)
end

%% Plot all before and all after
if verbose
    h = figure;
    hold on
    bar(2:3,[mean(preUs,'omitnan'),mean(postUs,'omitnan')]*100,'BaseValue',50)
    eb = errorbar(2:3,[mean(preUs,'omitnan'),mean(postUs,'omitnan')]*100,...
        [semOmitNan(preUs,1),semOmitNan(postUs,1)]*100);
    set(eb,'linestyle','none','color','k')
    [~,p] = ttest2(preUs,postUs);
    sigstar([2,3],p)
    ylabel('Leftward Choices (%)')
    makeFigureBig(h)
end

ch = nan(size(tm));
chEpp = ch;
chZero = ch;
for ii = 1:length(tm)
    idx = find(trialTm>tm(ii) & trialTm<tm(ii)+window & ~isnan(tData.ch'));
    if length(idx)<minTrials
        if ii == 1
            warning('Less than 50 trials in five minutes preceding US')
        else
            chEpp(ii) = nan;
            continue;
        end
    end
    ch(ii) = mean(tData.ch(idx),'omitnan');
    curCh = tData.ch(idx);
    curDelay = tData.delay(idx);
    chLin = nan(size(delays));
    for jj = 1:length(delays)
        chLin(jj) = mean(curCh(curDelay == delays(jj)),'omitnan');
        semLin(jj) = semOmitNan(curCh(curDelay==delays(jj)));
    end
    if sum(isnan(chLin))
        chEpp(ii) = nan;
    else
        if ~SIGMOID
            p = fit(delays,chLin,'poly1');
            chEpp(ii) = Epp*p(1)+p(2);
        else
            [slope, bias, downshift, scale] = fitSigmoid(delays, chLin);
            % p50(ii) = equalProbabilityPoint(slope,bias,downshift,scale);

            % Bias at x0
            if exist('Epp','var')
                if ~isempty(Epp)
                    chEpp(ii) = sigmoid_ext(Epp,slope,bias,downshift,scale);
                end
            end
        end
    end
    
    chZero(ii) = mean(curCh(curDelay==0),'omitnan');
end