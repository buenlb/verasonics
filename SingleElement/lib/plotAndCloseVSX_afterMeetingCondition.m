function plotAndCloseVSX_afterMeetingCondition(RData)
persistent figHandle;
Receive = evalin('base','Receive');
Resource = evalin('base','Resource');
% 
if isempty(figHandle)
    figHandle = figure;
end
h = figure(figHandle);
set(h,'position',[15   562   560   420]);
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

if exist(Resource.Parameters.closeFileName,'file')
    VSXquit();
else
    fid = fopen('acquireWaveform.taylor','w');
    fwrite(fid,magic(5),'integer*4');
    fclose(fid);
end
return