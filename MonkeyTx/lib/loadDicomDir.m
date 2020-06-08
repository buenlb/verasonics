function [imgstack, hdr, dimL, dimP, dimS] = loadDicomDir(dirpath,uiHandle)

% loadDicomDir          loads all DICOM images in a directory
%
% -- inputs --
% dirpath               system path of the directory containing the dicoms
% uiHandle              an optional input that specifies a uifigure to use
%                           in order to launch a status bar
%
% -- outputs --
% imgstack              3D stack of images. by default, the order of
%                           dimensions will be PLS (not the expected LPS).
%                           this is the actually the expected behavior so
%                           that image plotting in MATLAB will work
% hdr                   DICOM header of the first image in the series
% dimL                  real world coordinates (mm) of pixels in the L dimension
% dimP                  real world coordinates (mm) of pixels in the P dimension
% dimS                  real world coordinates (mm) of pixels in the S dimension
%
% -- edit history --
% 2016-03-12 SAL        created
% 2016-03-20 SAL        made sure images are PLS for MATLAB compatibility

%% setup
listing = dir(fullfile(dirpath, '*.dcm'));
numFiles = length(listing);

if numFiles < 1
    error('No Files Found!')
end

% the DICOM info of any slice contains most of the same information as all
% the other slices. we can use this info to pre-allocate memory and for
% other logic
file = fullfile(dirpath, listing(1).name);
% hdr = dicominfo(file, 'dictionary', 'gems-dicom-dict.txt');
hdr = dicominfo(file, 'UseDictionaryVR', true);

file2 = fullfile(dirpath, listing(end).name);
hdr2 = dicominfo(file2,'UseDictionaryVR', true);

% define pixel coordinates. the DICOM reference coordinate system has the
% first dimension running along the matrix row dimension (across the column
% dimension). therefore the number of pixels in the L dimension is the
% number of columns. the number of pixels in the P dimension is the number
% of rows
numCols = double(hdr.Columns);
numRows = double(hdr.Rows);
dimL = hdr.PixelSpacing(1)*(0:numCols-1)' + hdr.ImagePositionPatient(1);
dimP = hdr.PixelSpacing(2)*(0:numRows-1)' + hdr.ImagePositionPatient(2);
% if the slice thickness is the same as the spacing between slices, then we
% know that the slices are flush with one another and can compute the
% positions easily. otherwise, we need to get the slice location
% information from each DICOM
if ~isempty(hdr.SliceThickness)%hdr.SliceThickness == hdr.SpacingBetweenSlices;
    dimS = hdr.SliceThickness*(0:numFiles-1)' + hdr.ImagePositionPatient(3);
else
    warning('Unable to set dimS!')
    dimS = 0;
%     dimS = zeros(numFiles, 1);
%     for i = 1:numFiles
%         file = fullfile(dirpath, listing(i).name);
%         header = dicominfo(file);
%         dimS(i) = header.SliceLocation;
%     end
end


% want the order of dimensions to be PLS
imgstack = zeros(numRows, numCols, numFiles);

%% load files
% image data have been scaled to best fit the dynamic range of the dicom
% format. therefore we undo that scaling to get the original image data.
% we're uncertain which direction the 3rd dimension is traversing (could be
% S->I or I->S), therefore we populate the dim3 array as we load each image

if ~exist('uiHandle','var')
    uiHandle = uifigure;
    closeFigure = 1;
else
    closeFigure = 0;
end
d = waitbar(0,'Loading Dicoms');
for i = 1:numFiles
    waitbar(i/numFiles,d,'Loading Dicoms')
    
    %d.Value = i/numFiles;
    %d.Message = ['File ', num2str(i), ' of ', num2str(numFiles)];
    
    file = fullfile(dirpath, listing(i).name);
    header = dicominfo(file, 'UseDictionaryVR', true);
    if ~isfield('RescaleSlope',header)
        if i == 1
            fprintf('\n')
            disp('WARNING: No rescale slope!')
        end
        imgstack(:,:,i) = double(dicomread(header));
    else
        imgstack(:,:,i) = header.RescaleSlope*double(dicomread(header)) + header.RescaleIntercept;
    end
end
hdr = {hdr,hdr2};

if closeFigure
    close(uiHandle);
    close(d);
end
