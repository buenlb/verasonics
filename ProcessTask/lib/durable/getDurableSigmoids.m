% plotDurableSigmoids takes a matrix of delays and choices to plot an
% average sigmoid across time points.
% 
% @INPUTS
%   dVectors: matrix of delays. Each row is a different delay and each
%       column is a different time point. Each page is a different session
%   chVectors: matrix of choices. Each row corresponds to a different delay
%       and each column represents a different time point. Each entry is
%       the average number of times that the subject looked left during the
%       relevant time point in a single session. Each page represents a
%       different session.
% 
% @OUTPUTS: The function outputs the parameters of a sigmoid after 
% % averaging each time point in dVectors and chVectors. Each output
% parameter has a length of size(dVectors,2)
%   slope: slope of the sigmoid
%   bias: bias of the sigmoid
%   downshift: shift of the sigmoid
%   scale: scale factor of the sigmoid
%   
% Taylor Webb
% University of Utah

function [slope, bias, downshift, scale, delays, chOut] = getDurableSigmoids(dVectors,chVectors)

delays = unique(dVectors(~isnan(dVectors)));
ch = nan(length(delays),size(dVectors,2),size(dVectors,3));
for hh = 1:size(dVectors,3)
    for ii = 1:size(dVectors,2)
        for jj = 1:size(dVectors,1)
            ch(delays==dVectors(jj,ii,hh),ii,hh) = chVectors(jj,ii,hh);
        end
    end
end

slope = nan(size(dVectors,2),1);
bias = slope;
downshift = slope;
scale = slope;
chOut = nan(length(delays),size(ch,2));
for ii = 1:size(ch,2)
    curCh = mean(ch(:,ii,:),3,'omitnan');
    [slope(ii),bias(ii),downshift(ii),scale(ii)] = fitSigmoid(delays,curCh);
    chOut(:,ii) = curCh;
end