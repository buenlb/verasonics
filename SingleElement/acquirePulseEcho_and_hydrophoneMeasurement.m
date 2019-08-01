% This script acquires a pulse echo measurement using the Verasonics system
% and then acquires the with skull hydrophone measurement using Soniq. 
clear all; close all; clc;

addpath C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\SingleElement\lib\;
addpath C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\SingleElement\setupScripts\;
addpath C:\Users\Verasonics\Desktop\Taylor\Code\usDerivedDelay\lib\;

%% Pulse Echo Measurement
path = 'C:\Users\Verasonics\Box Sync\PulseEchoExperiments\13841\20190709\';
disp(['Current Save Path Is: ', path])

saveName = input('What should I name the file? ','s');

if exist([path,saveName],'file') || exist([path,saveName,'.mat'],'file')
    error('A file with that name already exists!')
end

singleElement_singleAcquisition_averagingByAcq
Resource.Parameters.closeFileName = 'tmpCloseVsx.taylor';
% Save all the structures to a .mat file.
%------------------------------------------------------------------------%
% An important note on VSX. VSX will clear the variable space and then load
% the mat file saved here. Therefore, after VSX runs only variables defined
% BEFORE this line will remain.
%------------------------------------------------------------------------%
save(svName);

fid = fopen(Resource.Parameters.closeFileName,'w');
fwrite(fid,magic(5),'integer*4');
fclose(fid);

filename = 'singleElement_singleAcquisition_averagingByAcq.mat';
VSX
save([path,saveName]);
clear all;
singleElement_singleAcquisition_averagingByAcq
load(svName)

system(['"C:\Program Files\MATLAB\R2017b\bin\matlab.exe" -r taylorRunVSX(''',Resource.Parameters.closeFileName,...
    ''',''', ['C:\Users\Verasonics\Desktop\Taylor\',saveName],''') &'])

delete(Resource.Parameters.closeFileName)
delete('acquireWaveform.taylor')

singleElement_singleAcquisition_averagingByAcq_manyCycles
Resource.Parameters.closeFileName = 'tmpCloseVsx.taylor';
save(svName);
filename = 'singleElement_singleAcquisition_averagingByAcq_manyCycles.mat';
VSX

movefile(['C:\Users\Verasonics\Desktop\Taylor\',saveName,'_withSkull.snq'],[path,saveName,'_withSkull.snq'])
if exist(['C:\Users\Verasonics\Desktop\Taylor\',saveName,'_noSkull.snq'],'file')
    movefile(['C:\Users\Verasonics\Desktop\Taylor\',saveName,'_noSkull.snq'],[path,saveName,'_noSkull.snq'])
    noSkullFile = 1;
    numPlots = 3;
else
    noSkullFile = 0;
    numPlots = 2;
end

delete(Resource.Parameters.closeFileName)

[t,beam] = processVSX([path,saveName]);

%% Plot Results
figure
subplot(numPlots,1,1)
plot(t,20*log10(abs(hilbert(beam))));
xlabel('\museconds')
ylabel('Voltage (dB)')
title('Pulse Echo Result')

[t,v] = readWaveform([path,saveName,'_withSkull.snq']);
subplot(numPlots,1,2)
plot(t,v)
xlabel('\museconds')
ylabel('Voltage (V)')
title('Hydrophone Result With Skull')

if noSkullFile
    [t,v] = readWaveform([path,saveName,'_noSkull.snq']);
    subplot(numPlots,1,3)
    plot(t,v)
    xlabel('\museconds')
    ylabel('Voltage (V)')
    title('Hydrophone Result Without Skull')
end
drawnow