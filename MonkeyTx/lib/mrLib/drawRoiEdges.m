function img = drawRoiEdges(img, roi)

roi = logical(roi);
roiEdges = edge(roi);
if length(size(img)) ~= 3 || size(img,3) ~= 3
    error('Expecting a planar RGB image. Dimensions must by MxNx3');
end

for ii = 1:3
    f_cImg = img(:,:,ii);
    if isa(f_cImg,'uint8')
        f_cImg(roiEdges) = 255;
    elseif isa(f_cImg,'double')
        f_cImg(roiEdges) = 1;
    else
        error(['img has an unknown data type: ', class(f_cImg)])
    end
    img(:,:,ii) = f_cImg;
end