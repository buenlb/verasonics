% getRawTraces gets the raw ultrasound data from the files gs and cr. gs
% usually points to a gold standard file acquired when the subject was in
% the MR. cr referes to a "current" file which is being compared to the
% gold standard.
% 
% @INPUTS
%   gs: full file name of mat file with gold standard data
%   cr: full file name of mat file wiht current data
%   singleElement: Specifies whether to load single element or gridded
%       element data
% 
% @OUTPUTS
%   gsRaw: NxM matrix of raw signals where N is the number of samples per
%       acquisition and M is the number of blocks
%   crRaw: Same as above but for the current data instead of the gold
%       standard data
%   t: time at which each sample is acquired (1XN matrix)
%   d: Approximate distance for each sample assuming a speed of sound of
%       1492 m/s
% 
% Taylor Webb
% University of Utah

function [gsRaw,crRaw,t,d] = getRawTraces(gs,cr,singleElement)

gs = load(gs);
cr = load(cr);

if ~singleElement
    gs = gs.griddedElRaw;
    cr = cr.griddedElRaw;
    gridSize = 3;
else
    gs = gs.singleElRaw;
    cr = cr.singleElRaw;
    gridSize = 1;
end

blocks = selectElementBlocks(gridSize);
Trans = transducerGeometry(0);

t = 1e6*(0:(cr.Receive(1).endSample-1))/(cr.Receive(1).ADCRate*1e6/cr.Receive(1).decimFactor);
d = t*1.492/2+cr.Receive(1).startDepth*cr.Resource.Parameters.speedOfSound/(Trans.frequency*1e6)*1e3;

for ii = 1:length(blocks)
    s = zeros(size(cr.RcvData(cr.Receive(ii).startSample:cr.Receive(ii).endSample,blocks{ii}(1))));
    for jj = 1:gridSize^2
        curS = double(cr.RcvData(cr.Receive(ii).startSample:cr.Receive(ii).endSample,blocks{ii}(jj)));
        s = curS+s;
    end
    crRaw(:,ii) = abs(hilbert(s));

    s = zeros(size(gs.RcvData(gs.Receive(ii).startSample:gs.Receive(ii).endSample,blocks{ii}(1))));
    for jj = 1:gridSize^2
        curS = double(gs.RcvData(gs.Receive(ii).startSample:gs.Receive(ii).endSample,blocks{ii}(jj)));
        s = curS+s;
    end
    gsRaw(:,ii) = abs(hilbert(s));
end