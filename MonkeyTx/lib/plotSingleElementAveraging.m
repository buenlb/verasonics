function plotSingleElementAveraging(RData)
persistent figHandle;
Receive = evalin('base','Receive');
Resource = evalin('base','Resource');
% 
if isempty(figHandle)
    figHandle = figure;
end
figure(figHandle);
% 
t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);

accum = zeros(size(Receive(1).startSample:Receive(1).endSample));
for ii = 1:length(Receive)
    accum = double(RData(Receive(ii).startSample:Receive(ii).endSample,Resource.Parameters.ioChannel))'+accum;
end
accum = accum/Resource.Parameters.numAvg;
plot(t,accum)
axis([0,max(t),-10000,10000])
drawnow
return