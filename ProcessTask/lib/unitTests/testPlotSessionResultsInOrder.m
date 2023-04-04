function passed = testPlotSessionResultsInOrder(sessions,sIdx,processedFiles,y,tmIdx)

[result,days] = plotSessionResultsInOrder(sessions,sIdx,processedFiles,y,tmIdx);
day = getSessionDate(processedFiles);
for ii = 1:length(sIdx)
    tmpDay = squeeze(days(ii,1,:));
    tmpDay = tmpDay(~isnan(tmpDay));
    
    [tmpDay2,sIdxLeft] = sort(day(sessions(sIdx(ii)).sessionsLeft));
    if sum(tmpDay2==tmpDay')<length(sessions(sIdx(ii)).sessionsLeft)
        keyboard
        error('Left days aren''t correct!')
    end

    tmpDay = squeeze(days(ii,2,:));
    tmpDay = tmpDay(~isnan(tmpDay));

    [tmpDay2,sIdxRight] = sort(day(sessions(sIdx(ii)).sessionsRight));
    if sum(tmpDay2==tmpDay')<length(sessions(sIdx(ii)).sessionsRight)
        error('Right days aren''t correct!')
    end

    tmpResult = squeeze(result(ii,1,:));
    tmpResult = tmpResult(~isnan(tmpResult));
    tmpResult2 = mean(y(sessions(sIdx(ii)).sessionsLeft,tmIdx),2,'omitnan');
    tmpResult2 = tmpResult2(sIdxLeft);
    tmpResult2 = tmpResult2(~isnan(tmpResult2));
    if sum(tmpResult2==tmpResult)<length(tmpResult)
        error('Left results aren''t correct')
    end

    tmpResult = squeeze(result(ii,2,:));
    tmpResult = tmpResult(~isnan(tmpResult));
    tmpResult2 = mean(y(sessions(sIdx(ii)).sessionsRight,tmIdx),2,'omitnan');
    tmpResult2 = tmpResult2(sIdxRight);
    tmpResult2 = tmpResult2(~isnan(tmpResult2));
    if sum(tmpResult2==tmpResult)<length(tmpResult)
        error('Right results aren''t correct')
    end
end

passed = true;