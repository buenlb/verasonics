% safetyDurable returns the accuracy as a function of the date of the
% session in order to look for declines in the subject's performance over
% time - a possible indicator of damage.
% 
% @INPUTS
%   tData: struct made by processTaskDataDurable
%   date: Names of processed files. These will be read to extract the date
% 
% @OUTPUTS 
%   accuracy: The subjects overall accuracy (excluding uncompleted trials)
%   day: The dates read from date and corresponding to each individual
%       accuracy number
% 
% Taylor Webb
% University of Utah
% November, 2022

function [accuracy,day,fullDate] = safetyDurable(tData,date)

%% Set up x-axis
found = 0;
day = zeros(size(tData));
fullDate = zeros(length(tData),3);
for ii = 1:length(date)
    for jj = 1:length(date{ii})
        if ~isnan(str2double(date{ii}(jj))) && isreal(str2double(date{ii}(jj)))
            curYear = str2double(date{ii}(jj:(jj+3)));
            curMonth = str2double(date{ii}((jj+4):(jj+5)));
            curDay = str2double(date{ii}((jj+6):(jj+7)));
            found = 1;
            break;
        end
    end
    if ~found
        keyboard
    end
    found = 0;
    day(ii) = date2month(curYear,curMonth,curDay);
    fullDate(ii,1) = curYear;
    fullDate(ii,2) = curMonth;
    fullDate(ii,3) = curDay;
end
day = day-min(day);

slope = zeros(size(tData));
bias = zeros(size(tData));
downshift = zeros(size(tData));
scale = zeros(size(tData));
session = zeros(size(tData));
accuracy = zeros(size(tData));
h = figure;
ax2 = gca;
idx = 1;
for ii = 1:length(tData)
    delay = tData(ii).delay;
    ch = tData(ii).ch;
    delay = delay(~isnan(ch));
    ch = ch(~isnan(ch));
    [slope(idx), bias(idx), downshift(idx), scale(idx)] = sigmoid_plot2(delay',ch',1:length(ch),ax2.ColorOrder(1,:),4);
    session(idx) = ii;
    
    result = zeros(size(ch));
    result(delay==0) = 1;
    result(delay<0 & ch==0) = 1;
    result(delay>0 & ch==1) = 1;
    accuracy(idx) = mean(result);
    idx = idx+1;
end