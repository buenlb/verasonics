function beam = receiveBeamformer(rData,ns,delays,dt,target,frequency)
if mod(size(rData,1),ns)
    error('size(rData,1) must be an integer multiple of ns')
end

nBeams = size(rData,1)/ns;
beam = zeros(size(rData,1),1);
for ii = 1:nBeams
    curIdx = (ii-1)*ns+1:ii*ns;
    data = rData(curIdx,:);
    for jj = size(rData,2)
        nSamples = round(delays{target}(jj)/(frequency*1e6)/dt);
        data(:,jj) = circshift(data(:,jj),nSamples);
        if nSamples > 0
            data(1:nSamples,jj) = 0;
        else
            data(end-nSamples+1:end,jj) = 0;
        end
    end
    beam(curIdx) = sum(data,2);
end