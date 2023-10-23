% This runs the MR code. The main components of this code are 0) Check
% coupling to validate Tx location and element coupling, 1) register
% the transducer to the MR coordinates, 2) Select a focal spot, 3) sonicate
% that spot with user provided sonication duration and voltage, 4)
% reconstructe thermometry and overlay it on the original anatomy image, 5)
% repeat until satisfactory focal spots are obtained.
% 
% The code keeps track of relevant variables in a system struct called sys.
% This struct has the following fields
% @FIELDS in sys
%   goldStandard: Full file name of coupling data to compare to
%   logFile: Full file name of location in which to save results - this is
%     done regularly in order to avoid data loss with errors
%   couplingFile: Full file name of location in which data gathered during
%     coupling validation is stored.
%   incomingDcms: Path where images pushed from scanner will arrive
%   mrPath: Path to MR images generated during this session.
%   aSeriesNo: MR series number of anatomical imaging dataset
%   aImg: Anatomical Imaging Data set
%   txCenter: Location of transducer center in MR Coordinates
%   txTheta: Angle of Tx x-axis and MR x-axis
%   txCenterIdx: Index of txCenter into anatomical imaging data
%   ux: x-axis of anatomical image dataset in ultrasound coordinates
%   uy: y-axis of anatomical image dataset in ultrasound coordinates
%   uz: z-axis of anatomical image dataset in ultrasound coordinates
%   ax: x-axis of anatomical image dataset in MR coordinates
%   ay: y-axis of anatomical image dataset in MR coordinates
%   az: z-axis of anatomical image dataset in MR coordinates
%   focalSpot: Location of current target in Tx coordinates
%   focalSpotMR: location of current target in Mr coordinates
%   focalSpotIdx: Index of focal spot location in anatomy MR dataset
%   sonications: Struct containing information about each sonication. Grows
%     as sonications are performed
%       @FIELDS in sonications
%         duration: duration of sonication in seconds
%         voltage: peak voltage applied to each element during sonication
%         focus: MR coords of focus targeted with this sonication (can be
%           different from current target to enable tracking of different
%           foci in the same MR session).
%         focusTx: Tx coords of focus targeted with this sonication
%         phaseSeriesNo: MR series number for the phase images
%           corresponding to this sonication
%         magSeriesNo: MR series number for the magnitude images
%           corresponding to this sonication
%   tImg: Thermometry dataset for the most recent sonication. This gets
%     replaced with each new sonication but can be easliy re-loaded using
%     sys.sonications(sonicationOfInterest).thermPath.

clear all; close all; clc;
%% Setup
% verasonicsDir = 'C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\';
verasonicsDir = 'C:\Users\Taylor\Documents\Projects\verasonics\verasonics\';
% Add relevant paths to give a  ccess to library functions

