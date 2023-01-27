function [t,eeg,dig] = loadEegBci(fName,digChannels)
raw = readmatrix(fName);
eeg = mean(raw(:,[2,5]),2);

dig = nan(size(eeg,1),length(digChannels));
for ii = 1:length(digChannels)
    dig(:,ii) = raw(:,digChannels(ii));
end

t = raw(:,23);