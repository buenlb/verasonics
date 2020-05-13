function trace = getTrace(gridSize,centerElement,RcvData,Receive)
blocks = selectElementBlocks(gridSize);

for ii = 1:length(blocks)
    if blocks{ii}(ceil(gridSize^2/2)) == centerElement
        break
    end
end
blockIdx = ii;

s = zeros(size(RcvData(Receive(blockIdx).startSample:Receive(blockIdx).endSample,blocks{blockIdx}(1))));
for ii = 1:gridSize^2
    curS = double(RcvData(Receive(blockIdx).startSample:Receive(blockIdx).endSample,blocks{blockIdx}(ii)));
    s = curS+s;
end
trace = s;