% initializeTx initializes the focal value in the struct Tx. Tx should
% contain the fields listed below. The Tx struct is returned with a new
% field, computedFocus, that is used by the rest of characterize Tx to
% determine how to select relevant grids.
% 
% @INPUTS
%   Tx: Struct containing the following fields:
%       Tx.frequency: center frequency at which the Tx is run during this
%         characterization
%       Tx.diameter: active aperture diameter
%       Tx.focalLength: focal length in mm. Use zero if Tx is unfocused
%       Tx.serial: Tx serial number
%       Tx.model: Tx make and model
%       Tx.cone: cone used in characterization. 
%   NOTE: The directory in which the characterizatino is saved is 
%       determined by a combination of the fields frequency, model, and 
%       cone.
% 
% @OUTPUTS
%   Tx: Struct with all the above fields and an additional field called
%      computedFocus which is the estimated location of the focus
%      referenced to the transducer face.
% 
% Taylor Webb
% University of Utah
% 2019

function Tx = initializeTx(Tx)
%% Error checking: Make sure required fields are present
if ~isfield(Tx,'frequency')
    error('Tx Struct: frequency is a required field')
end
if ~isfield(Tx,'diameter')
    error('Tx Struct: diameter is a required field')
end
if ~isfield(Tx,'focalLength')
    error('Tx Struct: focalLength is a required field')
end
if ~isfield(Tx,'serial')
    error('Tx Struct: serial is a required field')
end
if ~isfield(Tx,'model')
    error('Tx Struct: model is a required field')
end
if ~isfield(Tx,'cone')
    error('Tx Struct: cone is a required field')
end

%% Estimate focus relative to Tx face
if Tx.focalLength
    % Estimate the distance from the center of the Tx face to the edge. The
    % zero point along the z-axis is set to be the edge of the transducer.
    x = Tx.focalLength-sqrt(Tx.focalLength^2-Tx.diameter^2/4);
    Tx.computedFocus = Tx.focalLength-x;
else
    % Compute Fraunhofer distance assuming circular transducer
    Tx.computedFocus = Tx.diameter^2/(4*lambda);
end