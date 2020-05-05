% frontEdgeMatchedFilter takes a signal, s, and a template, tmplt, and,
% using the template, performs a matched filter search to determine the
% front edge of the template in the signal.
% 
% @INPUTS
%   s: signal
%   tmplt: Template to search for in s
%   dt: signal spacing for normalization of the template signal
% 
% @OUTPUTS
%   fe: index of front edge
%   R: Matched Filter Results normalized to give energy of signal produced
%       by matched filter at each location
% 
% Taylor Webb
% University of Utah
% April 2020

function [fe,R] = frontEdgeMatchedFilter(s,tmplt,dt)
% Normalize the filter
tmpltEnergy = trapz(dt,tmplt.^2);
tmplt = tmplt/sqrt(tmpltEnergy);

% perform match filtering
[R,lags] = xcorr(s,tmplt); 
R = (dt*R).^2; % convert to power instead of volts

% take only positive side
R = R(lags>=0);

[matchFiltPeak,fe] = max(R);

display(['Energy in Template: ',num2str(tmpltEnergy,3)])
display(['Matched Filter Peak: ',num2str(matchFiltPeak,3)])