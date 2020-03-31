% permutes the 3d matrix, img, so that the x, y, and z dimensions are in
% intuitive order.
% 
% @INPUTS
%   img: Matrix to be permuted
%   xDim: Dimension corresponding to x
%   xDim: Dimension corresponding to x
%   xDim: Dimension corresponding to x
%
% @OUTPUTS
%   img: Perumted version of input
% 
% Taylor Webb
% University of Utah
% March 2020

function img = permuteImg(img,xDim,yDim,zDim)

img = permute(img,[xDim,yDim,zDim]);