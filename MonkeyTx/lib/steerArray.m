% findPhaseCorrections finds the phase corrections for elements defined by
% the struct elements to focus at a desired location
% 
% @INPUTS
%   elements: struct containing at least the fields
%       x: x location of the elements
%       y: y location of the elements
%       z: z location of the elements
%   focus: [x,y,z] location of the focal spot in meters
%   frequency: frequency of the array in MHz
%   plotPhaseResults: flag determining whether or not to show the phases overlaid
%      on the array
% 
% @OUTPUTS
%   elements: the same elements struct that was passed in with the
%       additional field phi set to the phase for that element
%   phi: phase for each element relative to the first element
%   t: delays relative to a period at the given frequency
% 
% Taylor Webb
% University of Utah
% Summer 2019

function [elements,phi,t] = steerArray(elements,focus,frequency,plotPhaseResults)
VERBOSE = 0;
c = 1490; % Speed of sound in m/s

frequency = frequency*1e6; % convert to Hz

k = 2*pi*frequency/c;

phi = zeros(length(elements.x),1);
t = phi;

if nargin < 4
    plotPhaseResults = 1;
end

if VERBOSE
    figure
    plot3(elements.x,elements.y,elements.z,'*')
    hold on
    plot3(focus(1),focus(2),focus(3),'^')
    axis('equal')
    xlabel('x');
    ylabel('y');
    zlabel('z');
    legend('Element Locations','Focal Point')
end

for ii = 1:length(elements.x)
    d = sqrt((elements.x(ii)-focus(1))^2 + (elements.y(ii)-focus(2))^2 + (elements.z(ii)-focus(3))^2);
    if ii == 1
        phi(ii) = 0;
        d0 = d;
    else
        phi(ii) = (d0-d)*k;
        t(ii) = frequency*(d0-d)/c;
    end
end
t = t-min(t);
elements.phi = phi;
elements.t = t;

if plotPhaseResults
    plotElementValues(elements.x*1e3,elements.y*1e3,elements.z*1e3,t,'jet');
    title('Phase (N Cycles Delayed)');
    drawnow
end