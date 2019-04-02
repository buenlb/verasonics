close all; clearvars -except fg; clc;

setPaths();

%% User Defined Variables
saveDirectory = 'C:\Users\Verasonics\Desktop\Taylor\TransducerCharacterization\';

%% Final Characterization Grid
% Start and end points for x and y axis
Grid.xStart = -5; 
Grid.xEnd = 5;
Grid.yStart = -5;
Grid.yEnd = 5;

% length to scan along z-axis
% Grid.zLength = 20; 
Grid.zStart = 75;
Grid.zEnd = 210;

% time to wait after positioner moves before acquiring data
Grid.pause = 10;

% Set grid spacing. If not set these will be automatically set to lambda/4
% Grid.dx = 0.15;
% Grid.dy = 0.15;
% Grid.dz = 0.15;

% Transducer Parameters
Tx.frequency = 0.5;
Tx.diameter = 24.24; % aperture diameter in mm
Tx.focalLength = 0; % Focal length in mm. Use zero if Tx is unfocused
Tx.serial = '1199121';
Tx.model = 'Harisonic';

% Function Generator Parameters
FgParams.fg = 'Verasonics';
FgParams.gridVoltage = 29.9; % FG voltage for full grid (mVpp)
FgParams.maxVoltage = 96; % max FG voltage when testing Tx efficiency (mVpp)
FgParams.frequency = Tx.frequency; % center frequency in MHz
FgParams.nCycles = 1; % number of cicles in pulse
FgParams.burstPeriod = 25; % burst period in ms

% Pre-Amp Info
PreAmp.model = 'AG-2010';
PreAmp.serial = '1199';
PreAmp.calDate = 'Jan-29-1029';

% Hydrophone Info
Hydrophone.model = 'HGL0200';
Hydropone.serial = '1782';
Hydrophone.calDate = 'Jan-29-1029';
Hydrophone.rightAngleConnector = 'true';
% Calibration file for 0.25-1 MHz
Hydrophone.calibrationFile = 'C:\Users\Verasonics\Desktop\Taylor\Code\Aims\Calibrations\Combined\HGL0200-1782_AG2010-1199-20_xx_20190129.txt';
% Calibration file for 1-20 MHz with connector
% Hydrophone.calibrationFile = 'C:\Users\Verasonics\Desktop\Taylor\Code\Aims\Calibrations\Combined\HGL0200-1782_AG-2010-1199_OndaCombineCal_20190129_1-20MHz_withConnector.txt';

% Run findCalibration so that the user is notified right away if the
% calibration file appears to be the wrong one.
findCalibration(Tx.frequency,Hydrophone.calibrationFile,1);

saveDirectory = [saveDirectory,num2str(Tx.frequency),'MHz\',Tx.model,'\'];
if ~exist(saveDirectory,'dir')
    mkdir(saveDirectory);
elseif exist([saveDirectory,'report'],'dir')
    disp('This transducer has been characterized before.')
    disp('What do you want me to do?')
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

% Set up grid values. This just fills in defaults for any empty fields
Grid = initializeGrid(lib,Grid,Tx);

% Set record keeping transducer stuff in Soniq
setTxParams(lib,Tx,FgParams);

% Set the Oscope parameters based on frequency
setOscopeParameters(lib,{'timeBase',35/FgParams.frequency,'averages',Grid.averages});

%% Write a readme file with details of the characterization
% writeReadme(Tx,Grid,FgParams,Hydrophone,PreAmp,saveDirectory);

%% Estimate Scan Time
time = estimateCharacterizationTime(Grid,Tx);

%% Prep Verasonics System
% filename = generateVerasonicsMatfile(2.25,30,1e2,1);
%% Confirm Soniq settings
Pos = getPositionerSettings(lib);
disp('Current Settings:')
disp(['Estimated Time: ', time]);
disp(['  X-axis: ', Pos.AxisLabels{Pos.X.Axis+1},...
    '. Lower limit:', num2str(Pos.X.lowLimit),...
    ', Upper limit:', num2str(Pos.X.highLimit)]);

disp(['  Y-axis: ', Pos.AxisLabels{Pos.Y.Axis+1},...
    '. Lower limit:', num2str(Pos.Y.lowLimit),...
    ', Upper limit:', num2str(Pos.Y.highLimit)]);

disp(['  Z-axis: ', Pos.AxisLabels{Pos.Z.Axis+1},...
    '. Lower limit:', num2str(Pos.Z.lowLimit),...
    ', Upper limit:', num2str(Pos.Z.highLimit)]);

disp('Please confirm that you have set software limits to protect') 
disp('  the hydrophone. DO NOT PROCEED without setting these limits.')
disp('  You will be responsible for any damage.');
confirm = input('(y/n)>','s');
if confirm ~= 'y'
    closeSoniq(lib);
    error('User terminated characterization')
end
tic

% !matlab -r startCharacterization('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\Aims\MATFILES\generateVerasonicsMatfile.mat')

%% Find the center
findCenter(lib,Tx,Grid);
keyboard
%% Characterize Tx
grid_xy = soniq2dScan(lib,[Pos.X.Axis,Pos.Y.Axis],[Grid.xStart,Grid.yStart],[Grid.xEnd,Grid.yEnd],...
    [Grid.xPoints,Grid.yPoints],{'filename',[saveDirectory,'xy.snq'],'pause',Grid.pause});

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

grid_yz = soniq2dScan(lib,[Pos.Y.Axis,Pos.Z.Axis],[Grid.yStart,Grid.zStart],[Grid.yEnd,Grid.zEnd],...
    [Grid.yPoints,Grid.zPoints],{'filename',[saveDirectory,'yz.snq'],'pause',Grid.pause});

subplot(312)
imagesc(grid_yz.x,grid_yz.y,grid_yz.data);
axis('equal')
axis([grid_yz.x(1) grid_yz.x(end) grid_yz.y(1) grid_yz.y(end)])
xlabel(grid_yz.xLabel)
ylabel(grid_yz.yLabel)
makeFigureBig(h)
set(h,'position',[962    42   958   954]);
drawnow

grid_xz = soniq2dScan(lib,[Pos.X.Axis,Pos.Z.Axis],[Grid.xStart,Grid.zStart],[Grid.xEnd,Grid.zEnd],...
    [Grid.xPoints,Grid.zPoints],{'filename',[saveDirectory,'xz.snq'],'pause',Grid.pause});

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
getEfficiencyCurveVerasonics(lib,saveDirectory);

%% Generate report
generateReport(Grid,Tx,FgParams,Hydrophone,grid_xy,grid_xz,grid_yz,[saveDirectory,'report\'])

%% Close connection
closeSoniq(lib);