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

function side = waitForServer(RData)
Resource = evalin('base','Resource');
TX = evalin('base','TX');

pt = serial('COM1');
fopen(pt);
received = 0;

disp('Waiting for instruction from server');

while ~received
    % Scan until a message is received. The while loop essentially makes an
    % infinite time-out though the system will print a warning for each
    % time through the loop once the message is finally received.
    side = fscanf(pt);
    while isempty(side)
        side = fscanf(pt);
    end
    
    % Serial strings are terminated with a newline, remove it for
    % simplicity.
    side = side(1:end-1);
    
    % Determine what to do with the message
    switch side
        case 'INIT'
            fprintf(pt,'READY');
        case 'LEFT'
            phs = Resource.Parameters.phases{1};
            received = 1;
            fprintf(pt,'LEFT');
            fclose(pt);
        case 'RIGHT'
            phs = Resource.Parameters.phases{2};
            received = 1;
            fprintf(pt,'RIGHT');
            fclose(pt);
        otherwise
            fprintf(pt,'ERR');
            fclose(pt);
            error('Received invalid message from server.')            
    end
end

TX(1).Delay = phs;

%% Update and run in base
assignin('base','TX', TX);
assignin('base','Resource', Resource);
% Set Control command to update TX
Control = evalin('base','Control');
Control.Command = 'update&Run';
Control.Parameters = {'TX'};
assignin('base','Control', Control);

disp(['Sonicating ', side, ' LGN'])