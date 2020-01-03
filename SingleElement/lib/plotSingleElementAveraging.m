function plotSingleElementAveraging(RData)
persistent figHandle;
Receive = evalin('base','Receive');
Resource = evalin('base','Resource');
% 
if isempty(figHandle)
    figHandle = figure;
end
try
    figure(figHandle);
catch
    clear figHandle;
    figHandle = figure;
end
% 
t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);
d = t*1492*1e-3/2;
accum = zeros(size(Receive(1).startSample:Receive(1).endSample));
for ii = 1:length(Receive)
    accum = double(RData(Receive(ii).startSample:Receive(ii).endSample,Resource.Parameters.ioChannel))'+accum;
end
accum = accum/Resource.Parameters.numAvg;
plot(d,accum)
xlabel('Distance (mm)')
ylabel('voltage (V)')
axis([0,max(d),-100,100])
drawnow
return