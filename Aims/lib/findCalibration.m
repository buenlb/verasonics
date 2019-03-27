% findCalibration reads the calibration file calFile and finds the closest
% match to frequency. It returns the calibration value in volts/pascal. If
% checkRange is true it also prints a warning message if frequency is
% outside of the range given in the calibration file and allows the user to
% choose whether or not to continue.
% 
% @INPUTS
%   frequency: frequency in MHz at which to return calibration
%   calFile: full file location of calibration text file from Onda
%   checkRange: if true, system displays a warning message if the frequency
%     requested is outside the range of the calFile. Optional. Defaults to
%     true.
% 
% @OUTPUTS
%   cal: calibration value in volts per pascal
% 
% Taylor Webb
% University of Utah

function cal = findCalibration(frequency,calFile,checkRange)

if nargin < 3
    checkRange = 1;
end

fid = fopen(calFile,'r');

if fid < 0
    error(['Couldn''t find calibration file, ', calFile])
end

endHeader = 0;
while ~endHeader
    curLine = fgetl(fid);
    if length(curLine) > 10
        if strcmp(curLine(1:10),'HEADER_END')
            endHeader = 1;
        end
    end
end

tmp = fscanf(fid,'%f');
table = reshape(tmp,[4,length(tmp)/4]);

freqs = table(1,:);
[~,idx] = min(abs(frequency-freqs));

if checkRange
    if idx == 1
        if frequency < freqs(1)
            disp('WARNING: Calibration Frequency is not ')
            disp(['within range of cal file (', num2str(min(freqs)), ' - ', num2str(max(freqs)), 'MHz)'])
            cont = input('Continue? (y/n)>','s');
            if cont ~= 'y'
                error('Terminated by user. Wrong calibration file.')
            end
        end
    end
    
    if idx == length(freqs)
        if frequency > freqs(1)
            disp('WARNING: Calibration Frequency is not ')
            disp(['within range of cal file (', num2str(min(freqs)), ' - ', num2str(max(freqs)), 'MHz)'])
            cont = input('Continue? (y/n)>','s');
            if cont ~= 'y'
                error('Terminated by user. Wrong calibration file.')
            end
        end
    end
end

cal = table(3,idx);