% Moves dicoms from sourcePath to destPath and places them in a directory
% named for the series number.
% 
% @INPUTS
%   sourcePath: Source where dicoms from scanner are being pushed
%   destPath: where to move files to
% 
% @OUTPUTS
%   img: Image data from files that were moved
%   header: headers corresponding to files that were moved
% 
% Taylor Webb
% University of Utah
function [imgOut,headerOut,seriesNo] = sortDicoms(sourcePath, destPath)

if sourcePath(end)~= '/' || sourcePath(end)~= '\'
    sourcePath(end+1) = '\';
end

if destPath(end)~= '/' || destPath(end)~= '\'
    sourcePath(end+1) = '\';
end

[img,header,~,~,~,fileNames] = loadDicomDir(sourcePath);

for ii = 1:length(header)
    curSeries = header{ii}.SeriesNumber;
    if ii == 1
        firstSeries = curSeries;
    end
        
    if ~exist([destPath,num2str(curSeries,'%03d')],'dir')
        mkdir([destPath,num2str(curSeries,'%03d')]);
    end
    instNumber = double(header{ii}.InstanceNumber);
    movefile(fileNames{ii},[destPath,num2str(curSeries,'%03d'),'\img',num2str(header{ii}.InstanceNumber,'%04d'),'.dcm']);
    imgOut{curSeries-firstSeries+1}(:,:,instNumber) = img(:,:,ii);
    headerOut{curSeries-firstSeries+1,instNumber} = header{ii};
    seriesNos(ii) = curSeries;
end
seriesNo = unique(seriesNos);
        