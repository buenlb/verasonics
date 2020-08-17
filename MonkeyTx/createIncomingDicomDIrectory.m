inPth = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRImages\IncomingDicoms\';

pth = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRImages\20200629\053\';

files = dir([pth,'*.dcm']);
for ii = 1:length(files)
    copyfile([pth,files(ii).name],[inPth,'img',num2str(ii,'%03d'),'.dcm']);
end

pth = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRImages\20200629\054\';

files = dir([pth,'*.dcm']);
for ii = 1:length(files)
    copyfile([pth,files(ii).name],[inPth,'img',num2str(ii+120,'%03d'),'.dcm']);
end