function visaObj = establishKeysightConnection(id)
% The second argument to the VISA function is the resource string for your
% instrument
visaObj = visa('agilent',id);
% Set the buffer size
visaObj.InputBufferSize = 100000;
% Set the timeout value
visaObj.Timeout = 10;
% Set the Byte order
visaObj.ByteOrder = 'littleEndian';