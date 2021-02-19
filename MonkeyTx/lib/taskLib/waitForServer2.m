% Waits for a message from the server in order to determine wich LGN should
% be targeted. Sets the phases in the TX struct and updates and runs so
% that the correct LGN is targeted on the next transmit event.
% 
% @INPUTS:
%   None really, just obilgator RData for external Verasonics functions.
%       Reads what it needs out of the serial connection
% 
% @OUTPUTS
%   Updates the TX struct with the phases corresponding to the requested
%       LGN.
% 
% Taylor Webb
% University of Utah
% August 2020

function side = waitForServer2(RData)
Resource = evalin('base','Resource');
TX = evalin('base','TX');
TPC = evalin('base','TPC');

phs = Resource.Parameters.phases{2};
voltage = Resource.Parameters.voltages(2);

side = 'Left';
pause(3);

TX(1).Delay = phs;
TPC(5).hv = voltage;
setTpcProfileHighVoltage(voltage,5);
disp(['Setting TPC(5).hv = ', num2str(voltage)]);
%% Update and run in base
assignin('base','TX', TX);
assignin('base','TPC', TPC);
assignin('base','Resource', Resource);
% Set Control command to update TX
Control = evalin('base','Control');
Control(1).Command = 'update&Run';
Control(1).Parameters = {'TX'};
Control(2).Command = 'set&Run';
Control(2).Parameters = {'TPC',5,'hv',voltage};
assignin('base','Control', Control);

disp(['Sonicating ', side, ' LGN'])