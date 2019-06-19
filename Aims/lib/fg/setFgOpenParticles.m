function setFgOpenParticles(fg,dutyCycle,amplitude,frequency,period,nCycles)

if amplitude > 750
    error('Amplitude is too high for amplifier! Please select an amplitude less than or equal to 750 mVpp')
end

if frequency < 0.2
    error('Frequency is less than 250 kHz')
end

%% Set frequency and amplitude for the main signal (Channel 1)
command = ['SOURCE1:APPLy:SINusoid ', num2str(frequency*1e6), ', ' num2str(amplitude*1e-3)];
fprintf(fg,command);

fprintf(fg,'OUTPUT1 ON');

%% Turn amplituded modulation on with CH 2 as the source
fprintf(fg,'SOURCE1:AM:STATe ON');
fprintf(fg,'SOURCE1:AM:DSSC OFF');
fprintf(fg,'SOURCE1:AM:SOURCE CH2');
fprintf(fg,'SOURCE1:AM:DEPTh 100');

%% Set up channel 2
% Set frequency and amplitude
command = ['SOURCE2:APPLy:SQUare ', num2str(1/(1e-3*period)), ', ' num2str(5)];
fprintf(fg,command);

command = ['SOURCE2:FUNction:SQUare:DCYCle ', num2str(dutyCycle)];
fprintf(fg,command);

%% Burst Properties
% Set up the mode
fprintf(fg,'SOURCE2:BURS:MODE TRIG');
fprintf(fg,'TRIGger2:SOURce BUS');
 
% Number of cycles
command = ['SOURCE2:BURS:NCYC ', num2str(nCycles)];
fprintf(fg,command);

fprintf(fg,'SOURCE2:BURS:STAT ON');
fprintf(fg,'OUTPUT2 OFF');
