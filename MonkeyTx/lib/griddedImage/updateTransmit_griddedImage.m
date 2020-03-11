% Changes the element apodization in the TX structure based on the current
% value of Resource.Parameters.curGridIdx. 
% 
% @INPUTS
%   RData: Unused - just haven't figured out how not to pass that in
%   Resource.Parameters.CurGridIdx: obtained using evalin and not passed as
%       an argument. This tells the code which grid to turn on next.
%   Resource.Parameters.gridSize: Tells the code how many elements are in a
%       single edge of the grid. Grids are square.
% 
% @OUTPUTS
%   TX: The TX struct is updated via updateandrun VSX Command
%   Resource.Parameters.curGridIdx: This is incremented by 1
% 
% Taylor Webb
% University of Utah
% March 2020

function updateTransmit_griddedImage(RData)
Resource = evalin('base','Resource');


idx = Resource.Parameters.curGridIdx;
blocks = selectElementBlocks(Resource.Parameters.gridSize);

if idx > length(blocks)
    closeVSX();
    return;
end

% Reset apodization for each TX and Receive event
TX = evalin('base','TX');
Receive = evalin('base','Receive');
for ii = 1:length(TX)
    TX(ii).Apod = zeros(1,256);
    TX(ii).Apod(blocks{idx}) = 1;
    
    Receive(ii).Apod = zeros(1,256);
    Receive(ii).Apod(blocks{idx}) = 1;
end

Resource.Parameters.curGridIdx = idx+1;

%% Update TX and Resource in base
assignin('base','TX', TX);
assignin('base','Receive', Receive);
assignin('base','Resource', Resource);
% Set Control command to update TX
Control = evalin('base','Control');
Control.Command = 'update&Run';
Control.Parameters = {'TX','Receive'};
assignin('base','Control', Control);
disp(['Completed Recalculation of TX: ', num2str(toc)]);