% soniq1dScan performs a 1D scan with np points along axis, axis, with 
% start and end points sp and ep, respectively.
% 
% @INPUTS
%   axis: axis along which to perform scan
%   sp: starting point of scan (in absolute coordinates)
%   ep: ending point of scan (in absolute coordinates)
%   np: number of scan points
%   valuePairs: parameter value pairs. Optional. Defaults listed below.
%       filename: location in which to save result. Optional. Defaults to
%         xy.snq
%       parameter: parameter to scan. Optional. Defaults to Negative Peak
%         Voltage
%       pause: how long to pause after each movement. Optional. Defaults to
%         10 ms
% 
% @OUTPUTS
%   vpp: the peak-to-peak voltage measured along the scan
% 
% Taylor Webb
% University of Utah

function soniq1dScan(lib,axis,sp,ep,np,valuePairs)

calllib(lib,'Clear1DScanParameters')
calllib(lib,'Add1DScanParameter','Negative Peak Voltage')

filename = [pwd,'\xy.snq'];
pause = 10;

if nargin > 5
    if mod(length(valuePairs),2)
        error('You  must specify value pairs in pairs!')
    end

    firstParameter = 1;
    for ii = 1:length(valuePairs)/2
        switch valuePairs{ii*2-1}
            case 'parameter'
                if firstParameter
                    calllib(lib,'Clear2DScanParameters')
                    firstParameter = 0;
                end
                calllib(lib,'Add2DScanParameter',valuePairs{ii*2})
            case 'filename'
                filename = valuePairs{ii*2};
            case 'pause'
                pause = valuePairs{ii*2};
        end
    end
end

disp(['Scanning 1D. Axis: ', num2str(axis), ', sp: ', num2str(sp),...
    ', ep: ', num2str(ep), ', np: ', num2str(np)])

if ~withinLimits(lib,axis,sp)
    error('Start point is outside of limits!');
end
if ~withinLimits(lib,axis,ep)
    error('End point is outside of limits!');
end

calllib(lib,'SetWaveformAutoScaleMode','false');

calllib(lib,'Set1DScanAxis',axis);
calllib(lib,'Set1DScanStart',sp);
calllib(lib,'Set1DScanEnd',ep);
calllib(lib,'Set1DScanPoints',np);
calllib(lib,'Set1DScanPause',pause);

calllib(lib,'Set1DScanRecordWaveforms',0);

calllib(lib,'Start1DScan');

calllib(lib,'SaveFileAs',filename);