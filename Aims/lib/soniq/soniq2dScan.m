% soniq2dScan performs a 1D scan with np points along axis, axis, with 
% start and end points sp and ep, respectively.
% 
% @INPUTS
%   axis: axes along which to perform scan
%   sp: starting points of scan (in absolute coordinates)
%   ep: ending points of scan (in absolute coordinates)
%   np: number of scan points for each axis
%   valuePairs: parameter value pairs. Optional. Defaults listed below.
%       filename: location in which to save result. Optional. Defaults to
%         xy.snq
%       parameter: parameter to scan. Optional. Defaults to Negative Peak
%         Voltage
%       pause: how long to pause after each movement. Optional. Defaults to
%         10 ms
% 
% @OUTPUTS
%   data: the rms voltage measured along the scan
% 
% Taylor Webb
% University of Utah

function data = soniq2dScan(lib,axis,sp,ep,np,valuePairs)

%% Set defaults - these can be overwritten by values in valuePairs
calllib(lib,'Clear2DScanParameters')
calllib(lib,'Add2DScanParameter','Negative Peak Voltage')

filename = [pwd,'\xy.snq'];

pause = 10;
recordWaveforms = 0;
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
            case 'recordWaveforms'
                recordWaveforms = valuePairs{ii*2};
            otherwise
                error([valuePairs{ii*2-1}, ' is not a valid parameter'])
        end
    end
end
disp(['Scanning 2D. Axis: ', num2str(axis), ', sp: ', num2str(sp),...
    ', ep: ', num2str(ep), ', np: ', num2str(np)])

calllib(lib,'SetWaveformAutoScaleMode','true');

calllib(lib,'Set2DScanFirstAxis',axis(1));
calllib(lib,'Set2DScanSecondAxis',axis(2));

calllib(lib,'Set2DScanFirstStart',sp(1));
calllib(lib,'Set2DScanSecondStart',sp(2));

calllib(lib,'Set2DScanFirstEnd',ep(1));
calllib(lib,'Set2DScanSecondEnd',ep(2));

calllib(lib,'Set2DScanFirstPoints',np(1));
calllib(lib,'Set2DScanSecondPoints',np(2));

calllib(lib,'Set2DScanPause',pause);

calllib(lib,'Set2DScanRecordWaveforms',recordWaveforms);

calllib(lib,'Start2DScan');

calllib(lib,'SaveFileAs',filename);

%% Load scan and return data
[rawData,x,y,xLabel,yLabel] = readAIMS(filename);
data = struct('data',rawData,'x',x,'y',y,'xLabel',xLabel,'yLabel',yLabel);

