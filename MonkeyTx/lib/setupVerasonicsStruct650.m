% Returns the element locations of the 650 kHz 256 element array from
% Doppler. The z-dimension is assumed to be in the direction of the
% acoustic beam
% 
% @INPUTS
%   plotGeometry: flag that turns on plots of the results
% 
% @OUTPUTS
%   xE: Euclidian x location of each element
%   yE: Euclidian y location of each element
%   zE: Euclidian z location of each element

function [Trans,xE,yE,zE] = transducerGeometry(plotGeometry)
r = 65; % Radius of curvature
h = 4.2*(8-1)-0.2; % y dimension length
nX = 32; % Number of elements in the long dimension
nY = 8; % Number of elements in the short dimension
d = 4; % element length in mm

curvedDistance = (32-1)*4.2-0.2; % Distance spanned by elements along the x dimension
theta1 = (curvedDistance/(2*pi*r))*pi; % Angle subtended by half of the array.
c = 1540e3; % Speed of sound in mm/s
f = 650e3; % Center frequency
lambda = c/f; % Wavelength in mm 

th = linspace(-theta1,theta1,nX);
x = r*sin(th);
z = -r*cos(th)+r;
if nY > 1
    y = linspace(-h/2,h/2,nY);
else
    y = 0;
end

idx = 1;
for ii = 1:nY
    for jj = 1:nX
        X(idx) = x(jj);
        Y(idx) = y(ii);
        Z(idx) = z(jj);
        
        AZ(idx) = -th(jj);
        
        % Find corners - need these to simulate beam in K-wave
        deltaX = d/2*cos(-th(jj));
        deltaY = d/2;
        deltaZ = d/2*sin(-th(jj));
        corners{idx} = [X(idx)-deltaX,X(idx)-deltaX,X(idx)+deltaX,X(idx)+deltaX;...
                        Y(idx)-deltaY,Y(idx)+deltaY,Y(idx)+deltaY,Y(idx)-deltaY;...
                        Z(idx)+deltaZ,Z(idx)+deltaZ,Z(idx)-deltaZ,Z(idx)-deltaZ];
        idx = idx+1;
    end
end
EL = zeros(size(AZ));

xE = X;
yE = Y;
zE = Z;

%% Convert to wavelengths and plot to confirm correct locations
X = X/lambda;
Z = Z/lambda;
Y = Y/lambda;

if plotGeometry
    figure(1);
    plot3(X,Y,Z,'*');
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    axis('equal')
end

elementPositions = [X',Y',Z',AZ',EL'];

%% Plot full elements
if plotGeometry
    figure;
    hold on
    for ii = 1:length(corners)
        fill3(corners{ii}(1,:),corners{ii}(2,:),corners{ii}(3,:),mod(ii,3))
    end
    xlabel('x')
    ylabel('y')
    zlabel('z')
    axis('equal')
end

%% Element directivity
% Directivity is defined by a number between 1 and 0 along an elevation
% that moves from -pi/2 to pi/2. The Verasonics code expects a 101X1 double
th = linspace(-pi/2,pi/2,101);
directivity = cos(th);

%% Set up Transducer struct
Trans = struct('name','Macaque','frequency',f/1e6,'type',2,'units','mm',...
    'numelements',nX*nY,'ElementPos',elementPositions,'ElementSens',directivity,...
    'connType',1,'spacing',3.2/lambda,'maxHighVoltage',10);

% Some notes:
% - This allows the system to set the Tx BW by default. This will effect
% features like examining what the output waveform looks like and what the
% transmit beam profile is.
