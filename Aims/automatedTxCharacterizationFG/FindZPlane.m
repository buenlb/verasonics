close all; clearvars -except fg; clc;

setPaths();

%% User Defined Variables
saveResults = 0;
saveDirectory = 'C:\Users\Verasonics\Box Sync\TransducerCharacterizations\HNR0500\';

%% User Defined Variables
% Define the grid
% Start and end points for x and y axis
Grid.xStart     = -5; 
Grid.xEnd       =  5;
Grid.yStart     = -5;
Grid.yEnd       =  5;

% length to scan along z-axis
% Grid.zLength = 20; 
Grid.zStart = 10;
Grid.zEnd = 100;

% time to wait in ms after positioner moves before acquiring data
Grid.pause = 100;

% Set grid spacing. If not set these will be automatically set to lambda/4
Grid.dx = .25;
Grid.dy = .25;
Grid.dz = 10;

% Set the parameter to measure on the grid
% Grid.parameters = 'Pulse Intensity Integral';
Grid.parameters = 'Negative Peak Voltage';

% Determine wether or not to record waveforms at each individual location.
Grid.recordWaveforms = 0;

% Transducer Parameters
Tx.frequency        = 1.0; % Frequency in MHz
Tx.diameter         = 0.75*25.4; % aperture diameter in mm
Tx.focalLength      = 0; % Focal length in mm. Use zero if Tx is unfocused
Tx.serial = '707171';
Tx.model = 'OLYMPUS PANAMETRICS -NDT- V314';
Tx.cone = 'none';
Tx.coneEdge = 0;

%% Function Generator Parameters
FgParams.amplifierModel = 'ENI A150';
FgParams.amplifierSerial = '1305';
FgParams.gridVoltage = 100; % FG voltage for full grid (mVpp)
FgParams.maxVoltage = 500; % max FG voltage when testing Tx efficiency (mVpp)
FgParams.minVoltage = 50; % min FG voltage when testing Tx efficiency (mVpp)
FgParams.frequency = Tx.frequency; % center frequency in MHz
FgParams.nCycles = 100; % number of cicles in pulse
% For long pulses use a burst period that results in 0.1% duty cycle to be
% extra careful with hydrophone.
FgParams.burstPeriod = 1000*FgParams.nCycles/Tx.frequency/1e3; % burst period in ms

% Pre-Amp Info
PreAmp.model = 'None';
PreAmp.serial = 'None';
PreAmp.calDate = 'None';

% Hydrophone Info
Hydrophone.model = 'HNR0500';
Hydrophone.serial = '1546';
Hydrophone.calDate = '18-Aug-2008';
Hydrophone.rightAngleConnector = 'true';
% Calibration file for 0.25-1 MHz
% Hydrophone.calibrationFile = 'C:\Users\Verasonics\Desktop\Taylor\Code\Aims\Calibrations\Combined\HGL0200-1782_AG2010-1199-20_xx_20190129.txt';
% Calibration file for 1-20 MHz with connector
% Hydrophone.calibrationFile = 'C:\Users\Verasonics\Desktop\Taylor\Code\Aims\Calibrations\Combined\HGL0200-1782_AG-2010-1199_OndaCombineCal_20190129_1-20MHz_withConnector.txt';
% Calibration file for 20-40 MHz
% Hydrophone.calibrationFile = 'C:\Users\Verasonics\Desktop\Taylor\Code\Aims\Calibrations\Combined\HGL0200-1782_AG2010-1199-20_xx_20190129_20-40.txt';
% Calibration file for Navid's hydrophone With our Amp
% Hydrophone.calibrationFile = 'C:\Users\Verasonics\Desktop\Taylor\Code\Aims\Calibrations\HGL1000 Calibration\combinedWithOurAmp.txt';
% Calibration file for Navid's hydrophone open circuit
% Hydrophone.calibrationFile = 'C:\Users\Verasonics\Desktop\Taylor\Code\Aims\Calibrations\HGL1000 Calibration\HGL1000-1745_xxxxxx-xxxx-xx_xx_20180622.txt';
% Calibration file for Doug's Hydrophone
Hydrophone.calibrationFile = 'C:\Users\Verasonics\Desktop\Taylor\Code\Aims\Calibrations\HNR0500_1546\readFromPaper.txt';

