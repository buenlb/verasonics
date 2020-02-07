% This function acquires and saves a wavefrom. The waveform is saved to the
% directory defined by Resource.Parameters.saveDir with the base file name
% Resource.Parameters.saveName. An index is added which corresponds to the
% linear index into the X, Y, and Z matrices that define the 3d grid. It
% expects to find these matrices at Resource.Parameters.gridInfoFile. This
% file can be generated by the prescribe_cmp GUI.
% 
% Taylor Webb
% Fall 2019

function getWaveform_exVivoScan(RData) %#ok<*INUSD>
if ~exist('isSoniqConnected.m','file')
    addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\Aims\lib\soniq');
    addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\Aims\lib')
end

lib = 'soniq';
if ~isSoniqConnected(lib)
    openSoniq(lib);
end

Resource = evalin('base','Resource'); 

%% Determine where we are in the code - how should this be saved?
% header.transmits complete is a vector whose length is based on the number
% of transmits. Each entry in the vector tells the system how many averages
% have been recorded for each waveform.
hd = load(Resource.Parameters.logFileName);
header = hd.header;
for ii = 1:length(header.transmitsComplete)
    if header.transmitsComplete(ii) == Resource.Parameters.numAvg
        continue
    else
        header.transmitsComplete(ii) = header.transmitsComplete(ii)+1;
        avgIdx = header.transmitsComplete(ii);
        transmitIdx = ii;    
        break;
    end
end
save(Resource.Parameters.logFileName,'header');

% Add a slash if necessary to the end of the path
if Resource.Parameters.saveDir(end) ~= '\' && Resource.Parameters.saveDir(end) ~= '/'
    Resource.Parameters.saveDir(end+1) = '\';
end

% Figure out what angle we are currently on
lib = 'soniq';
pos = getPositionerSettings(lib);
angles = Resource.Parameters.angles;
angleIdx = find(abs(pos.THETA.loc - angles) < 1e-6);

% Create a save name based on the transmit, average, and angle number of
% the current file.
saveName = [Resource.Parameters.saveDir, Resource.Parameters.saveName,...
    '_hData_transmitNo', num2str(transmitIdx), '_averageNo', num2str(avgIdx),...
    '_angleNo', num2str(angleIdx), '.snq'];

% Load the relevant O-scope settings
fname = ['C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\SingleElement\lib\OscopeParams_transmit',...
    num2str(transmitIdx), '.txt'];
calllib(lib,'LoadScopeSettings',fname);

% Acquire the waveform
disp(['    Acquiring wave from transmit ', num2str(transmitIdx), ' and average ', num2str(avgIdx)]);
getSoniqWaveform(lib,saveName);
return