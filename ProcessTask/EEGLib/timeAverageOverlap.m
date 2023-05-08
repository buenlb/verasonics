% Averages the variable, v, over time in windows of size window. Assumes a
% temporal seperation between the elements of v as dt. If overlap is
% greater than zero it slides the window with an overlap percentage of
% overlap (default is zero).
% 
% @INPUTS
%   v: signal to average
%   dt: sample period
%   window: Window over which to average (must be same units as dt)
%   overlap: How much to overlap consecutive windows (%)
% 
% Taylor Webb
% University of Utah
% Spring 2023


function [m,tAvg,sDev,sError] = timeAverageOverlap(v,dt,window,overlap)
if ~exist('overlap','var')
    overlap = 0;
end

if isrow(v)
    v = v.';
end

windowIdx = ceil(window/dt);

gap = round((window-overlap*window/100)/dt);
num_windows = floor((length(v) - windowIdx)/gap)+1;

tAvg = window:gap:num_windows*gap;
if length(tAvg)<num_windows
    tAvg = window:gap:(num_windows+1)*gap;
end
t = 0:dt:length(v);

m = nan(size(tAvg));
sDev = nan(size(tAvg));
sError = nan(size(tAvg));
for ii = 1:length(tAvg)

    if ii == 1
        startIdx = 1;
        endIdx = windowIdx;
    else
        startIdx = (ii-1)*gap+1;
        endIdx = (ii-1)*gap+windowIdx;
    end
    
    curIdx = startIdx:endIdx;
    m(ii) = mean(v(curIdx),'omitnan');
    sDev(ii) = std(v(curIdx),[],1,'omitnan');
    sError(ii) = semOmitNan(v(curIdx),1);
end