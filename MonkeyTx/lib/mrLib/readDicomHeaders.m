function [headers,fullFiles] = readDicomHeaders(directory)

if directory(end) ~= '/' && directory(end) ~= '\'
    directory(end+1) = '\';
end

files = dir([directory,'*.dcm']);
if isempty(files)
    files = dir([directory]);
    idx = 1;
    for ii = 1:length(files)
        if ~isfolder([directory,files(ii).name])
            files2(idx) = files(ii);
            idx = idx+1;
        end
    end
    files = files2;
end

if isempty(files)
    error(['No files found in ', directory]);
end

headers = cell(1,length(files));
fullFiles = headers;
d = waitbar(0,'Loading Headers');
for ii = 1:length(files)
    headers{ii} = dicominfo([directory,files(ii).name]);
    fullFiles{ii} = [directory,files(ii).name];
    waitbar(ii/length(files),d,['Loading Header ', num2str(ii), ' of ', num2str(length(headers))]);
end
close(d);