function saveState(sys)
if isfield(sys,'colorTempImg')
    sys = rmfield(sys,'colorTempImg');
end
if isfield(sys,'tImg')
    sys = rmfield(sys,'tImg');
end
if isfield(sys,'T')
    sys = rmfield(sys,'T');
end
if isfield(sys,'tInterp')
    sys = rmfield(sys,'tInterp');
end
if isfield(sys,'tInterp_deNoised')
    sys = rmfield(sys,'tInterp_deNoised');
end
if isfield(sys,'colorImg')
    sys = rmfield(sys,'colorImg');
end

save(sys.logFile,'sys');