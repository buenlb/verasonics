% Stacks all of the individual LSTIM trials into a variable named data.
% Data is NxM where N is the total number of sonications across all
% sessions represented in bnd and M is the number of EEG windows present
% between each sonication.
% 
% @INPUTS
%   bnd: EEG data after analysis with multiGammaResults.m
%   bndIdx: Which of the frequency bands in bnd to use to create the
%     output. This is an index into the 2nd dimension of bnd. 
%   description: Struct with fields:
%       dc: Nx1 matrix of duty cycles. Correspondes to the 1st dimension of
%         bnd.
%       magnet: Nx1 binary matrix telling whether session was in/out of
%         magnetic field.
%       monkey: Nx1 matrix telling which monkey the data was collected in.
%       p:  Nx1 matrix of pressure
% 
% @OUTPUT
%   data: All the EEG measured between sonications
% 
% Taylor Webb
function [data,outDescription] = stackLstimData(bnd,bndIdx,description)

data = [];
dc = [];
magnet = [];
monkey = [];
p = [];
lgn = [];
sNumber = [];

for ii = 1:size(bnd,1)
    curData = bnd(ii,bndIdx).shortWindow.bndDuring;

    % Error check - there should always be an even # of sonications
    if mod(size(curData,1),2)
        error('Expected an even number of sonications!')
    end

    data = cat(1,data,curData);

    dc = cat(1,dc,ones(size(curData,1),1)*description.dc(ii));
    magnet = cat(1,magnet,ones(size(curData,1),1)*description.magnet(ii));
    monkey = cat(1,monkey,ones(size(curData,1),1)*description.monkey(ii));
    p = cat(1,p,ones(size(curData,1),1)*description.p(ii));
    curLgn = ones(size(curData,1),1);
    curLgn(1:2:end) = -1;
    lgn = cat(1,lgn,curLgn);
    sNumber = cat(1,sNumber,ones(size(curData,1),1)*ii);
end

outDescription = struct('dc',dc,'magnet',magnet,'monkey',monkey,'p',p,'lgn',lgn,...
    'sNumber',sNumber);