%% Run findCalibration so that the user is notified right away if the
% calibration file appears to be the wrong one.
findCalibration(Tx.frequency,Hydrophone.calibrationFile,1);

saveDirectory = [saveDirectory,num2str(Tx.frequency),'MHz\',Tx.model,'\cone_',Tx.cone,'\'];
if ~exist(saveDirectory,'dir')
    mkdir(saveDirectory);
elseif exist([saveDirectory,'report'],'dir')
    disp('This transducer has been characterized before.')
    disp('What do you want me to do?')
    disp(['Current Path: ', saveDirectory])
    disp('  c: cancel')
    disp('  o: repeat and overwrite')
    disp('  s: repeat and save both copies')
    decision = input('>','s');
    switch decision
        case 'c'
            error('Terminated by user')
        case 'o'
            % do nothing - it will overwrite by default
        case 's'
            dirIdx = 2;
            newDirectory = [saveDirectory(1:end-1),'_',num2str(dirIdx),'\'];
            while exist(newDirectory,'dir') && exist([newDirectory,'report'],'dir')
                dirIdx = dirIdx+1;
                newDirectory = [saveDirectory(1:end-1),'_',num2str(dirIdx),'\'];
            end
            saveDirectory = newDirectory;
            mkdir(saveDirectory);
        otherwise
            error([decision, ' is not a valid input. Please choose c, o, or s'])
    end
end
%% Prep Soniq
% Connect to Soniq
lib = loadSoniqLibrary();
openSoniq(lib);

% Error check Tx Struct and compute effective focal length
Tx = initializeTx(Tx);

% Set up grid values. This just fills in defaults for any empty fields
Grid = initializeGrid(lib,Grid,Tx);

% Set record keeping transducer stuff in Soniq
setTxParams(lib,Tx,FgParams);

% Set the Oscope parameters based on frequency
% Compute the Oscope time base such that there are at least 22 samples per
% wavelength. This ensures that regardless of phase shift we will always
% measure 0.99 of the peak voltage.
if FgParams.nCycles > 50
    windowLength = 2*FgParams.nCycles/FgParams.frequency;
else
    windowLength = 8*FgParams.nCycles/FgParams.frequency;
end
timeBase = windowLength/10;
setOscopeParameters(lib,{'timeBase',timeBase,'averages',Grid.averages});
actualTimeBase = calllib(lib,'GetScopeTimebase');
actualWindowLength = actualTimeBase*10;
dt = 1/(22*FgParams.frequency);
nSamples = ceil(actualWindowLength/(dt));
setOscopeParameters(lib,{'nSamples',nSamples});
nSamplesActual = calllib(lib,'GetScopePoints');
idx = 1;
while nSamplesActual < nSamples
    setOscopeParameters(lib,{'nSamples',(idx+1)*nSamples});
    nSamplesActual = calllib(lib,'GetScopePoints');
    idx = idx+1;
end

%% Estimate Scan Time
time = estimateCharacterizationTime(Grid,Tx,FgParams);
disp(['Estimated Time: ', time])

%% Prep function generator
if ~exist('fg','var')
  fg = establishKeysightConnection('USB0::0x0957::0x2A07::MY52600670::0::INSTR');
end
if strcmp(fg.Status, 'closed')
    fopen(fg);
end
%%
setFgBurstMode(fg,Tx.frequency,FgParams.gridVoltage,FgParams.burstPeriod,FgParams.nCycles);

%% Confirm Soniq Settings
Pos = verifyPositionerSettings(lib,Tx);

%% Write a readme file with details of the characterization
writeReadme(Tx,Grid,FgParams,Hydrophone,PreAmp,saveDirectory);

%% Find the center
tic
%disp(['2D scan at Z = ',num2str(zLoc)]);
lambda = 1490000/(Tx.frequency*1e6); % wavelength in mm
data = soniq2dScan(lib,[Pos.Y.Axis,Pos.Z.Axis],[-7.5,15],[7.5,100],[round(15/0.25),round(85/0.25)],{'parameter',Grid.parameters,'pause',Grid.pause});
imagesc(data.x,data.y,data.data);
axis image
drawnow



%% Close connection
setFgBurstMode(fg,Tx.frequency,0,FgParams.burstPeriod,1);
closeSoniq(lib);