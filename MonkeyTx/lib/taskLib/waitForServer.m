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
TPC = evalin('base','TPC');

pt = serial('COM1');
fopen(pt);
received = 0;

%% Add previous successful sonication to log
if ~isempty(Resource.Parameters.priorSonication)
    Resource.Parameters.log.totalSonications = Resource.Parameters.log.totalSonications + 1;
    if Resource.Parameters.priorSonication == 'R'
        Resource.Parameters.log.rightSonications = Resource.Parameters.log.rightSonications + 1;
    elseif Resource.Parameters.priorSonication == 'L'
        Resource.Parameters.log.leftSonications = Resource.Parameters.log.leftSonications + 1;
    else
        error(['Unknown sonication type for prior sonication: ',...
                Resource.Parameters.priorSonication]);
    end
    
    log = Resource.Parameters.log;
    save(Resource.Parameters.logFileName, 'log');
end

%% Communicate with server
% If this is the first sonication, let the server know that the skull image
% is complete and we are ready for sonication.
if Resource.Parameters.log.totalSonications == 0
    fprintf(pt,'INIT');
end

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
            fprintf(pt,'INIT');
            disp('Initialized');
        case 'TERMINATE'
            fprintf(pt,'TERMINATE');
            fclose(pt);
            disp('Finished')
            closeVSX();
            return
        case 'E:L'
            phs = Resource.Parameters.phases{1};
            voltage = Resource.Parameters.voltages(1);
            received = 1;
            fprintf(pt,'E:L');
            fclose(pt);
            Resource.Parameters.priorSonication = 'L';
            disp('Preparing to sonicate Left LGN');
        case 'E:R'
            phs = Resource.Parameters.phases{2};
            voltage = Resource.Parameters.voltages(2);
            received = 1;
            fprintf(pt,'E:R');
            fclose(pt);
            Resource.Parameters.priorSonication = 'R';
            disp('Preparing to sonicate Right LGN');
        otherwise
            fprintf(pt,'ERR');
            fclose(pt);
            error(['Received invalid message from server; ', side])
    end
end

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