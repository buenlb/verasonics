% Parses the processed file to find the date. Doesn't account for leap
% years or other calendar abnormalities!
% 
% @INPUT
%   processedFile: File name(s)
% 
% @OUTPUT
%   day: The number of days since Jan 1, 0 CE for each file in
%       processedFiles
%   fullDate: A matrix with the full date [year, month, day]. Each row
%       corresponds to a different entry in processedFiles

function [day,fullDate,month] = getSessionDate(processedFiles)
day = zeros(size(processedFiles));
fullDate = zeros(length(processedFiles),3);
month = day;
for ii = 1:length(processedFiles)
    for jj = 1:length(processedFiles{ii})
        if ~isnan(str2double(processedFiles{ii}(jj))) && isreal(str2double(processedFiles{ii}(jj)))
            curYear = str2double(processedFiles{ii}(jj:(jj+3)));
            curMonth = str2double(processedFiles{ii}((jj+4):(jj+5)));
            curDay = str2double(processedFiles{ii}((jj+6):(jj+7)));
            found = 1;
            break;
        end
    end
    if ~found
        keyboard
    end
    found = 0;
    day(ii) = date2day(curYear,curMonth,curDay);
    month(ii) = date2month(curYear,curMonth,curDay);
    fullDate(ii,1) = curYear;
    fullDate(ii,2) = curMonth;
    fullDate(ii,3) = curDay;
end