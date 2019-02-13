r = 65; % Radius of curvature
h = 25.6; % y dimension length
nX = 32; % Number of elements in the long dimension
nY = 8; % Number of elements in the short dimension
theta1 = asin(46/65); % Angle subtended by half of the array. 46 is half of the projected x dimension of the array
c = 1540e3; % Speed of sound in mm/s
f = 500e3; % Center frequency
lambda = c/f; % Wavelength in mm 

th = linspace(-theta1,theta1,nX);
x = r*sin(th);
z = r*cos(th);
y = linspace(-h/2,h/2,nY);

idx = 1;
for ii = 1:nY
    for jj = 1:nX
        X(idx) = x(jj);
        Y(idx) = y(ii);
        Z(idx) = z(jj);
        
        AZ(idx) = -th(jj);
        idx = idx+1;
    end
end
EL = zeros(size(AZ));
Z = Z-r;
Z = -Z;

%% Convert to wavelengths and plot to confirm correct locations
X = X/lambda;
Z = Z/lambda;
Y = Y/lambda;

figure(1);
plot3(X,Y,Z,'*');
xlabel('X');
ylabel('Y');
zlabel('Z');
axis('equal')

elementPositions = [X',Y',Z',AZ',EL'];

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

