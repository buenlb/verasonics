function [data,t,axis] = read1DWaveFormsSonic(fileName)

fid = fopen(fileName);

found = 0;
while ~feof(fid)
    line = fgetl(fid);
    
    if length(line)<6
        continue
    end
    
    if strcmp(line(1:6),'Points')
        if ~exist('tPoints','var')
            tPoints = sscanf(line(7:end),'%f');
            continue
        end
    end
    
    if strcmp(line(1:6),'Points')
        nGrid1 = sscanf(line(7:end),'%f');
    end
    
    if length(line)<18
        continue
    end
    
    if strcmp(line(1:18),'[1D Scan Waveforms')
        found = 1;
        break;
    end
end
line = fgetl(fid);
axis = sscanf(line,'%f');

data = cell(nGrid1,1);

t = zeros(1,tPoints);
for jj = 1:tPoints
    line = fgetl(fid);
    tmp = sscanf(line,'%f');
    t(jj) = tmp(1);
    for kk = 1:nGrid1
        data{kk,1}(jj) = tmp(kk+1);
    end
end
fclose(fid);