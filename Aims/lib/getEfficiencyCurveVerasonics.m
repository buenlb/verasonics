function getEfficiencyCurveVerasonics(lib,saveDirectory)

saveLocation = [saveDirectory,'efficiencyCurve\'];
mkdir(saveLocation);

keepGoing = 1;
while keepGoing
    vIn = input('input voltage?>');
    getSoniqWaveform(lib,[saveLocation, 'wv_',num2str(vIn),'mVpp.snq']);
    keepGoing = input('Continue (0/1)?>');
end