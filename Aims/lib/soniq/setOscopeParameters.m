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
    end
end