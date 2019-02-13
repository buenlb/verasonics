% computeTxDelays_monkey computes delays for the macaque transducer.
% 
% @INPUTS
%   focus: the desired focal location. Must be referenced to the same
%      origin as the element locations in Trans. A 3x1 vector <x,y,z> (mm).
%   Trans: Struct defining the transducer. This is the same struct expected
%      by VSX
%   Resource: VSX Resource struct. At a minimum must include
%     Resource.Parameters.speedOfSound
% 
% @OUTPUTS
%   delays: Delays to apply to each element in order to focus at the
%     desired target

function delays = computeTXDelays_monkey(focus,Trans,Resource)

elLocations = Trans.ElementPos(:,1:3);
f = Trans.frequency;
c = Resource.Parameters.speedOfSound;

% Vectors pointing from the elements to the focus
R = elLocations-repmat(focus,Trans.numelements,1);

% For a spherical focusing law the delays are simply set to make each
% element arrive at the same time
delays = sqrt(sum(R.^2,2))/c;

% Convert delays to fractions of a period.
delays = delays*f;
