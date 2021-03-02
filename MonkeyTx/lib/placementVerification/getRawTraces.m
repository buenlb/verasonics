function [gsRaw,crRaw,t,d] = getRawTraces(gs,cr,singleElement)

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