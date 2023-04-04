% This runs the MR code. The main components of this code are 0) Check
% coupling to validate Tx location and element coupling, 1) register
% the transducer to the MR coordinates, 2) Select a focal spot, 3) sonicate
% that spot with user provided sonicatino duration and voltage, 4)
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
return
% Experiment Path
sys.expPath = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20220203\';

% Gold Standard Acoustic Imaging Files
eulerGs = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20210929\UltrasoundData\eulerGs.mat';
boltzmannGs = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20210929\UltrasoundData\boltzmannGs.mat';
sys.goldStandard = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\test_20210913\UltrasoundData\exVivoSkull1_gs.mat';
sys.goldStandard = eulerGs;
% Set the transducer you are using
sys.txSn = 'JAB800';

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
couplingFile = 'CalvinPostLStim.mat';
sys.couplingFile = [sys.expPath,'UltrasoundData\',couplingFile];

% Log file
logFile ='calvin20220203_postLStim.mat';
sys.logFile = [sys.expPath,'Logs\',logFile];

% Imaging paths
sys.mrPath = [sys.expPath,'Images\'];
sys.incomingDcms = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\IncomingImages\';

% Anatomical Series
sys.aSeriesNo = [];

% Invert Transducer
sys.invertTx = 0;

sys.offElements = [];

msgbox(['You have selected transducer: ', sys.txSn]);

%% Check Coupling
rescan = 1;
scIdx = 1;
while rescan
    save('tmp.mat','sys','scIdx');
    testArrayPlacement_firstTargetTask(sys.goldStandard,sys.couplingFile,[],0);
    load('tmp.mat');
    delete('tmp.mat');
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
sys = registerTx(sys);
saveState(sys);

%% Segment LGN
sys = segmentLGNs(sys);
saveState(sys);

%% Select Focus
sys = selectFocus(sys);
saveState(sys);

%% Sonicate
sys = mrSonication(sys,25.5,25,.48);
totalEnergy(sys);
saveState(sys);
% Overlay result
if isfield(sys.sonication(end),'phaseSeriesNo') && sys.sonication(end).phaseSeriesNo > 0
    sys = processAndDisplaySonication(sys,length(sys.sonication));
end