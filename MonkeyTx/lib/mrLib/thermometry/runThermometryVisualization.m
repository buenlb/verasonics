
if ~exist('sys','var')
    if 0
        sys.path = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\phantom_20200623\s000049 seg_EPI3D_HIFU2_ETL5_TR25_TE13_10s_15V_10foot_11right_60pos';
    else
        sys.path = uigetdir();
    end

    sys.baseline = 1;
    sys.nSlices = 8;
    [img,header] = loadDicomDir(sys.path);
    
    sys.img = img;
    
    res(1) = double(header{1}.PixelSpacing(1));
    res(2) = double(header{1}.PixelSpacing(1));
    res(3) = header{1}.SliceThickness;
    sys.res = res;
    sys.imgHeader = header{1};
end
%%
visualizeThermometry(sys,6);
% 
% 
% for ii = 1:14
% figure(2) 
% subplot(121)
% imagesc(T(:,:,regionCenter(3)+2,ii),[0,10])
% 
% subplot(122)
% imagesc(roi(:,:,regionCenter(3)+2),[0,10])
% end