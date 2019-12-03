function displayEchoTest(RcvData,Trans,Receive)

RcvData = RcvData{1};

xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

for ii = 1:256
    s = RcvData(:,ii);
    s = s(Receive(ii).startSample:Receive(ii).endSample);
    tmp = find(abs(RcvData(:,ii))>1e-3);
    skullIdx(ii) = tmp(1);
end

plotPhases(xTx,yTx,zTx,skullIdx);
keyboard