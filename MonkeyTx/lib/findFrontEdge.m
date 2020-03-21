% findFrontEdge finds the front edge of a signal by first relying on the
% threshold and then finding where the signal derivative goes negative.
% The code assumes an envelope and not a raw signal.

function idx = findFrontEdge(signal, threshold)
idx = find(signal>threshold);
if isempty(idx)
    idx = nan;
    return
end
idx = idx(1);

difS = diff(signal);

while difS(idx-1) > 0
    idx = idx-1;
end