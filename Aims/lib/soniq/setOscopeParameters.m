function setOscopeParameters(lib,parameters)
if mod(length(parameters),2)
    error('parameters must be specified in name, value pairs')
end

for ii = 1:length(parameters)/2
    switch parameters{ii*2-1}
        case 'averages'
            NA = parameters{ii*2};
            if NA > 1
                calllib(lib,'SetScopeWFAverage',1)
                calllib(lib,'SetScopeWFAveraging', int32(NA))
            else
                calllib(lib,'SetScopeWFAverage',0)
            end
        case 'timeBase'
            tb = parameters{ii*2};
            calllib(lib,'SetScopeTimebase',tb);
        case 'nSamples'
            ns = parameters{ii*2};
            calllib(lib,'SetScopePoints',ns);
        case 'delay'
            delay = parameters{ii*2};
            calllib(lib,'SetScopeDelay',delay);
        case 'distanceTracking'
            dt = parameters{ii*2};
            if dt
                calllib(lib,'SetDistanceTrackingEnabled',1)
            else
                calllib(lib,'SetDistanceTrackingEnabled',0)
            end
        case 'distanceTrackingOffset'
            offset = parameters{ii*2};
            calllib(lib,'SetDistanceTrackingOffset',offset);            
        otherwise
            error([parameters{ii*2-1} ' is not a valid option.'])
    end
end