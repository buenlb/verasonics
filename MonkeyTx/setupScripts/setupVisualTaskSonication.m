%% This script sets up a VSX MATFILE to sonicate left/right LGN during a
% visual task. The code uses a focal location discovered from MR
% thermometry and gives the relevant phases to target each LGN in each
% subject.
function setupVisualTaskSonication(fName)

%% Sonication Parameters
PRF = 500;
duty = 50;
duration = 300e-3;

%% Get the transducer geometry
frequency = 0.65;
Trans = transducerGeometry(0);

xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

elements.x = xTx*1e-3;
elements.y = yTx*1e-3;
elements.z = zTx*1e-3;

%% Steer to the desired focal location
% Euler left LGN (Determined on December 2, 2020: Sonication #8)
focus = [-10,5.5,55.5]*1e-3;
elements = steerArray(elements,focus,frequency);
delays{1} = [elements.t]';
voltages(1) = 17;

% Euler right LGN (Determined on December 2, 2020: Sonication #2)
focus = [12,5,59]*1e-3;
elements = steerArray(elements,focus,frequency);
delays{2} = [elements.t]';
voltages(2) = 17;

%% Setup VSX MATfile
if strcmp(fName(end-3:end),'.mat')
    fName = fName(end:end-4);
end
fName = [fName,'_log.mat'];
doppler256_neuromodulate(duration,voltages,delays,PRF,duty,fName);