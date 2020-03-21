% Tests the placement of the array on the skull by acquiring two image data
% sets, one using single elements and one using a 3x3 grid of elements.
% 
% @INPUTS
%   None
% 
% @OUTPUTS
%   singleElRaw: Struct containing results of single element imaging
%   griddedElRaw: Struct containing results of gridded element imaging
% 
% Taylor Webb
% Targeted Treatments Laboratory
% University of Utah
% March 2020

function [singleElRaw,griddedElRaw] = imageSkull()
%% Run single element transmit/receive
disp('Single Element:');
disp('  Acquiring Data...')
tic;
filename = 'imaging_singleElement.mat';
assignin('base','filename',filename);
evalin('base','VSX');

Resource = evalin('base','Resource');
Receive = evalin('base','Receive');
TX = evalin('base','TX');
RcvData = evalin('base','RcvData');

singleElRaw = struct('RcvData',RcvData,'Receive',Receive,'TX',TX,'Resource',Resource);

%% Run gridded transmit/receive
disp(['Gridded Element (elapsed time = ', num2str(toc), '):']);
disp('  Acquiring Data...');
filename = 'imaging_elementGrids_oneDepth.mat';
assignin('base','filename',filename);
evalin('base','VSX');

Resource = evalin('base','Resource');
Receive = evalin('base','Receive');
TX = evalin('base','TX');
RcvData = evalin('base','RcvData');

griddedElRaw = struct('RcvData',RcvData,'Receive',Receive,'TX',TX,'Resource',Resource);

disp(['Gridded Element imaging complete (elapsed time = ', num2str(toc), '):']);
