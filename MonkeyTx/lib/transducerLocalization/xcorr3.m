% The 3D cross correlation of img and tmplt. This function does not zeropad
% and therefore does not return lags less than 0 or greater than the size
% of the image minus the size of the template.
% 
% @INPUTS
%   img: image in which to search for tmplt
%   tmplt: template to look for in img
% 
% @OUTPUTS
%   corr: correlation matrix
%   lags: lags corresponding to each value in corr. lags is a cell in order
%       to store the lags in each dimension.
% 
% Taylor Webb
% University of Utah

function [corr,lags] = xcorr3(img,tmplt)

xSz = size(img,1)-size(tmplt,1)+1;
ySz = size(img,2)-size(tmplt,2)+1;
zSz = size(img,3)-size(tmplt,3)+1;


corr = zeros(xSz,ySz,zSz);
lags = cell(xSz,ySz,zSz);

for ii = 1:xSz
    for jj = 1:ySz
        for kk = 1:zSz
            xIdx = ii:(ii+size(tmplt,1)-1);
            yIdx = jj:(jj+size(tmplt,2)-1);
            zIdx = kk:(kk+size(tmplt,3)-1);
            corr(ii,jj,kk) = sum(sum(sum(tmplt.*img(xIdx,yIdx,zIdx))));
            lags{ii,jj,kk} = [ii,jj,kk];
        end
    end
end