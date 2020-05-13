% Uses a simple huygens principle simulation to predict the pressure from
% an array.
% 
% @INPUTS
%   elements: Struct containing the following fields
%       x: x location of element
%       y: y location of element
%       z: z location of element
%       p: Magnitude of pressure at the element surface
%       phi: Phase of pressure relative to a common reference
%   frequency: frequency of array
%   grid: A struct containing the fields X, Y, and Z which represents the
%       x, y, and z locations at which a simulation of pressure is desired.
%   uiHandle: optional handle to a uiFigure that can be used to launch a
%       status bar
% 
% Taylor Webb
% University of Utah
% Summer 2019

function p = simulateArray(elements,frequency,grid,uiHandle)
VERBOSE = 1;
c = 1540;

X = grid.X;
Y = grid.Y;
Z = grid.Z;

p = zeros(size(X));
k = 2*pi*frequency/c;

% Show a status bar
if ~exist('uiHandle','var')
    uiHandle = uifigure;
    closeFigure = 1;
else
    closeFigure = 0;
end
d = waitbar(0,'Simulating');

if VERBOSE
    figure
    plot3(grid.X(:),grid.Y(:),grid.Z(:),'.')
    hold on
    plot3(elements.x,elements.y,elements.z,'*')
    axis('equal')
    xlabel('x');
    ylabel('y');
    zlabel('z');
    legend('Simulation points', 'Element Locations')
end

for ii = 1:length(elements.x)
    % Update Status bar
    waitbar(ii/length(elements.x),d,['Element ', num2str(ii), ' of ', num2str(length(elements.x))]);
    %d.Value = ii/length(elements.x);
    %d.Message = ['Element ', num2str(ii), ' of ', num2str(length(elements.x))];
    
    % Determine distance between the current element and each location in the grid
    R = sqrt((X-elements.x(ii)).^2+(Y-elements.y(ii)).^2+(Z-elements.z(ii)).^2);
    
    % Add the contribution of the current element
    p = p+elements.p(ii)*exp(1i*R*k+1i*elements.phi(ii));
end
close(d);
if closeFigure
    close(uiHandle);
end