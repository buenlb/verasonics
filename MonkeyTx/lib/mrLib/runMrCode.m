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
%   aPath: Path to anatomical images
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
%         thermPath: Path to thermometry images corresponding to this
%           sonication
%   tImg: Thermometry dataset for the most recent sonication. This gets
%     replaced with each new sonication but can be easliy re-loaded using
%     sys.sonications(sonicationOfInterest).thermPath.

clear all; close all; clc;
%% Setup
% Add relevant paths to give access to library functions
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\griddedImage')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\placementVerification')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\MATFILES\')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\setupScripts\')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\lib')
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\mrLib\thermometry\')

% Establish file names for storing results 
goldStandard = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRLogs\goldStandard_testCoupling.mat';
logFile ='C:\Users\Verasonics\Desktop\Taylor\Data\MRLogs\20200623\withSkull1.mat';
couplingFile = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRLogs\20200623\inMR2.mat';

sys.logFile = logFile;
sys.goldStandard = goldStandard;
sys.couplingFile = couplingFile;
sys.aPath = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRLogs\20200623\phantom_20200623\s000017 t1_mpr_tra_iso\';
sys.invertTx = 1;

%% Localize Transducer
if exist(sys.logFile,'file')
    error('You must not overwrite an old log file!')
end
sys = registerTx(sys);
save(sys.logFile,'sys');

%% Select Focus
sys = selectFocus(sys);
save(sys.logFile,'sys');

%% Sonicate
sys = mrSonication(sys,10,5);

%% Overlay result
sys.tPath = sys.sonication(end).tPath;
sys.tMagPath = sys.sonication(end).tMagPath;
sys.nSlices = 8;
sys = overlayTemperatureAnatomy(sys);
return
%% Coupling Checks
save('tmp.mat','sys');
testArrayPlacement(sys.goldStandardFile,sys.couplingCheckFile);
load('tmp.mat');
delete('tmp.mat');