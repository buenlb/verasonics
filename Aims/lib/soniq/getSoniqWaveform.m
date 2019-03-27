% getSoniqWaveform acquires a waveform using the Soniq interface and
% returns the waveform and the time of each sample point relative to the
% incoming trigger. It does this by digitizing, saving, and reloading the
% waveform. By default the waveform is saved in wv.mat in the working
% directory but a unique filename can also be passed.
% 
% @INPUTS
%   lib: MATLAB alias for Soniq DLL
%   filename: optional, filename in which to store the recorded waveform.
%      If a location outside of the working directory is desired filename
%      must be a full path
% 
% @OUTPUTS
%   wv: recorded signal in volts
%   t: time of each sample relative to the trigger
% 
% Taylor Webb
% University of Utah

function [wv,t] = getSoniqWaveform(lib,filename)

if nargin == 0
    filename = 'wv.snq';
end

calllib(lib,'SetWaveformAutoscale',1);
calllib(lib,'DigitizeWaveform');

calllib(lib,'SaveFileAs',filename);

[t,wv] = readWaveform(filename);