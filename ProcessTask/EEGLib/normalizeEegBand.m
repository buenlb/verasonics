% Takes the eeg struct created by fullEegAnalysis and finds the percent
% change in the frequency band specified by bnd ([lowFreqCutoff,
% highFreqCutoff]). 

function [bndOut,leftBndOut,rightBndOut] = normalizeEegBand(eeg,bnd,tAvg,windowSize)
fIdx = find(eeg(1).frequencies>bnd(1) & eeg(1).frequencies <=bnd(2));

bndOut = nan(length(eeg),length(tAvg));
leftBndOut = bndOut;
rightBndOut = bndOut;
for ii = 1:length(eeg)
    disp(['Session ', num2str(ii), ' of ', num2str(length(eeg))]);
    if isempty(eeg(ii).features)
        continue;
    end
    curBnd = real(mean(eeg(ii).features(fIdx,:),1,'omitnan'));
    curBnd = temporalAverageSynchronized(curBnd,eeg(ii).tFeatures,tAvg,windowSize);
    bndOut(ii,:) = (curBnd-curBnd(tAvg==0))/curBnd(tAvg==0);
%     bndOut(ii,:) = (curBnd)/curBnd(tAvg==0);

    curBnd = squeeze(real(eeg(ii).featuresByPins(2,:,:)))';
    curBnd = mean(curBnd(fIdx,:),1,'omitnan');
    curBnd = temporalAverageSynchronized(curBnd,eeg(ii).tFeatures,tAvg,windowSize);
    leftBndOut(ii,:) = (curBnd-curBnd(tAvg==0))/curBnd(tAvg==0);
%     leftBndOut(ii,:) = (curBnd)/curBnd(tAvg==0);

    curBnd = squeeze(real(eeg(ii).featuresByPins(1,:,:)))';
    curBnd = mean(curBnd(fIdx,:),1,'omitnan');
    curBnd = temporalAverageSynchronized(curBnd,eeg(ii).tFeatures,tAvg,windowSize);
    rightBndOut(ii,:) = (curBnd-curBnd(tAvg==0))/curBnd(tAvg==0);
%     rightBndOut(ii,:) = (curBnd)/curBnd(tAvg==0);
end