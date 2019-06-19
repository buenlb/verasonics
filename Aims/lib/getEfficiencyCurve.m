function getEfficiencyCurve(lib,fg,FgParams,saveDirectory)

voltage = FgParams.minVoltage:50:FgParams.maxVoltage;
saveLocation = [saveDirectory,'efficiencyCurve\'];
mkdir(saveLocation);

for ii = 1:length(voltage)
    setFgBurstMode(fg,FgParams.frequency,voltage(ii),FgParams.burstPeriod,FgParams.nCycles);
    pause(5);
    getSoniqWaveform(lib,[saveLocation, 'wv_',num2str(voltage(ii)),'mVpp.snq']);
end

setFgBurstMode(fg,FgParams.frequency,voltage(1),FgParams.burstPeriod,FgParams.nCycles);