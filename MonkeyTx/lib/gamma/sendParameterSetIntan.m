% Send a binary code to the intan system to tell the user which parameter
% set was delivered during each sonication
% 
% @INPUTS
%   daq: pointer to the USB1208FS device generated with DaqDeviceIdx from
%     the psychtoolbox
%   param: A number representing the delivered US parameters. This number
%     will be sent as a binary number to the digital channel of the Intan
% 
% The code assumes that the serial binary code is read from port A0
% (Channel 21) and that none of the other ports are in use (they will be
% zeroed out by this code). After the message is sent port A0 is reset to
% zero.
function sendParameterSetIntan(daq,param)

% Convert to binary
biRaw = dec2bin(param);

biWithTriggers = ['1',biRaw,'1'];

for ii = 1:length(biWithTriggers)
    curBit = str2double(biWithTriggers(ii));
    DaqDOut(daq,0,curBit);
    WaitSecs(1e-3);
end

DaqDOut(daq,0,0);