function [t,s,sCorrected] = plotTrace(RcvData,Receive,idx,figHandle)
if nargin <4
    plotResults = 0;
else
    figure(figHandle);
end
t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);

%% plot raw data
s = RcvData(Receive(idx).startSample:Receive(idx).endSample,idx);
if plotResults
    subplot(211)
    plot(t,s);
end

%% plot data after correction
transients = load('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\transientMeasurements.mat');
transSig = double(transients.RcvData{1}(Receive(idx).startSample:Receive(idx).endSample,idx));

sCorrected = s-transSig;
if plotResults
    subplot(212);
    plot(t,sCorrected);
end


