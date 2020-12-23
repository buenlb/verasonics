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

Resource.Parameters.log.totalSonications = Resource.Parameters.log.totalSonications+1;
if mod(Resource.Parameters.log.totalSonications,2)
    voltage = 5;
    phs = Resource.Parameters.phases{1};
    disp('LEFT')
else
    voltage = 1.6;
    phs = Resource.Parameters.phases{2};
    disp('RIGHT')
end
TX(1).Delay = phs;
TPC(5).hv = voltage;
keyboard
disp(['Setting TPC(5).hv = ', num2str(voltage)]);
%% Update and run in base
% UI(1).Statement = '[result,hv] = setTpcProfileHighVoltage(2,1);';
% UI(2).Statement = 'hv1Sldr = findobj(''Tag'',''hv5Sldr'');';
% UI(3).Statement = 'set(hv5Sldr,''Value'',hv);';
% UI(4).Statement = 'hv5Value = findobj(''Tag'',''hv5Value'');';
% UI(5).Statement = 'set(hv5Value,''String'',num2str(hv,''%.1f''));';
% assignin('base','UI',UI);
% 
assignin('base','TX', TX);
% assignin('base','TPC', TPC);
assignin('base','Resource', Resource);
% % Set Control command to update TX
Control.Command = 'update&Run';
Control.Parameters = {'TX'};
% Control(2).Command = 'set&Run';
% Control(2).Parameters = {'TPC',5,'hv',voltage};
assignin('base','Control', Control);

% disp(['Sonicating ', side, ' LGN'])