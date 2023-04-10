function [t,eeg,dig] = loadEegBci(fName,digChannels)
if iscell(fName)
    raw = [];
    for ii = 1:length(fName)
        tmp = readmatrix(fName{ii});
        raw = cat(1,raw,tmp);
    end
else
    raw = readmatrix(fName);
end

eeg = mean(raw(:,[2,5]),2);

dig = nan(size(eeg,1),length(digChannels));
for ii = 1:length(digChannels)
    dig(:,ii) = raw(:,digChannels(ii));
end
t = raw(:,23);