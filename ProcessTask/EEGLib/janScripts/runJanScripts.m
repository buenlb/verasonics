frequencies = [1 : 1 : 19, 20 : 2 : 38, 40 : 4 : 76, 80 : 8 : 320];
spike_thrs = [4i, 5i]; %uV; imaginary values stand for the number of sigmas to be exceeded (e.g., 5i: abs(signal) > 5 sigma)
%frequencies = [2 : 2 : 320];
frequency_bands = cell(size(frequencies));
for f = 1 : numel(frequencies)
    frequency_bands{f} = [frequencies(f) - 1, frequencies(f) + 1];
end

rereference = ''; %'' or 'CAR'
windowdur = 0.1;
tFeatures = cell(size(processedFiles));
features = cell(size(processedFiles));
for ii = 1:length(processedFiles)
    disp(['  Processing EEG data in session ', num2str(ii), ' of ', num2str(length(processedFiles))])
    tic
    for jj = 1:length(processedFiles{ii})
        if ~isnan(str2double(processedFiles{ii}(jj))) && isreal(str2double(processedFiles{ii}(jj)))
            date(ii).year = (processedFiles{ii}(jj:(jj+3)));
            date(ii).month = (processedFiles{ii}((jj+4):(jj+5)));
            date(ii).day = (processedFiles{ii}((jj+6):(jj+7)));
            break;
        end
    end
    switch monk(ii)
        case 'b'
            pth = 'D:\Task\Boltz\eeg\';
            baseName1 = 'boltzmannTask_';
        case 'e'
            pth = 'D:\Task\Euler\eeg\';
            baseName1 = 'Euler_';
    end
    baseName = [baseName1,date(ii).year(3:4),date(ii).month,date(ii).day];
    files = dir([pth,baseName,'*.rhs']);
    for jj = 1:length(files)
        data = read_Intan_RHS2000_file_JK([pth,files(jj).name],[60,120,180]);
        if jj == 1
            rData = data;
            continue
        else
            rData.t = [rData.t,data.t];
            rData.amplifier_data = [rData.amplifier_data,data.amplifier_data];
        end
    end
    eegWindow2 = 60*5;
    eegWindowSep = 30;

    [features{ii}, tFeatures{ii}] = derive_features(rData,frequency_bands,[],windowdur,rereference);
    [~,~,~,~,tEeg,eeg,~,~,trId{ii},taskIdx{ii}] =...
            loadEEGTaskData(pth,baseName,tData(ii));
    if isempty(tEeg)
        timeOfSonication(ii) = nan;
    else
        [~,zIdx] = alignEegSpectra({tEeg},tData(ii),taskIdx(ii),trId(ii));
        if isnan(zIdx)
            timeOfSonication(ii) = nan;
        else
            timeOfSonication(ii) = tEeg(zIdx);
        end
    end
end
