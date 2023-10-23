
% firstTarget script sets the Verasonics machine to listen for instructions
% from the task server.
% 
% Known Instructions:
%   SKULL: Take a B-mode image of the skull and save the data. Send
%       confirmation when the image is complete and launch VSX to prepare
%       for sonication of Left/Right LGN
%   INIT: Received by doppler256_neuromodulation VSX script, allows the
%       server to confirm that the Verasonics machine is ready for
%       sonication
%   E:L Sonicate left LGN with parameters for Euler
%   E:R Sonicate right LGN with parameters for Eule  r
%   TERMINATE: Task comp.lete, close communication.
% 
% Taylor Webb
% University of Utah
% December 2020

%% Clear the workspace and add necessary paths
clear all; close all; clc;
% cd 'C:\Users\Verasonics\Documents\Vantage-4.4.0-2012091800';
activate;

mainPth = 'C:\Users\Administrator\Documents\MonkeyCode\';

addpath([mainPth, 'MonkeyTx\lib\']);
addpath([mainPth, 'MonkeyTx\lib\taskLib']);
addpath([mainPth, 'MonkeyTx\lib\placementVerification']);
addpath([mainPth, 'lib\']);
addpath([mainPth, 'MonkeyTx\MATFILES\']);
addpath([mainPth, 'MonkeyTx\setupScripts\']);
addpath([mainPth, 'MonkeyTx\lib\mrLib\transducerLocalization\']);

%% User defined inputs
monk = input('Monkey (b/e): ', 's');
switch monk
    case 'b'
        goldStd = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20210929\UltrasoundData\boltzmann_20210929_2GS.mat';
        txSn = 'JAB800';
    case 'e'
        goldStd = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20201202\UltrasoundData\gs_Euler_0925.mat';
        txSn = 'JAB800';
    otherwise
        error([monk, ' not a recognized subject! Please choose b or e (case sensitive).'])
end
expPath = 'C:\Users\Verasonics\Documents\firstTargetData\';
disp(['Using Tx: ', txSn]);

%% Open Communications
pt = serial('COM1');
fopen(pt);
received = 0;

%% Listen
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
            disp('Getting initial parameters')
            fprintf(pt,'INIT');
            
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
            disp(['  Target Variation (<x,y,z>): <', num2str(dev(1)),',',num2str(dev(2)),',',num2str(dev(3)),'>'])
            disp(['  Saving in: ', fName])
            
            doppler256_neuromodulate2_spotlight(duration*1e-3,voltage,target,prf,dc,frequency,[expPath,fName,'_log'],txSn,dev,nTargets);
        case 'SKIPSKULL'
            fprintf(pt,'SKIPSKULL');
            fNameOrig = fName;
%             received = 1;
        case 'SKULL'
            disp('Starting Skull Image')
            fprintf(pt,'SKULL');
            % Image Skull
            if ~exist('fName','var')
                fprintf(pt,'ERR: INIT must be run before SKULL');
                fclose(pt);
                error('INIT must be run before SKULL')
            end
            fNameOrig = fName;
            rescan = 1;
            scanIdx = 0;
            while rescan
                % VSX clears variables so we need to store them
                if scanIdx == 0
                    curFname = [expPath,fName];
                    save tmpBeforeVSX.mat
                    [gsParams,gs,cr] = testArrayPlacement_firstTargetTask(goldStd,curFname,[],1);
                else
                    curFname = [expPath,fName,num2str(scanIdx+1)];
                    save tmpBeforeVSX.mat
                    [gsParams,gs,cr] = testArrayPlacement_firstTargetTask(goldStd,curFname,[],1);
                end
                load tmpBeforeVSX.mat
                delete('tmpBeforeVSX.mat')
                % Let server know that the process is complete.
                disp('Skull Image Complete');
                
                waitfor(verifyPreTask(goldStd,curFname));
                rs = load('guiOutput.mat');
                rescan = rs.rescan;
                
                scanIdx = scanIdx+1;
            end
            fprintf(pt,'INIT');
%             received = 1;
        case 'BEGINSONICATING'
            fprintf(pt,'BEGINSONICATING');
            received = 1;
        case 'ENDSONICATING'
            fprintf(pt,'ENDSONICATING');
            disp('Finished Sonicating')
            closeVSX();
        case 'TERMINATE'
            fprintf(pt,'TERMINATE');
            fclose(pt);
            disp('Finished')
            closeVSX();
            return
        otherwise
            fprintf(pt,'ERR');
            fclose(pt);
            error(['Received invalid message from server; ', msg])
    end
end
fclose(pt);

%% Launch VSX
save tmpBeforeVSX.mat
filename = 'doppler256_neuromodulate2_spotlight.mat';
VSX;
load tmpBeforeVSX.mat
%% Take a final coupling Image
testArrayPlacement_firstTargetTask(goldStd,[expPath,fNameOrig,'_final'],[],1);
