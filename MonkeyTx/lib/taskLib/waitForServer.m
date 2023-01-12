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

function msg = waitForServer(RData)
Resource = evalin('base','Resource');
TX = evalin('base','TX');
TPC = evalin('base','TPC');
Trans = evalin('base','Trans');

received = 0;

if ~isfield(Resource.Parameters,'verasonicsPort')
    Resource.Parameters.verasonicsPort = serial('COM1');
    fopen(Resource.Parameters.verasonicsPort);
%     fprintf(Resource.Parameters.verasonicsPort,'INIT');
end
pt = Resource.Parameters.verasonicsPort;

%% Communicate with server
disp('Waiting for instruction from server');

while ~received
    % Scan until a message is received. The while loop essentially makes an
    % infinite time-out though the system will print a warning for each
    % time through the loop once the message is finally received.
    msg = fscanf(pt);
    while isempty(msg)
        msg = fscanf(pt);
    end
    
    % Serial strings are terminated with a newline, remove it for
    % simplicity.
    msg = msg(1:end-1);
    
    % Determine what to do with the message
    switch msg
        case 'INIT'
            fprintf(pt,'INIT');
            disp('Initialized');
        case 'ENDSONICATING'
            fprintf(pt,'ENDSONICATING');
            fclose(pt);
            disp('Finished Sonicating')
            closeVSX();
            return;
        case 'TERMINATE'
            fprintf(pt,'TERMINATE');
            fclose(pt);
            disp('Finished')
            closeVSX();
            return
        case 'FOCUS'
            fprintf(pt,'FOCUS')
            [voltage,target,nTargets,dev] = receiveFocusFromServer(pt);
            disp('New Focal Spot:')
            disp(['  Focus: <', num2str(target(1)), ',',num2str(target(2)), ',',num2str(target(3)), '>'])
            disp(['  Voltage: ', num2str(voltage), ' V'])
            Resource.Parameters.log.voltages(end+1) = voltage;
            Resource.Parameters.log.targets(end+1,:) = target;
            if length(Resource.Parameters.log.Date) == 1
                date = cell(1);
                date{1} = Resource.Parameters.log.Date;
                date{2} = datetime;
                Resource.Parameters.log.Date = date;
            else
                Resource.Parameters.log.Date{end+1} = datetime;
            end
            log = Resource.Parameters.log;
            save(Resource.Parameters.logFileName,'log');
            received = 1;
        otherwise
            fprintf(pt,'ERR');
            fclose(pt);
            error(['Received invalid message from server; ', msg])
    end
end

targets = generateTargets(target,nTargets,dev);

xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);
elements.x = xTx*1e-3;
elements.y = yTx*1e-3;
elements.z = zTx*1e-3;

if length(TX) ~= size(targets,1)
    error('You cannot change the number of targets in the middle of a session!')
end

% Find the phases for the first focal spot
for ii = 1:size(targets,1)
    elements = steerArray(elements,targets(ii,:)*1e-3,Trans.frequency,0);
    phs = [elements.t]';
    TX(ii).Delay = phs;
end
TPC(5).hv = voltage;
setTpcProfileHighVoltage(voltage,5);
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