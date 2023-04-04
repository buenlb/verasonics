function [months,contraCh,contraChSem,idx] = summaryWithTime(processedFiles,sessions,sIdx,contraVar,tmIdx,nDays,day1)

day = getSessionDate(processedFiles);
[idxLeft,idxRight] = getLeftRightIdx(sessions,sIdx);
idx1 = [idxLeft,idxRight];
day = day(idx1);
if ~exist('day1','var')
    day1 = min(day);
end
if isempty(day1)
    day1 = min(day);
end
day = day-day1;
contraVar = mean(contraVar(idx1,tmIdx),2,'omitnan');

monthLength = nDays;

monthBins = 0:monthLength:(ceil(max(day)/monthLength))*monthLength;
months = discretize(day,monthBins);

contraCh = nan(1,max(months));
contraChSem = contraCh;
idx = cell(size(contraCh));
for ii = 1:max(months)
    curIdx = find(months==ii);
    if sum(isnan(contraVar(curIdx)))
        warning(['Removing ', num2str(sum(isnan(contraVar(curIdx)))), ' NaNs']);
        curIdx = curIdx(~isnan(contraVar(curIdx)));
    end
    idx{ii} = idx1(curIdx);
    if length(curIdx)< 1
        continue;
    end
    contraCh(ii) = mean(contraVar(curIdx),'omitnan');
    contraChSem(ii) = semOmitNan(contraVar(curIdx),1);
end

months = 1:max(months);