% readWaveform.m
% Patrick Ye
% http://kbplab.stanford.edu/
%
% [t, v] = readWaveform(fileName);
% Reads waveform.aim files and outputs time and voltage in matrix form 

function [time, volt, position,delay] = readWaveform(fileName)

% find start of waveform data
text = fileread(fileName);
dataHeader = '\[Waveform Data\]';
m = regexp(text, dataHeader);
n = regexp(text, '\n');

planeLoc = regexp(text,'Axis . Position');
position = zeros(1,5);
for ii = 1:5
    position(ii) = findNextNumber(text,planeLoc(ii)+7);
end

% Find Scope Delay
scopeData = regexp(text,'\[Oscilloscope\]');
delayLoc = regexp(text, 'Delay');
delayLoc = delayLoc(delayLoc>scopeData);
delayLoc = delayLoc(1);
delay = findNextNumber(text,delayLoc);

divLoc = regexp(text, 'SecPerDiv');
divLoc = divLoc(divLoc>scopeData);
divLoc = divLoc(1);
secPerDiv = findNextNumber(text,divLoc);
delay = delay-secPerDiv;

numHeaderLines = sum(n<m);

% read file
fid = fopen(fileName);
c = textscan(fid, '%f', 'Headerlines', numHeaderLines+1); % may not be 252 lines for every file...
fclose(fid);
data = c{1};

% odd indices are time, even indices are voltages
idx = 1:length(data);
time = data(mod(idx, 2)==1); % microseconds
volt = data(mod(idx, 2)==0); % voltage

end