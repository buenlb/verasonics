function eegOutT = eegDurable(tData,processedFiles,eegPath,baseName1)
for ii = 1:length(processedFiles)
    disp(['Processing session ', num2str(ii), ' of ', num2str(length(tData))])
    for jj = 1:length(processedFiles{ii})
        tic;
        if ~isnan(str2double(processedFiles{ii}(jj))) && isreal(str2double(processedFiles{ii}(jj)))
            eegDate.year = (processedFiles{ii}(jj:(jj+3)));
            eegDate.month = (processedFiles{ii}((jj+4):(jj+5)));
            eegDate.day = (processedFiles{ii}((jj+6):(jj+7)));
            break;
        end
    end
    baseName = [baseName1,eegDate.year(3:4),eegDate.month,eegDate.day];

    totEEG = tic;
    outT = fullEegAnalysis2(eegPath,baseName,tData(ii));
%     if isempty(outT)
%         keyboard
%         toc(totEEG)
%         continue
%     end
    eegOutT(ii) = outT; %#ok<AGROW> 
    toc(totEEG)
end