addpath([verasonicsDir, 'MonkeyTx\lib'])
addpath([verasonicsDir, 'MonkeyTx\lib\mrLib'])
addpath([verasonicsDir, 'MonkeyTx\lib\griddedImage'])
addpath([verasonicsDir, 'MonkeyTx\lib\placementVerification'])
addpath([verasonicsDir, 'MonkeyTx\MATFILES\'])
addpath([verasonicsDir, 'MonkeyTx\setupScripts\'])
addpath([verasonicsDir, 'lib'])
addpath([verasonicsDir, 'MonkeyTx\lib\mrLib\thermometry\'])
addpath([verasonicsDir, 'MonkeyTx\lib\mrLib\transducerLocalization\']);

% Experiment Path
sys.expPath = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20230208\';

% Gold Standard Acoustic Imaging Files
eulerGs = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20210929\UltrasoundData\eulerGs.mat';
boltzmannGs = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20210929\UltrasoundData\boltzmannGs.mat';
hobbesGs = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20220202\UltrasoundData\hobbesGS.mat';
calvinGs = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20220203\UltrasoundData\calvinGS.mat';
sys.goldStandard = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\test_20210913\UltrasoundData\exVivoSkull1_gs.mat';
sys.goldStandard = calvinGs;
% Set the transducer you are using
sys.txSn = 'JAB800';

% xDist, yDist, and zDist are used by transducer localization functions to
% determine the center of the transducer relative to the fiducials.
if strcmp(sys.txSn,'JEC482')
    sys.zDist = 9.53e-3;
    sys.xDist = 187.59e-3/2;
    sys.yDist = 35e-3/2;
else
    % zDist is 2.53 + whatever the Tx offset is.
    sys.zDist = 9.53e-3;
    sys.xDist = (169/2)*1e-3;
    sys.yDist = (35/2)*1e-3;
end
    

% Coupling File
% couplingFile = 'calvin_preMR.mat';
couplingFile = 'calvin_preMR.mat';
sys.couplingFile = [sys.expPath,'UltrasoundData\',couplingFile];

% Log file
logFile ='calvin20230208.mat';
sys.logFile = [sys.expPath,'Logs\',logFile];

% Imaging paths
sys.mrPath = [sys.expPath,'Images\'];
sys.incomingDcms = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\IncomingImages\';

% Anatomical Series
sys.aSeriesNo = 6;

% Invert Transducer
sys.invertTx = 0;

sys.offElements = [];

msgbox(['You have selected transducer: ', sys.txSn]);

%% Check Coupling
rescan = 1;
scIdx = 1;
while rescan
    % VSX will clear the variable space so we have to save and re-load our
    % state before/after calling testArrayPlacement
    save('tmp.mat','sys','scIdx');

    % Runs the verasonics code to measure coupling
    testArrayPlacement_firstTargetTask(sys.goldStandard,sys.couplingFile,[],0);
    load('tmp.mat');
    delete('tmp.mat');

    % Plot the results and wait for the user to respond. This GUI allows
    % the user to repeat the process (sets rescan to 1).
    waitfor(verifyPreTask(sys.goldStandard,sys.couplingFile));

    rs = load('guiOutput.mat');
    rescan = rs.rescan;
    if rescan
        scIdx = scIdx+1;
        sys.couplingFile = [sys.couplingFile(1:end-4),'_',num2str(scIdx),'.mat'];
    end
end


%% Localize Transducer
if exist(sys.logFile,'file')
    warning('File exists, continuing where you left off!')
    load(sys.logFile);
    return
%     error('You must not overwrite an old log file!')
end

% Allows the user to provide a first pass estimate on the location of the
% center of the transducer, then automatically registers the transducer
% based on a matched filter search of the fiducials.
sys = registerTx(sys);
saveState(sys);

%% Segment LGN
% Allows the user to segment the LGN. This is just to help the user
% visualize where to place the sonication. It does not effect the
% sonication. This function is a bit buggy but it is no necessary for a
% succesful thermometry session.
sys = segmentLGNs(sys);
saveState(sys);

%% Select Focus
% A GUI to allow the user to select a focus. Note that the focus should
% NEVER be set manually - a function should always be called. If you wish
% to set manual coordinates you may use the function adjustFocus. This is
% because the focus is saved in both MR and US coordinates. These functions
% ensure that all of the variables are properly updated.
sys = selectFocus(sys);
saveState(sys);

%% Sonicate
duration = 5; % duration in seconds
voltage = 30; % voltage in volts

% Runs the sonication. This will load the sonication and wait for the user
% to press enter before it begins. This is to allow quazi synchronization
% between the ultrasound and the MR (the MR operator should tell you when
% the proper number of baselines complete and the sonication should begin).
sys = mrSonication(sys,duration,voltage,.48);

% Computes the total energy that has been delivered in this session for
% IACUC compliance. Note that this assumes that you have the same unique 
% log file defined within sys for each sonication of the session.
totalEnergy(sys);

% Saves the state to ensure that no data is lost in case MATLAB struggles
% with reconstruction
saveState(sys);

% Assuming that the MR images were transferred this will load them and
% provide an overlay of the thermometry on the original anatomical image.
% To setup image transfer (before the beginning of the session) the
% verasonics computer should be connected to the same ethernet hub as the
% scanner. The IP address should be manually set to something the scanner 
% can find (as of 2023 192.168.2.6 worked well) and the verasonics computer
% should run the dcmtk:
% “storescp.exe --verbose --output-directory C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\IncomingImages 104”
% The location of the directory is flexible and is set by sys.mrPath.
if isfield(sys.sonication(end),'phaseSeriesNo') && sys.sonication(end).phaseSeriesNo > 0
    sys = processAndDisplaySonication(sys,length(sys.sonication));
end