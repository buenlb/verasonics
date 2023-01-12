function valid = verifyWithLog(tData,fName)
logPath = 'D:\Task\verasonicsLog\';

if strcmp(fName(end-3:end),'.mat')
    fName = fName(1:end-4);
end
fName = [fName, '_log.mat'];

if ~exist([logPath,fName], 'file')
    valid = false;
    disp('WARNING!')
    disp(['  ', fName, ' could not be found in the specified directory'])
    return
end

log = load([logPath, fName]);

if sum(log.log.targets == tData.sonication.focalLocation) == 3
    valid = true;
elseif sum(isnan(log.log.targets)) == 3 && sum(isnan(tData.sonication.focalLocation)) == 3
    valid = true;
else
    valid = false;
end