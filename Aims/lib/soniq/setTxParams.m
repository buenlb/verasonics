% Sets transducer paramters for record keeping only. These will be recorded
% in the header files produced by Soniq to help keep straight which
% transducer was characterized
% 
% @INPUTS
%   lib: MATLAB alias for Soniq DLL
%   Tx: Struct with the following fields
%       frequency: center frequency of Tx in MHz
%       diameter: Aperture diameter in mm
%       model: Model name
%       serial: Serial number
%       focalLength: focal length in mm (use zero if Tx is unfocused)
% 
% @OUTPUTS
%   None
% 
% Taylor Webb
% University of Utah

function setTxParams(lib,Tx,FgParams)

calllib(lib,'SetXdcrModel',Tx.model);
calllib(lib,'SetXdcrSerial',Tx.serial);
calllib(lib,'SetXdcrFreqMHz',Tx.frequency);
calllib(lib,'SetXdcrPRFHz',1/FgParams.burstPeriod);
calllib(lib,'SetXdcrDiameter',Tx.diameter/10)
calllib(lib,'SetXdcrFLX',Tx.focalLength)
