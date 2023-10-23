% This script is designed for general processing of behavioral data in the
% first target task. It was written by Taylor Webb
% (taylorwebb85@gmail.com). Feel free to reach out with questions.
% 
% The code processes raw behavior data into a struct called tData. This 
% struct is then sorted by US parameters and a new struct called sessions 
% is created. Sessions contains an individual entry for each parameter set 
% in each monkey, thus making it straight forward plot the results of any
% given set of parameters. The session struct can be searched using 
% getSessionIndex.m
% 
% The required user input is simply the path(s) in which to look for
% behavioral data files, a code describing each path (

%% Provide the location of Behavioral Data
close all; clear; clc;
% NOTE TO USER: Loading and processing the raw data is time consuming.
% Therefore, the function will first check each directory for a file named
% curData.mat. This file contains the results of prior runs of the function
% and will allow you to avoid re-processing the data. curData.mat has a
% record of the files it has processed and in the event that there are
% unprocessed files in the directory it will process them and add them to
% curData.mat

% Paths in which raw data are found
behavioralPths = {'D:\Task\Boltz\durable\','D:\Task\Euler\durable\',...
    'D:\Task\Hobbes\Propofol','D:\Task\Calvin\Propofol',...
    'D:\Task\Hobbes\Saline','D:\Task\Hobbes\Saline'};

% Subject code. This is the code that will be applied to the data from each
% directory so it should be the same length as behavioralPths. This is to
% allow the user to differentiate between subjects and between sonications
% with drugs/saline/blanks.
subjectCode = {'b','e','HP','CP','HS','CS'};

% Injection. 1 if there was an injection, 0 otherwise. Sessions with an
% injection require some extra processing since the sonicated trial has to
% be determined.
injection = [0,0,1,1,1,1];

if length(subjectCode) ~= length(behavioralPths) || length(subjectCode) ~= length(injection)
    error('behavioralPths, injection, and subjectCode must be the same length!')
end
%% Load behavioral Data
for ii = 1:length(behavioralPths)
    disp(['Loading directory ', num2str(ii), ' of ', num2str(length(behavioralPths))]);
    % Load the raw data
    [cData, cFiles] = loadMonk(behavioralPths{ii});
    
    % Save an index into subjectCode/injection
    cSubject = ii*ones(size(cData));
    
    % Add data to a universal struct
    if ii == 1
        tData = cData;
        subject = cSubject;
        dataFiles = cFiles;
    else
        tData = cat(2,tData,cData);
        subject = cat(2,subject,cSubject);
        dataFiles = cat(2,dataFiles,cFiles);
    end
end

%% Process Behavioral Data
% Set time window and range
tWindow = 5*60;
dt = 0.5*60;
tBefore = 2*tWindow;
tAfter = 12*tWindow;
tm = -tBefore:dt:tAfter;
baseline = 0;

y = nan(length(tData),length(tm));
m = y;
allCh = y;
epp = y;
err = y;
p0 = nan(size(tData));
chVectors = nan(5,length(tm),length(tData));
dVectors = chVectors;
for ii = 1:length(tData)
    disp(['Processing Behavior: ', num2str(ii), ' of ', num2str(length(tData))])

    % Error check for early sessions in which we sonicated multiple times.
    % This throws out all trials after later sonications
    tData(ii) = removeExcessSonications(tData(ii));

    % If this is a session with an injection, set the ultrasound trial.
    if injection(subject(ii))
        tData(ii) = setUltrasoundTrial(tData(ii));
    end
    
    % No sonication was recorded - even after setting the sonication for
    % injections. This session will be rejected.
    if isnan(tData(ii).sonicatedTrials) || length(tData(ii).sonicatedTrials)>1
        continue
    end
    % Acquire baseline
    p0(ii) = behaviorOverTime2(tData(ii),baseline,tWindow);

    % Process behavior over time
    [epp(ii,:),y(ii,:),m(ii,:),allCh(ii,:),chVectors(:,:,ii),dVectors(:,:,ii),err(ii,:)]...
        = behaviorOverTime2(tData(ii),tm,tWindow,p0(ii));
end

%% Plot results
% The following functions sort the data for easy processing of results
% specific to a parameter set or a subject. This is simply to provide an
% example. Another useful function for plotting is selectByFocus (the
% sessions do not separate different locations in order to keep left/right
% sonications together but this can be an issue if one of the parameters
% that a particular session varies is focal location).
sessions = sortSessions(tData,subject,0);
sIdx = getSessionIdx(sessions,'duration',30000,'=','voltage',9,'=',...
    'PRF',4.8,'=','monk',1,'=');
