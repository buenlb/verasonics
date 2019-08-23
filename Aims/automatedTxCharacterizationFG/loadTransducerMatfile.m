function [Tx] = loadTransducerMatfile(model,serial)
% Load transducer information stored in a MATfile.  Inputs are the name of
% the model (read directly from the transducer) and the serial number of
% the transducer (read directly from the transducer).  Error checks include
% bad name (underscore at the beginning and end of the name) and the
% specified transducer was not found (shows the available transducers)
FileLocation = 'C:\Users\Verasonics\Box Sync\TransducerCharacterizations\Transducer Files';

modelName = strrep(model,'-','_');
modelName = strrep(modelName,' ','_');

serialName = strrep(serial,'-','_');
serialName = strrep(serialName,' ','_');

if modelName(1) == '_' || serialName(1) == '_' || modelName(end) == '_' || serialName(end) == '_'
    error('Invalid model and serial number.')
end

searchstring = [modelName,'_',serialName];

try load([FileLocation,'/',searchstring]);
    Tx.serial        = serial;
    Tx.model         = model;
    Tx.diameter      = diameter;
    Tx.frequency     = frequency;
    Tx.focalLength   = focalLength;
    Tx.computedFocus = computedFocus;
catch
    what(FileLocation)
    disp(' ');
    error(['Could not find file. Attempted to search for: ',searchstring]);
end





