function idx = alignEEG(trId,trIdx,tData,alignTo)
Fs = 20e3;
idx = nan(size(trIdx));
for ii = 1:length(trId)
    switch alignTo
        case 'FP'
            % FP On
            idx(ii) = trIdx(ii);
        case 'FT'
            % FT On
            timing = tData.timing(trId(ii));
            
            nBits = ceil(log2(trId(ii)))+2;
            fTargetTime = timing.eventTimes(3)-timing.eventTimes(1)+3e-3*nBits;
            idx(ii) = round(fTargetTime*Fs+trIdx(ii));
        otherwise
            error([alignTo, ' not yet implemented']);
    end
end