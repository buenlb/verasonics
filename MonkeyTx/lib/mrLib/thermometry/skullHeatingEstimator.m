clear; close all; clc
files = dir('C:\Users\Taylor\Documents\Data\Transducers\DopplerJEC482_characterization\3D_scan_12_4_57\*.snq');
for ii = 1:length(files)
    [img(:,:,ii),y,x,~,~,ztmp] = readAIMS(['C:\Users\Taylor\Documents\Data\Transducers\DopplerJEC482_characterization\3D_scan_12_4_57\',files(ii).name]);
end
z = 25:0.5:70;

tmp = (img(:,:,z<=30));
powerAtSkull = (max(-tmp(:))/max(-img(:)))^2;

% attenuation leaves only 30% of PRESSURE. Assume the skull is still free
% field pressure and assume a standing wave that doubles the result. Also
% assume 2.7 db/cm (0.31 Np/cm) absorption (Pinton et al.) in the skull
% 0.068 np/cm in the brain
skullMultiplier = powerAtSkull*(1/0.3)^2*4*(0.31/0.068)