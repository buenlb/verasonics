% Version changes:
%   8/22/19: Renamed to *_Arjun.  Kept original file. 
%
%   8/22/19: Changed transducer inputs so that it loads from file instead
%   of populating in the code.  
%
%   8/22/19: Changed cone inputs so that it loads from file instead of
%   populating in the code.  Adds onto Tx struct. 
%
%   8/22/19: Changed Hydrophone, Amplifier, and FG inputs so that it loads
%   from file instead of populating in the code.  Hydrophone is it's own
%   struct, Amplifier and FG adds to FgParams struct.

close all; clearvars -except fg; clc;

setPaths();

%% User Defined Variables
saveResults = 0;
saveDirectory = 'C:\Users\Verasonics\Box Sync\TransducerCharacterizations\HNR0500\';

% Define the grid
% Start and end points for x and y axis                                [mm]
Grid = createGrid(              ...
    [-10 10],                   ... X range
    [-10 10],                   ... Y range
    20,                         ... Z range
    [0.2 0.2 0.2],              ... increment in x, y, and z
    10,                         ... pause between measurements
    'Negative Peak Voltage',    ... parameter to measure
    0                           ... record waveform toggle
    );
% Grid = rmfield(Grid,'dx');
% Grid = rmfield(Grid,'dy');
% Grid = rmfield(Grid,'dz');

Tx = loadTransducerMatfile('technisonic ISL-0504-GP','61235');
Tx.computedFocus = 18;
Tx = loadCone(Tx,'none');
Tx.notes = '';
disp('Grid:');
disp(Grid);
disp(' ');
disp('Transducer + Cone:');
disp(Tx);
TxCheck = input('Check if transducer is correct: Continue? (y/n)','s');
switch lower(TxCheck)
    case 'y'
    case 'n'
        error('Transducer not correct (user input).');
    otherwise
        error('Invalid input.');
end
% Tx.cone = 'none'; % none if no cone is present
% Tx.coneEdge = 0; % zero if no cone is present                          [mm]

% optional field to set the starting x-y plane to a set distance.  Overwritten if transducer has a focus (i.e. Tx.focalLength is non-zero)


% Grid.xStart     = -10; 
% Grid.xEnd       = 10;
% 
% Grid.yStart     = -10;
% Grid.yEnd       = 10;
% 
% % length to scan along z-axis                                          [mm]
% Grid.zLength    = 20; 
% %Grid.zStart    = 5;
% %Grid.zEnd      = 35;
% 
% % time to wait in ms after positioner moves before acquiring data      [ms]
% Grid.pause = 10;
% 
% % Set grid spacing. If not set these will be automatically set to lambda/4
% %                                                                      [mm]
% Grid.dx = .25;
% Grid.dy = .25;
% Grid.dz = .25;
% 
% % Set the parameter to measure on the grid
% % Grid.parameters = 'Pulse Intensity Integral';
% Grid.parameters = 'Negative Peak Voltage';
% 
% % Determine wether or not to record waveforms at each individual location.
% Grid.recordWaveforms = 0; %                                       [boolean]


% Transducer Parameters
% Tx.frequency = 5.0; % Frequency in MHz
% Tx.diameter = 0.5*25.4; % aperture diameter                            [mm]
% Tx.focalLength = 0*25.4; % Focal length (use 0 if Tx is unfocused)     [mm]
% Tx.serial = '61235';
% Tx.model = 'technisonic ISL-0504-GP';



% Function Generator Parameters
FgParams.amplifierModel     = 'ENI A150';
FgParams.amplifierSerial    = '363';
FgParams.FGID               = 'MY52600670';
FgParams.gridVoltage = 100; % FG voltage for full grid               [mVpp]
FgParams.maxVoltage = 500; % max FG voltage for Tx efficiency        [mVpp]
FgParams.minVoltage = 50;  % min FG voltage for Tx efficiency        [mVpp]
FgParams.frequency = Tx.frequency; % center frequency                 [MHz]
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
Hydrophone.notes    = '';
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
% if Tx.focalLength == 0
%     Tx.computedFocus = 24;
% end

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
  fg = establishKeysightConnection(['USB0::0x0957::0x2A07::',FgParams.FGID,'::0::INSTR']);
