function [date,day] = getDate(fileNames)
date = nan(size(fileNames));
day = nan(size(fileNames));
for ii = 1:length(fileNames)
    for jj = 1:length(fileNames{ii})
        if ~isnan(str2double(fileNames{ii}(jj))) && isreal(str2double(fileNames{ii}(jj)))
            curYear = str2double(fileNames{ii}(jj:(jj+3)));
            curMonth = str2double(fileNames{ii}((jj+4):(jj+5)));
            curDay = str2double(fileNames{ii}((jj+6):(jj+7)));
            found = 1;
            break;
        end
    end
    if ~found
        continue
    end
    found = 0;
    date(ii) = str2double([num2str(curYear),num2str(curMonth),num2str(curDay)]);
    day(ii) = date2day(curYear,curMonth,curDay);
end