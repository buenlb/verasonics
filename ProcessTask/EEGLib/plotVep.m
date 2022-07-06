% Automatically averages and plots EEG data with shaded SEM.
% 
% @INPUTS
%   t: time vector for EEG data
%   eeg: eeg data in a matrix with rows or columns representing repeated
%       measurements to be averaged.
%   dim: dimension across which to average. 
%   ax: axis on which to plot the result
%   lineprops: style instructions for plotting the result
% 
% @OUTPUTS
%   meanEeg: averaged EEG vector
%   sem: Standard error of the mean computed at each time point
% 
% Taylor Webb
% University of Utah

function [meanEeg,sem] = plotVep(t,eeg,dim,ax,lineprops)
if ~exist('dim','var') || isempty(dim)
    dim = 1;
end
if ~exist('ax','var') || isempty(ax)
    h = figure;
    ax = gca;
end

meanEeg = mean(eeg,dim,'omitnan');
lgth = sum(~isnan(eeg),dim);
sem = std(eeg,[],dim,'omitnan')./sqrt(lgth);

axes(ax);

if exist('lineprops','var')
    shadedErrorBar(t,meanEeg,sem,'lineprops',lineprops)
else
    shadedErrorBar(t,meanEeg,sem)
end