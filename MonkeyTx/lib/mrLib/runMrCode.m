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
verasonicsDir = 'C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\';
% Add relevant paths to give access to library functions

addpath([verasonicsDir, 'MonkeyTx\lib'])
addpath([verasonicsDir, 'MonkeyTx\lib\griddedImage'])
addpath([verasonicsDir, 'MonkeyTx\lib\placementVerification'])
addpath([verasonicsDir, 'MonkeyTx\MATFILES\'])
addpath([verasonicsDir, 'MonkeyTx\setupScripts\'])
addpath([verasonicsDir, 'lib'])
addpath([verasonicsDir, 'MonkeyTx\lib\mrLib\thermometry\'])
addpath([verasonicsDir, 'MonkeyTx\lib\mrLib\transducerLocalization\']);

% Establish file names for storing results 
goldStandard = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRLogs\goldStandard_testCoupling.mat';
logFile ='C:\Users\Verasonics\Desktop\Taylor\Data\MRLogs\test.mat';
couplingFile = 'C:\Users\Verasonics\Desktop\Taylor\Data\tmp\tmpTest.mat';
sys.logFile = logFile;
sys.goldStandard = goldStandard;
sys.couplingFile = couplingFile;
% sys.mrPath = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\Phantom_20200629\images\20200629\';
sys.mrPath = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRImages\20200629\';
sys.aSeriesNo = 50;
sys.invertTx = 1;
sys.incomingDcms = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRImages\IncomingDicoms\';
return
%% Check Coupling
if ~exist(sys.couplingFile,'file')
    save('tmp.mat','sys');
    testArrayPlacement(sys.goldStandard,sys.couplingFile);
    load('tmp.mat');
    delete('tmp.mat');
end
return
%% Localize Transducer
if exist(sys.logFile,'file')
    warning('File exists, continuing where you left off!')
    load(sys.logFile);
    return
%     error('You must not overwrite an old log file!')
end
sys = registerTx(sys);
save(sys.logFile,'sys');

%% Select Focus
sys = selectFocus(sys);
save(sys.logFile,'sys');

%% Sonicate
sys = mrSonication(sys,10,1.6);
save(sys.logFile,'sys');
% Overlay result
if isfield(sys.sonication(end),'phaseSeriesNo')
    sys.nSlices = 8;
    sys = overlayTemperatureAnatomy(sys);
    sys.dynamic = sys.sonication(end).firstDynamic;
    waitfor(orthogonalTemperatureViewsGui(sys));
    sys = rmfield(sys,'tImg');
    sys = rmfield(sys,'tHeader');
    sys = rmfield(sys,'tInterp');
end