% Move sorted dicoms to a folder that simulates their arrival from MR
% scanner

phasePath = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\phantom_20200623\s000049 seg_EPI3D_HIFU2_ETL5_TR25_TE13_10s_15V_10foot_11right_60pos\';
magPath = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\phantom_20200623\s000048 seg_EPI3D_HIFU2_ETL5_TR25_TE13_10s_15V_10foot_11right_60pos\';

incomingDcms = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\phantom_20200623\incomingImages\';

mgImgs = dir([magPath,'*.dcm']);
phImgs = dir([phasePath,'*.dcm']);

if length(mgImgs) ~= length(phImgs)
    error('Something is wrong, the number of magnitude and phase images do not match!')
end

for ii = 1:length(phImgs)
    copyfile([magPath,mgImgs(ii).name],[incomingDcms,'img',num2str(ii,'%04d'),'.dcm']);
    copyfile([phasePath,mgImgs(ii).name],[incomingDcms,'img',num2str(ii+120,'%04d'),'.dcm']);
end