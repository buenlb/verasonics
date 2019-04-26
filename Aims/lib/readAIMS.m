function [allData,xAxis,yAxis,xName,yName,position] = readAIMS(fileName)

% readAIMS - This code reads AIM files containing hydrophone data.
%    [] = readAIMS(fileName, folderName, newAxis)
%    fileName is a string input for the data file. It should end in '.AIM'
%    plots is a logical 1 or 0 for whether plots should be displayed.
%    folderName is an optional input for the folder containing AIMS data
%       should it not be the current directory
%    newcAxis is an optional input for a new colorbar axis. New colorbar
%       axis can be specified numerically in the form [min max] where min
%       and max specify the limits for the colorbar axis. Or, the new
%       colorbar axis can be copied from another scan's colorbar axis, in
%       which case newcAxis is a string input (e.g. 'scanXZaddon'). By
%       default, readAIMS will match the colorbar axis with the
%       corresponding skullAbsent / skullPresent scan if such axes exist.
%       If newcAxis is [], readAIMS will not set a new colorbar axis.
%    newAxis is an optional vector input in the form [xMin xMax yMin yMax]
%       in units of mm
%
% Saves a .mat file containing data in a structure
%
% Patrick Ye, Butts Pauly Lab, Stanford University
% 
% Modified by Taylor Webb, Jan Kubanek Lab, University of Utah


% % the data looks like this
% %       -10 -9.8 ... 10
% % -10   data ..........
% % -9.8  ...............
% %  .    ...............
% %  .    ...............
% %  .    ...............
% %  10   ...          ..

% get number of parameters measured
text = fileread(fileName);
p = regexp(text, 'Parameter');
p_num = length(p);

% for every parameter
for q = 1:p_num
    
    % calculate number of header lines before data starts
    dataHeader = ['2D Scan Data ' num2str(q-1)];
    newline = '[\n]';
    n = regexp(text, newline);
    m = regexp(text, dataHeader);
    planeLoc = regexp(text,'Axis . Position');
    position = zeros(1,3);
    for ii = 1:3
        position(ii) = findNextNumber(text,planeLoc(ii)+7);
    end
    numHeaderLines = sum(n<m);

    % read file
    fid = fopen(fileName);
    c = textscan(fid, '%f', 'Headerlines', numHeaderLines+1); % may not be 252 lines for every file...
    data = c{1};

    % calculate x axis properties
    if q == 1
        x = regexp(text, '[\n]First Axis');
        xAxisNum = str2double(text(x+12));
        xName = axisAIMS(str2double(text(x+12)));
        dx = data(2) - data(1);
        xMin = data(1);

        xMaxIndex = n(numHeaderLines+2)-2;
        a = text(xMaxIndex);
        while isspace(a) ~= 1
            xMaxIndex = xMaxIndex - 1;
            a = text(xMaxIndex);
        end
        xMax = str2double(text(xMaxIndex:n(numHeaderLines+2)-2));

        numXPoints = (xMax - xMin) / dx + 1;
        numXPoints = int32(numXPoints);
        xAxis = data(1:numXPoints);

        % 1 mm offset for AIMS software because it doesn't run if Left/Right axis
        % starts at 0 mm
        if xMin == 1 && xAxisNum == 0
            xAxis = xAxis - 1;
        end
    end

    % move first row into an axis variable
    data = data(numXPoints+1:end);

    % reshape matrix
    bigData = reshape(data, numXPoints+1, []);
    bigData = bigData';
    rawData = bigData(:, 2:end);
    
    % save rawdata so it doesn't get overwritten
    if q == 1
        allData = zeros(size(rawData, 1), size(rawData, 2), p_num);
    end
    allData(:, :, q) = rawData;
    
    % y axis properties
    if q == 1
        yAxis = bigData(:, 1);
        y = regexp(text, '[\n]Second Axis');
        yName = axisAIMS(str2double(text(y+13)));
    end

end

fclose(fid);

end


function axisName = axisAIMS(n)

% axisAIMS - This code converts axis number from AIM files to axis name.
%    axisName = axisAIMS(n)
%    n is a integer input which is the axis number.
%    axisName is a string output for the axis name corresponding to the
%       axis number.
%
% Patrick Ye
% Butts Pauly Lab, Stanford University
% http://kbplab.stanford.edu

    switch n
        case 0
            axisName = 'Left/Right (mm)';
        case 1
            axisName = 'Front/Back (mm)';
        case 2
            axisName = 'Up/Down (mm)';
    end
end