end
if strcmp(fg.Status, 'closed')
    fopen(fg);
end
%%
setFgBurstMode(fg,FgParams.frequency,FgParams.gridVoltage,FgParams.burstPeriod,FgParams.nCycles);

%% Confirm Soniq Settings
Pos = verifyPositionerSettings(lib,Tx);

%% Write a readme file with details of the characterization
writeReadme(Tx,Grid,FgParams,Hydrophone,PreAmp,saveDirectory);

%% Find the center
tic
findCenter5(lib,Tx,Grid);

%% XY Plane
grid_xy = soniq2dScan(lib,[Pos.X.Axis,Pos.Y.Axis],[Grid.xStart,Grid.yStart],[Grid.xEnd,Grid.yEnd],...
    [Grid.xPoints,Grid.yPoints],{'filename',[saveDirectory,'xy.snq'],...
    'pause',Grid.pause,'parameter',Grid.parameters,'recordWaveforms',Grid.recordWaveforms});

% Record the z location of this plane
Pos = getPositionerSettings(lib);
Grid.XYPlaneLoc = Pos.Z.loc;

% Display Result
h = figure;
subplot(311)
imagesc(grid_xy.x,grid_xy.y,grid_xy.data);
axis('equal')
axis([grid_xy.x(1) grid_xy.x(end) grid_xy.y(1) grid_xy.y(end)])
xlabel(grid_xy.xLabel)
ylabel(grid_xy.yLabel)
makeFigureBig(h)
set(h,'position',[962    42   958   954]);
drawnow
% YZ Plane
grid_yz = soniq2dScan(lib,[Pos.Y.Axis,Pos.Z.Axis],[Grid.yStart,Grid.zStart],[Grid.yEnd,Grid.zEnd],...
    [Grid.yPoints,Grid.zPoints],{'filename',[saveDirectory,'yz.snq'],...
    'pause',Grid.pause,'parameter',Grid.parameters,'recordWaveforms',Grid.recordWaveforms});

subplot(312)
imagesc(grid_yz.x,grid_yz.y,grid_yz.data);
axis('equal')
axis([grid_yz.x(1) grid_yz.x(end) grid_yz.y(1) grid_yz.y(end)])
xlabel(grid_yz.xLabel)
ylabel(grid_yz.yLabel)
makeFigureBig(h)
set(h,'position',[962    42   958   954]);
drawnow

% XZ Plane
grid_xz = soniq2dScan(lib,[Pos.X.Axis,Pos.Z.Axis],[Grid.xStart,Grid.zStart],[Grid.xEnd,Grid.zEnd],...
    [Grid.xPoints,Grid.zPoints],{'filename',[saveDirectory,'xz.snq'],...
    'pause',Grid.pause,'parameter',Grid.parameters,'recordWaveforms',Grid.recordWaveforms});

subplot(313)
imagesc(grid_xz.x,grid_xz.y,grid_xz.data);
axis('equal')
axis([grid_xz.x(1) grid_xz.x(end) grid_xz.y(1) grid_xz.y(end)])
xlabel(grid_xz.xLabel)
ylabel(grid_xz.yLabel)
makeFigureBig(h)
set(h,'position',[962    42   958   954]);
drawnow

%% Test output with different voltages
% calllib(lib,'MoveTo2DScanPeak');
getEfficiencyCurve(lib,fg,FgParams,saveDirectory);

%% Generate report
generateReport(Grid,Tx,FgParams,Hydrophone,grid_xy,grid_xz,grid_yz,[saveDirectory,'report\'])

%% Close connection

setFgBurstMode(fg,Tx.frequency,0,FgParams.burstPeriod,1);
closeSoniq(lib);