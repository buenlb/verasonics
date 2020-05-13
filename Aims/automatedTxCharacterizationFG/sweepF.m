function sweepF(lib,fg,FgParams,flen,saveDirectory)
FgParams.frequency = 0.885;
FgParams.gridVoltage = 100;
fs = FgParams.frequency*1000-flen:FgParams.frequency*1000+flen;
fs = fs/1000;
fs = repmat(fs,1,3);
saveLocation = [saveDirectory,['txsweep',num2str(FgParams.frequency*1000)],'\'];
mkdir(saveLocation);

for ii=1:length(fs)
    setFgBurstMode(fg,fs(ii),FgParams.gridVoltage,FgParams.burstPeriod,FgParams.nCycles);
    pause(0.25);
    getSoniqWaveform(lib,[saveLocation, 'wv_',num2str(fs(ii)*1000),'kHz.snq']);
    [t,v(:,ii),p(ii,:),d(ii)] = readWaveform([saveLocation, 'wv_',num2str(fs(ii)*1000),'kHz.snq']);
   
end
save([saveLocation, 'vars',num2str(FgParams.frequency*1000)],'t','v','p','d','fs','FgParams')
setFgBurstMode(fg,0.270,0,FgParams.burstPeriod,FgParams.nCycles);

