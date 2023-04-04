function [tData,processed] = loadMonk(monk)
switch monk
    case 'e'
        pth = 'D:\Task\Euler\durable\';
    case 'b'
        pth = 'D:\Task\Boltz\durable\';
    case 'c_saline'
        pth = 'D:\Task\Matt\Saline\Calvin\';
    case 'h_saline'
        pth = 'D:\Task\Matt\Saline\Hobbes\';
    case 'c'
        pth = 'D:\Task\Matt\Propofol\Calvin\';
    case 'h'
        pth = 'D:\Task\Matt\Propofol\Hobbes\';
    otherwise
        error(['Unrecognized Monk: ' monk]);
end

files = dir([pth,'*.mat']);
date = getDate({files.name});
if min(abs(diff(date))) == 0
    disp('Found Duplicates. Keeping only the second of each')
    keep = true(size(files));
    keep(diff(date)==0) = false;
    origLength = length(files);
    files = files(keep);
    disp(['Removed ', num2str(origLength-length(files)), ' files.'])
end

if exist([pth,'curData.mat'], 'file')
    eData = load([pth,'curData.mat']);
end

tIdx = 1;
for ii = 1:length(files)
    disp(['File ', num2str(ii), ' of ', num2str(length(files))])
    if strcmp(files(ii).name,'curData.mat')
        continue
    end
    FOUND = 0;
    if exist('eData','var')
        for jj = 1:length(eData.processed)
            if strcmp(eData.processed{jj},files(ii).name)
                disp('  Data already Processed!')
                tData(tIdx) = eData.tData(jj); %#ok<AGROW>
                processed{tIdx} = eData.processed{jj}; %#ok<AGROW> 
                tIdx = tIdx+1;
                FOUND = 1;
                break;
            end
        end
    end
    if ~FOUND
        try
            tmp = processTaskDataDurable([pth,files(ii).name]);
            if ~isstruct(tmp)
                disp(['One of the files appears to be empty: ', files(ii).name])
                continue;
            end
            tData(tIdx) = tmp;
            processed{tIdx} = files(ii).name;
            tIdx = tIdx+1;
        catch me
            if strcmp(me.identifier,'PROCESS:notDurable')
                warning([files(ii).name, ' not processed - it appears to be the wrong kind of file!'])
                disp(['WARNING! ', files(ii).name, ' not processed - it appears to be the wrong kind of file!'])
            elseif strcmp(me.identifier,'MATLAB:nonExistentField')
                warning([files(ii).name, ' not processed - it was empty!'])
                disp(['WARNING! ', files(ii).name, ' not processed - it appears to be the wrong kind of file!'])
            else
                keyboard
                rethrow(me);
            end
        end
    end
end
save([pth,'curData.mat'],'tData','processed')