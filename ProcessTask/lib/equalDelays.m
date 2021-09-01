% equalDelays makes sure that the number of trials acquired at the negative
% delay is equal to the number of trials at the positive delay. If they are
% not equal, trials are removed (set to nan) until they are equal. Trials 
% are taken from the beginning of the vector.
% 
% @INPUTS
%   delay: vector of delays
%   ch: vector of left/right choices
%   delayVector: possible delays
% 
% @OUTPUTS
%   delay: vector of delays corrected to have equal trials
%   ch: vector of choices corrected to have equal trials
%   idxRemoved: index into original ch and delay vectors of trials that
%     were removed

function [delay,ch,idxRemoved] = equalDelays(delay,ch,delayVector)

idxRemoved = [];
for ii = 1:floor(length(delayVector)/2)
    if delayVector(ii)~=-delayVector(end-ii+1)
        error('Expected symmetric delay vector!')
    end
    negTrials = sum(delay==delayVector(ii) & ~isnan(ch));
    posTrials = sum(delay==delayVector(end-ii+1) & ~isnan(ch));
    if negTrials>posTrials
        idx = find(delay==delayVector(ii));
        idxRemoved = cat(1, idxRemoved, idx(1:(negTrials-posTrials)));
    elseif negTrials<posTrials
        idx = find(delay==delayVector(end-ii+1));
        idxRemoved = cat(1, idxRemoved, idx(1:(posTrials-negTrials)));
    end
end
delay(idxRemoved) = nan;
ch(idxRemoved) = nan;
