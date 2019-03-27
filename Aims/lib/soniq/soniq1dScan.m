% soniq1dScan performs a 1D scan with np points along axis, axis, with 
% start and end points sp and ep, respectively.
% 
% @INPUTS
%   axis: axis along which to perform scan
%   sp: starting point of scan (in absolute coordinates)
%   ep: ending point of scan (in absolute coordinates)
%   np: number of scan points
%   pause: sets the pause time after the positioner moves in ms. Optional.
%      Defaults to 10 ms
% 
% @OUTPUTS
%   vpp: the peak-to-peak voltage measured along the scan
% 
% Taylor Webb
% University of Utah

function soniq1dScan(lib,axis,sp,ep,np,pause)

if nargin < 6
    pause = 10;
end

disp(['Scanning 1D. Axis: ', num2str(axis), ', sp: ', num2str(sp),...
    ', ep: ', num2str(ep), ', np: ', num2str(np)])

calllib(lib,'SetWaveformAutoScaleMode','true');

calllib(lib,'Set1DScanAxis',axis);
calllib(lib,'Set1DScanStart',sp);
calllib(lib,'Set1DScanEnd',ep);
calllib(lib,'Set1DScanPoints',np);
calllib(lib,'Set1DScanPause',pause);

calllib(lib,'Start1DScan');