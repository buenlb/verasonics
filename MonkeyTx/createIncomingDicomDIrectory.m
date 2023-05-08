% The following code copies images from the directory pth and places them
% in inPth. The purpose of this code is to easily replenish inPath in order
% to test software that transfers files that have recently arrived from the
% MR scanner. This is not called by any other code - it is just to help me
% test those functions.

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