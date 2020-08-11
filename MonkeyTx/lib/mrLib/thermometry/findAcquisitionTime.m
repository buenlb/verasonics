% Uses the dicom header to find the acquisition time for a 3D thermometry
% series.
% 
% @INPUTs
%   header: Cell array of headers for at least the first nSlices+1 images
%       in the relevant thermometry sequence.
% 
% @OUTPUTS
%   acqTime: elapsed time (seconds) between each temperature dynamic for
%       each slice

function acqTime = findAcquisitionTime(header)
% Figure out number of slices
nSlices = howManySlices(header);

% First Acquisition Time
acqTime1 = header{1}.AcquisitionTime;
acqTime1_hr = str2double(acqTime1(1:2));
acqTime1_mn = str2double(acqTime1(3:4));
acqTime1_sc = str2double(acqTime1(5:end));
acqTime1 = acqTime1_hr*3600+acqTime1_mn*60+acqTime1_sc;

acqTime2 = header{1+nSlices}.AcquisitionTime;
acqTime2_hr = str2double(acqTime2(1:2));
acqTime2_mn = str2double(acqTime2(3:4));
acqTime2_sc = str2double(acqTime2(5:end));
acqTime2 = acqTime2_hr*3600+acqTime2_mn*60+acqTime2_sc;

acqTime = (acqTime2-acqTime1);