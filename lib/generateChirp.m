% Generate a frequency-modulated chirp
% 
% @INPUTS
%   frequency: the center frequency to be modulated
%   nosegments: 5 for a long chirp and 3 for a short chirp
% 
% @OUTPUTS
%   pc: Pulse Code matrix with values assigned according to the structure 
%     of the arbitrary waveform generator. See Verasonics documentation for
%     details of this structure. TW.PulseCode should be set to this
%     returned value
% 
% Jan Kubanek (jan.kubanek@utah.edu)
% University of Utah
% March 2019

function vect = generateChirp(frequency, nosegments)

switch nosegments
    case 3
        fm = [0.75, 1.0, 1.25]; %frequency multipliers for the individual chirp segments
    case 4
        fm = [0.75, 1.0, 1.25, 1.5]; %frequency multipliers for the individual chirp segments
    case 5
        fm = [0.5, 0.75, 1.0, 1.25, 1.5]; %frequency multipliers for the individual chirp segments
end

fs = 250e6; %Verasonics time base
vect = [];
for m = fm
    sa = round(fs / (frequency * m) / 2); %samples per square pulse
%    if (sa > 175) %original Verasonics limit
    if (sa > 500) %my new limit
        NS = 3; %size of a sample chunk
        R = sa / NS; %number of times the chunk must be repeated
        sa = NS;
    else
        R = 1; %normally repeat only once
    end
    
    vect(end + 1, :) = [0, sa, 0, 0, R]; %positive square (half wavelength)
    vect(end + 1, :) = [0, -sa, 0, 0, R]; %negative square (half wavelength)
end
%vect(end + 1, :) = 0;