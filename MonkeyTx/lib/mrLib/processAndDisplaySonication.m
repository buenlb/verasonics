% Interpolates the temperature image onto the anatomy image, converts it
% into a true color image to facilitate rapid scrolling, and launches the
% GUI that enables the user to look at the temperature rise overlaid on the
% anatomy image
% 
% @INPUTS
%   sys: system struct
%   sonicationNo: Desired sonication to reconstruct - defaults to the last
%       one that was done
%   maxT: Max temperature for colorbar display. Defaults to 2 C
% 
% OUTPUTS
%   sys: Updated fields are tWindow (temperatures displayed), colorTempImg
%       (true color image), and other temperature data as described by
%       overlayTemperatureAnatomy.
% 
% Taylor Webb
% University of Utah

function sys = processAndDisplaySonication(sys,sonicationNo,maxT)
if nargin < 2
    sonicationNo = length(sys.sonication);
    maxT = 2;
elseif nargin < 3
    maxT = 2;
end
sys.baseline = 1:5;
sys.dynamic = sys.sonication(sonicationNo).firstDynamic;
sys.curSonicationNo = sonicationNo;
sys = adjustFocus(sys,sys.sonication(sonicationNo).focalSpot,'US');

%% Interpolate
sys = overlayTemperatureAnatomy(sys,sonicationNo);

%% Convert to true color image
sys = draw3dTempOverlay(sys,[0,maxT],sys.sonication(sonicationNo).firstDynamic,1,1);

%% Display result in GUI
orthogonalTemperatureViewsGui(sys);
