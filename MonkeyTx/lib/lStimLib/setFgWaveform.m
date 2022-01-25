% Sets the function generators carrier frequency
% 
% @INPUTS
%   fg: Pointer to opened function generator (VISA object)
%   ch: Channel (1|2)
%   wf: wf (SIN|SQU) I haven't yet implemented other waveforms
%   freq: Frequency (MHz)
%   amp: amplitude (mVpp)
%   offset: Offset (mV)
%   imp: Desired output impedence (defaults to 50 ohms)
%   dc: duty cycle (%) (defaults to 50%)
% 
% @OUTPUTS
%   None
% 
% Taylor Webb
% taylorwebb85@gmail.com

function setFgWaveform(fg,ch,wf,freq,amp,offset,imp,dc)
if ch ~= 1 && ch ~= 2
    error('Channel must be 1 or 2');
end

if ~exist('imp','var')
    imp = 50;
end
if ~exist('dc','var')
    dc = 50;
end

% Set impedance first - otherwise you can get strange voltage results.
if isnumeric(imp)
    command = ['OUTP',num2str(ch),':LOAD ',num2str(imp)];
    fprintf(fg,command);
elseif ~strcmp(imp,'INF')
    error('imp must be a double or the string ''INF''');
else
    command = ['OUTP',num2str(ch),':LOAD INF'];
    fprintf(fg,command);
end

% command = ['SOUR',num2str(ch),':APPL:',wf,' ', num2str(freq),' MHZ,' num2str(amp), ' mVPP,',num2str(offset),' mV'];
% fprintf(fg,command);

% Set waveform
command = ['SOUR',num2str(ch),':FUNC ',wf];
fprintf(fg,command);

% Set Frequency
command = ['SOUR',num2str(ch),':FREQ ',num2str(freq*1e6)];
fprintf(fg,command);

% Set Amplitude
command = ['SOUR',num2str(ch),':VOLT ',num2str(amp), ' mVPP'];
fprintf(fg,command);

% Set Offset
command = ['SOUR',num2str(ch),':VOLT:OFFS ',num2str(offset*1e-3)];
fprintf(fg,command);

% Duty cycle if it is a square wave
if strcmp(wf,'SQU')
    command = ['SOUR',num2str(ch),':FUNC:SQU:DCYC ', num2str(dc)];
    fprintf(fg,command);
end

err = checkFgError(fg);
if err
    ii = 1;
    nextErr = 1;
    while nextErr
        nextErr = checkFgError(fg);
        disp(nextErr);
        ii = ii+1;
    end
    error([num2str(ii), ' remote errors. First error: ', err])
end