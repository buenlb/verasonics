% findPeakNegativeVoltage takes a waveform, v, and determines the peak
% negative voltage. It handles different types of input differently. For
% short pulses it simply takes the minimum value. For long pulses it takes
% an average of the negative peaks. nCycles specifies the type of input.
% 
% @INPUTS
%   v: a waveform
%   nCycles: the number of cycles in the pulse. Pulses longer than 5 cycles
%     are treated differently than those shorter than 5
% 
% @OUTPUTS
%   pnv: computed peak negative voltage
% 
% Taylor Webb
% University of Utah

function pnv = findPeakNegativeVoltage(v,nCycles)
if nCycles < 5
    pnv = -min(v);
else
    threshold = 0.65*max(v);
    idx = find(v>=threshold);
    idx1 = idx(1);
    idxEnd = idx(end);
    
    pulse = -v(idx1:idxEnd);

    [peaks,idx] = findpeaks(pulse,'MinPeakProminence',threshold);
    idx = idx(peaks>0);
    peaks = peaks(peaks>0);
    
%     if length(peaks) > nCycles
%         peaks = peaks(1:nCycles);
%         idx = idx(1:nCycles);
%     end
    pnv = mean(peaks);
end

if 0
    figure
    subplot(211)
    plot(v)
    hold on
    plot([1,length(v)],-[pnv,pnv],'--')
    subplot(212)
    plot(pulse)
    hold on
    plot(idx,peaks,'*')
    keyboard
end