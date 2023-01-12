% DrugDelivery puts the verasonics in a state to obtain skull images and or
% deliver a nanoparticle opening sonication
% 
% Actions: 
%   Run drugDelivery.m
%     Upon running drugDelivery.m the system first asks the user which
%       monkey (c for Calvin, h for Hobbes) is in the setup. It uses this
%       information to set the location of the gold standard data to which
%       to compare new skull images
%   INIT 
%     The system then waits for initial instructions from the server
%       (received via serial port). These instructions contain details for
%       the acoustic parameters and upon receipt of the INIT command the
%       system sets up the .mat file that will give instructions to VSX.
%   USER COMMANDS
%     After initialization the system awaits instructions from a user.
%       Possible commands are:
%         i: Acquire a skull image (takes approximately 1 minute).
%         s: Prepare the system to deliver a particle opening sonication.
%           This will launch VSX with the appropriate transmit parameters
%           but the system will wait to deliver those parameters until the
%           user presses enter. It can take up to  30 seconds for the
%           system to be ready and waiting for the enter key. When it is
%           ready the command line will display the message, "Press Enter
%           When Ready >>"
%         t: Terminate. Acquire a last skull image and exit
% 
% Taylor Webb
% University of Utah
% December 2020

%% Clear the workspace and add necessary paths
clear all; close all; clc;
% cd 'C:\Users\Verasonics\Documents\Vantage-4.4.0-2012091800';
activate;

addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\');
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\taskLib');
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\placementVerification');
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\lib\');
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\MATFILES\');
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\setupScripts\');
addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\mrLib\transducerLocalization\');

%% User defined inputs
monk = input('Monkey (c/h): ', 's');
switch monk
    case 'c'
        goldStd = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20220203\UltrasoundData\calvinGS.mat';
        txSn = 'JAB800';
    case 'h'
        goldStd = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20220202\UltrasoundData\hobbesGS.mat';
        txSn = 'JAB800';
    otherwise
        error([monk, ' not a recognized subject! Please choose c or h (case sensitive).'])
end
expPath = 'C:\Users\Verasonics\Documents\firstTargetData\';
disp(['Using Tx: ', txSn]);

%% Open Communications
pt = serial('COM1');
fopen(pt);
received = 0;

%% Listen for init command from server
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
    
    switch msg
        case 'INITD'
            disp('Getting initial parameters')
            fprintf(pt,'INITD');
            
            fName = fscanf(pt);
            while isempty(fName)
                fName = fscanf(pt);
            end
            fName = fName(1:end-1);
            fprintf(pt,fName);
            
            % Get duty cycle, duration, and PRF
            dc = receiveDoubleFromServer(pt);
            prf = receiveDoubleFromServer(pt);
            duration = receiveDoubleFromServer(pt);
            frequency = receiveDoubleFromServer(pt);            
            
            % Get first target and voltage.
            [voltage, target,nTargets,dev] = receiveFocusFromServer(pt);
                        
            disp('Initializing with parameters:')
            disp(['  Focus: <', num2str(target(1)), ',',num2str(target(2)), ',',num2str(target(3)), '>'])
            disp(['  Voltage: ', num2str(voltage), ' V'])
            disp(['  PRF: ', num2str(prf), ' Hz'])
            disp(['  Duty: ', num2str(dc), '%'])
            disp(['  Freqency: ', num2str(frequency), 'MHz'])
            disp(['  Duration: ', num2str(duration), ' ms'])
            disp(['  Target Variation (<x,y,z>): <', num2str(dev(3)),',',num2str(dev(2)),',',num2str(dev(3)),'>'])
            disp(['  Saving in: ', fName])
            
            log = struct('focus',target,'voltage',voltage,'prf',prf,'dc',dc,...
                'frequency',frequency,'duration',duration,'nTargets',nTargets,...
                'dev',dev);
            
            doppler256_neuromodulate2_drugDelivery(duration*1e-3,voltage,target,prf,dc,frequency,[expPath,fName,'_log'],txSn,dev,nTargets);
            received = 1;
            save([expPath, fName],'log');
        otherwise
            error(['Unrecognized message from server: ', msg])
    end
end

%% Wait for input from user
skIdx = 0;
terminate = 0;
while ~terminate
    command = input('Give a command (i: image the skull; s: prepare for sonication; t: terminate)','s');
    switch command
        case 'i'
            rescan = 1;
            while rescan
                curFileName = [expPath, fName, '_sk', num2str(skIdx)];
                % VSX clears variables so we need to store them

                save tmpBeforeVSX.mat
                [gsParams,gs,cr] = testArrayPlacement_firstTargetTask(goldStd,curFileName,[],1);
                load tmpBeforeVSX.mat
                delete('tmpBeforeVSX.mat')
                disp('Skull Image Complete');

                waitfor(verifyPreTask(goldStd,curFileName));
                rs = load('guiOutput.mat');
                rescan = rs.rescan;

                skIdx = skIdx+1;
            end
        case 's'
            save tmpBeforeVSX.mat
            filename = 'doppler256_neuromodulate2_drugDelivery.mat';
            VSX;
            load tmpBeforeVSX.mat
            usTrialNo = input('On what trial was the US activated (enter 0 if you forgot to look)>>');
            log.usTrialNo = usTrialNo;
            
            sonicationTime = input('How many seconds after the injection was the sonication delivered >>');
            log.sonicationTime = sonicationTime;
            save([expPath,fName],'log');
        case 't'
            save([expPath, fName],'log');
            fclose(pt);
            terminate = 1;
        otherwise
            disp('Unrecognized Command')
    end
end
        