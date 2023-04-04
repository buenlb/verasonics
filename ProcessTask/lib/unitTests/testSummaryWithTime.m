function testSummaryWithTime(processedFiles,sessions,sIdx,contraVar,tmIdx,nDays,day1)

day = getSessionDate(processedFiles);

if exist('day1','var')
    [months,contraCh,contraChSem,idx] = summaryWithTime(processedFiles,sessions,sIdx,contraVar,tmIdx,nDays,day1);
    minDay = day1;
else
    [months,contraCh,contraChSem,idx] = summaryWithTime(processedFiles,sessions,sIdx,contraVar,tmIdx,nDays);
    minDay = min(day(idx{1}));
end

if isempty(minDay)
    minDay = min(day(idx{1}));
end

for ii = 1:length(months)
    dayTest = day(idx{ii});
    dayTest = dayTest-minDay;
    if max(dayTest)>=nDays*ii
        error(['The ', num2str(ii), ' month has days that are too high!'])
    elseif min(dayTest)<(ii-1)*nDays
        error(['The ', num2str(ii), ' month has days that are too Low!'])
    end

    testContraCh = mean(contraVar(idx{ii},tmIdx),2,'omitnan');
    testContraCh = mean(testContraCh,1,'omitnan');

    if contraCh(ii)~=testContraCh && ~(isnan(testContraCh) && isnan(contraCh(ii)))
        keyboard
        error('The average values don''t match the expected result!')
    end

    testContraChSm = mean(contraVar(idx{ii},tmIdx),2,'omitnan');
    testContraChSm = semOmitNan(testContraChSm,1);

    if contraChSem(ii)~=testContraChSm && ~(isnan(testContraChSm) && isnan(contraChSem(ii)))
        keyboard
        error('The SEM values don''t match the expected result!')
    end
end

disp('summaryWIthTIme Passed All Tests!')