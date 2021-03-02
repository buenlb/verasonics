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
%   TERMINATE: Task complete, close communication.
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

%% User defined inputs
expPath = 'C:\Users\Verasonics\Documents\firstTargetData\';
goldStd = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20201202\UltrasoundData\gs_Euler_0925.mat';

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
        case 'SKULL'
            disp('Starting Skull Image')
            fprintf(pt,'SKULL');
            % Image Skull
            fName = fscanf(pt);
            while isempty(fName)
                fName = fscanf(pt);
            end
            fName = fName(1:end-1);
            fNameOrig = fName;
            fprintf(pt,fName);
            rescan = 1;
            scanIdx = 0;
            while rescan
                % VSX clears variables so we need to store them
                save tmpBeforeVSX.mat
                if scanIdx == 0
                    [gsParams,gs,cr] = testArrayPlacement_firstTargetTask(goldStd,[expPath,fName],[],1);
                else
                    [gsParams,gs,cr] = testArrayPlacement_firstTargetTask(goldStd,[expPath,fName,num2str(scanIdx+1)],[],1);
                end
                load tmpBeforeVSX.mat
                delete('tmpBeforeVSX.mat')
                % Let server know that the process is complete.
                disp('Skull Image Complete');
                imgs = struct('gs',gs,'cr',cr,'gsParams',gsParams,...
                    'goldStd',goldStd,'expPath',expPath,'fName',fName);

                waitfor(verifyPreTask(imgs));
                rs = load('guiOutput.mat');
                rescan = rs.rescan;
                
                scanIdx = scanIdx+1;
            end
            
            received = 1;
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
%% Create VSX struct. 
% The file setupVisualTaskSonication is expected to have all the necessary
% parameters such as the proper focal target and element intensities. These
% will be used by doppler256_neuromodulate to sonicate the LGN at the
% timing established by the server.
setupVisualTaskSonication([expPath,fNameOrig]);

%% Launch VSX
save tmpBeforeVSX.mat
filename = 'doppler256_neuromodulate2.mat';
VSX;
load tmpBeforeVSX.mat
%% Take a final coupling Image
testArrayPlacement_firstTargetTask(goldStd,[expPath,fNameOrig,'_final'],[],1);
