% alignVerasonicsArduino finds the arduino message delivered berfore each
% trigger. It makes no assumptions about how long before the trigger the
% message should have been delivered - it simply finds the most recent
% message at each trigger. It is possible for multiple triggers to find the
% same message - this likely happens at the beginning of a session when
% initial setup of the function generator and skull imaging is occuring.
% 
% @INPUTS
%   numIdx: Indices at which binary messages from the arduino are found
%   usTrigIdx: Indices at which a trigger from the function generator is
%       detected
%   t: time vector
% 
% @OUTPUTS
%   indices: A vector with the same length as usTrigIdx indicating what
%       message most immediately preceeds the detection of the US trigger
% 
% Taylor Webb
% taylor.webb@utah.edu
function indices = alignVerasonicsArduino(numIdx,usTrigIdx,t)

indices = nan(size(usTrigIdx));
for ii = 1:length(usTrigIdx)
    tmp = t(numIdx)-t(usTrigIdx(ii));
    tmp(tmp>0) = inf;
    if sum(isinf(tmp)) == length(tmp)
        curNumIdx = nan;
    else
        [~,curNumIdx] = min(abs(tmp));
    end
    indices(ii) = curNumIdx;
end