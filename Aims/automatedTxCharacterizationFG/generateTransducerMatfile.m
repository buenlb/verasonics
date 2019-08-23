% generateTransducerFile creates a MAT file with the transducer
% characteristics stored as individual parameters.


% Transducer Parameters
serial          = '1401001';
model           = 'ValpeyFisher ISO.504HP';
frequency       = 0.5      ; % Frequency                              [mHz]
diameter        = 0.5*25.4; % aperture diameter                       [mm]
focalLength     = 1.0*25.4 ; % Focal length (use 0 if Tx is unfocused) [mm]

computedFocus   = 25.4     ; % computed focus (overrides if transducer is focused) [mm]



% Error checks and saving information
FileLocation = 'C:\Users\Verasonics\Box Sync\TransducerCharacterizations\Transducer Files';
cd(FileLocation);

modelName = strrep(model,'-','_');
modelName = strrep(modelName,' ','_');
modelName = strrep(modelName,'.','_');

serialName = strrep(serial,'-','_');
serialName = strrep(serialName,' ','_');

if modelName(1) == '_' || serialName(1) == '_' || modelName(end) == '_' || serialName(end) == '_'
    error('Model and serial number invalid for saving.')
else
    save([modelName,'_',serialName],'serial','model','frequency','diameter','focalLength','computedFocus');
end