% This function takes a vector, v, and returns the temporal average. The
% temporal average is the average value in time windows that are windowSize
% in length and end at each element of tAvg. Thus, t, tAvg, and windowSize
% all must have the same units.

function [m,sem] = temporalAverageSynchronized(v,t,tAvg,windowSize)

m = nan(size(tAvg));
sem = m;
for ii = 1:length(tAvg)
    startTime = tAvg(ii)-windowSize;
    if startTime < t(1)
        continue
    end
    endTime = tAvg(ii);
    if endTime > t(end)
        break;
    end
    curIdx = find(t>=startTime & t<endTime);
    m(ii) = mean(v(curIdx),'omitnan');
    if isrow(v)
        sem(ii) = semOmitNan(v(curIdx),2);
    else
        sem(ii) = semOmitNan(v(curIdx),1);
    end
end