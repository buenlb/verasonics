% Moves dicoms from sourcePath to destPath and places them in a directory
% named for the series number.
% 
% @INPUTS
%   sourcePath: Source where dicoms from scanner are being pushed
%   destPath: where to move files to
% 
% @OUTPUTS
%   header: headers corresponding to files that were moved
%   seriesNo: Series that were moved
% 
% Taylor Webb
% University of Utah
function [header,seriesNo] = sortDicoms(sourcePath, destPath)

if sourcePath(end)~= '/' && sourcePath(end)~= '\'
    sourcePath(end+1) = '\';
end

if destPath(end)~= '/' && destPath(end)~= '\'
    sourcePath(end+1) = '\';
end

% [img,header,~,~,~,fileNames] = loadDicomDir(sourcePath);
[header,fileNames] = readDicomHeaders(sourcePath);
overwrite = 0;
seriesNos = zeros(length(header),1);
for ii = 1:length(header)
    curSeries = header{ii}.SeriesNumber;
        
    if ~exist([destPath,num2str(curSeries,'%03d')],'dir')
        mkdir([destPath,num2str(curSeries,'%03d')]);
    end
    
    % Unless user has already indicated to overwrite files, check if file exists
    destName = [destPath,num2str(curSeries,'%03d'),'\img',num2str(header{ii}.InstanceNumber,'%04d'),'.dcm'];
    if ~overwrite
        if exist(destName, 'file')
            answer = questdlg('The destination file already exists, continue?','File Exists!','Yes','Yes To All','No','No');
            switch answer
                case 'No'
                    error('Destination file exists.')
                case 'Yes To All'
                    overwrite = 1;
            end
        end
    end
    movefile(fileNames{ii},destName);
    seriesNos(ii) = curSeries;
end
seriesNo = unique(seriesNos);
disp('Results:')
for ii = 1:length(seriesNo)
    nFiles = sum(seriesNos == seriesNo(ii));
    disp(['  Series: ', num2str(seriesNo(ii)), ': ', num2str(nFiles)])
end
        