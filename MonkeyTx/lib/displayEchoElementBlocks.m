function displayEchoElementBlocks(RcvData,Receive,Trans)

RcvData = RcvData{1};

elements = selectElementBlocks(5);

echo = zeros(length(elements),Receive(1).endSample-Receive(1).startSample+1);
for ii = 1:length(elements)
    curData = zeros(Receive(1).endSample-Receive(1).startSample+1,1);
    for jj = 1:length(elements{1})
        tmpData = RcvData(Receive(ii).startSample:Receive(ii).endSample,elements{ii}(jj));
        curData = curData+abs(hilbert(double(tmpData)));
    end
    echo(ii,:) = curData;
end

keyboard