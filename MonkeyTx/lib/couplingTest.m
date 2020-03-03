% couplingTest plots diagnostic tests to enable a user to determine if the
% array is well coupled to the skull. If data files are supplied, the
% function plots the data from those files. Otherwise the function calls
% VSX to acquire the data, this assumes that the array is connected and
% ready to be excited.
% 
% NOTE: For now this is a script instead of a function because I had
% difficulty getting VSX to run within a function. Inputs are the user
% defined variables at the top and this is easily transitioned to a
% function if I get VSX running from within a MATLAB function
% 
% @INPUTS
%   origFile: Original file for comparison
%   saveFile: Full file name and path in which to store the results
%   dataFile: Optional, if provided the results are plotted from the data
%       in that file rather than by acquiring data through VSX
% 
% @OUTPUTS
%   none but several figures are displayed showing diagnostics for the
%       coupling
% 
% Taylor Webb
% University of Utah
% February 2020

clear all; close all; clc;

%% Inputs
origFile = '';
saveFile = 'C:\Users\Verasonics\Desktop\Taylor\Data\Coupling\diagnostics\testResults2.mat';
clear dataFile
dataFile = 'C:\Users\Verasonics\Desktop\Taylor\Data\Coupling\diagnostics\test2';

%%

if exist('dataFile','var')
    data = load(dataFile);
else
    % Run VSX
    filename = 'imaging_singleElement.mat';
    
    VSX
    
    data.Receive = Receive;
    data.RcvData = RcvData;
    data.Trans = Trans;
end

%% Find broken elements
brokenElements = brokenElementsDoppler1();

%% Plot arrival times for comparison
tmplt = load('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\tmpltSignal.mat');
dTmplt = tmplt.d(tmplt.id);
template = tmplt.sgnl(tmplt.id);

Receive = data.Receive;
t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);
d = t*1.492*0.5;

tArr = zeros(1,256);
for ii = 1:256
    if ismember(ii,brokenElements)
        tArr(ii) = nan;
        continue
    end
    curSignal = data.RcvData{1}(data.Receive(ii).startSample:data.Receive(ii).endSample,ii);
    
    % Matched Filter
    filtered = xcorr(curSignal,template);
    filtered = filtered(length(curSignal):end);
    filtered(d<15) = 0;
    filtered(d>d(end)-d(length(template))) = 0;
    [~,idx] = max(filtered);
    
    % Front Edge
    cs = abs(hilbert(curSignal));
    cs(d<20 | d>d(end)-d(length(template))) = 0;
    [~,frontEdge] = max(cs);
    while cs(frontEdge)-cs(frontEdge-1) > 0 || cs(frontEdge)>max(cs)/4
        frontEdge = frontEdge-1;
    end
        
    tArr(ii) = t(frontEdge);
%     if ii == 30
%         figure(99)
%         subplot(211)
%         plot(d,curSignal,'-',d(idx:(idx+length(template))-1),template,'--')
%     %     axis([25,50,-500,500])
%         subplot(212)
%         plot(d,filtered,'-',d(idx),filtered(idx),'*')
%         drawnow
%         pause(0.1)
%         keyboard
%     end
end

closestSkullInterface(tArr);

%% Save result
save(saveFile, 'data');