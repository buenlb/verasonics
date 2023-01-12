function data = read_Intan_RHS2000_fileperchannel(directory_name, notch_filter_frequencies, allchannelsstimulatedsimultaneously)
% reads Intan RHS2000 data split as one file per channel

%go into the directory
cdr = cd;
dir_name = sprintf('%s*', directory_name);
d = dir(dir_name);
dirname = d.name;
cd(dirname);
fprintf('Processing %s\n', dirname);

%header file
data = read_Intan_RHS2000_file_JK('info.rhs');

%time vector
fileinfo = dir('time.dat');
num_samples = fileinfo.bytes/4; % int32 = 4 bytes
fid = fopen('time.dat', 'r');
t = fread(fid, num_samples, 'int32');
fclose(fid);
data.timevector = t / data.frequency_parameters.amplifier_sample_rate; %sample rate from header file

%alloc
data.amplifier_data = zeros(numel(data.amplifier_channels), num_samples);
%signals
fs = data.frequency_parameters.amplifier_sample_rate;

for ch = 1 : numel(data.amplifier_channels)
    filename = sprintf('amp-%c-%03d.dat', data.amplifier_channels(ch).port_name(end), data.amplifier_channels(ch).chip_channel);
    fileinfo = dir(filename);
    if ~isempty(fileinfo)
        fprintf('   loading channel %d\n', ch);
        num_samples = fileinfo.bytes/2; % int16 = 2 bytes
        fid = fopen(filename, 'r');
        v = fread(fid, num_samples, 'int16');
        fclose(fid);
        signal = v * 0.195; % convert to microvolts
                
        for nf = 1 : numel(notch_filter_frequencies)
            fprintf(1, 'Applying notch filter at %d Hz...\n', notch_filter_frequencies(nf));            
            signal = notch_filter(signal, fs, notch_filter_frequencies(nf), 10); %last param is the filter bandwidth
        end
        
        data.amplifier_data(ch, :) = signal;
        data.stds(ch) = std(signal); %useful for identifying bad channels (with binary "spikes" on them)
    end
end


% if useflexintanmap
%     fprintf('   reordering channels so that they encode position on the Microflex array\n');
%     % reorder intan channel order so that channels are sorted according to the
%     % position on the Microflex array (channel 1 on Microflex is the farthest from the tip of the array)
%     %Microflex  Intan
%     flexintanmap = [
%         1	4
%         2	3
%         3	5
%         4	2
%         5	6
%         6	1
%         7	7
%         8	0
%         9	8
%         10	15
%         11	9
%         12	14
%         13	10
%         14	13
%         15	11
%         16	12
%         ];
%     flexintanmap(:, 2) = flexintanmap(:, 2) + 1;
%     data.amplifier_data =  data.amplifier_data(flexintanmap(:, 2), :);
% else
% %        fprintf('   NOT reordering channels so that they encode position on the Microflex array\n');
% end

%analog in
filename = 'board-ANALOG-IN-1.dat';
fileinfo = dir(filename); % ADC input data
if ~isempty(fileinfo)
    fprintf('   loading analog in\n');
    num_samples = fileinfo.bytes/2; % uint16 = 2 bytes
    fid = fopen(filename, 'r');
    v = fread(fid, num_samples, 'uint16');
    fclose(fid);
    data.analogin = (v - 32768) * 0.0003125; % convert to volts
end

%digital in
filename = 'board-DIGITAL-IN-01.dat';
fileinfo = dir(filename); % digital input data
if ~isempty(fileinfo)
    fprintf('   loading DIGITAL-IN-01\n');
    num_samples = fileinfo.bytes/2; % uint16 = 2 bytes
    fid = fopen(filename, 'r');
    din01 = fread(fid, num_samples, 'uint16');
    fclose(fid);
    data.board_dig_in_data = din01;
end
%
filename = 'board-DIGITAL-IN-02.dat';
fileinfo = dir(filename); % digital input data
if ~isempty(fileinfo)
    fprintf('   loading DIGITAL-IN-02\n');
    num_samples = fileinfo.bytes/2; % uint16 = 2 bytes
    fid = fopen(filename, 'r');
    din02 = fread(fid, num_samples, 'uint16');
    fclose(fid);
    data.board_dig_in_data(:, 2) = din02;
end


%stimulation output current
if allchannelsstimulatedsimultaneously
    stimchvect = 1; %all channels are electrically stimulated at the same time with the same waveform, so need just one channel for timing
else
    stimchvect = 1 : numel(data.amplifier_channels);
end
for ch = stimchvect
    filename = sprintf('stim-%s.dat', data.amplifier_channels(ch).native_channel_name);
    fileinfo = dir(filename);
    if ~isempty(fileinfo)
        fprintf('   loading stimulated data for channel %d (%s)\n', ch, filename);
        num_samples = fileinfo.bytes/2; % uint16 = 2 bytes
        fid = fopen(filename, 'r');
        dat = fread(fid, num_samples, 'uint16');
        fclose(fid);
        curmag = bitand(dat, 255) * data.stim_parameters.stim_step_size; % current magnitude
        signat = (128 - bitand(dat, 256))/128; % convert sign bit to 1 or -1
        data.stim_data(ch, :) = curmag .* signat; % signed current in Amps
    end
end

cd(cdr);
return;



function out = notch_filter(in, fSample, fNotch, Bandwidth)

% out = notch_filter(in, fSample, fNotch, Bandwidth)
%
% Implements a notch filter (e.g., for 50 or 60 Hz) on vector 'in'.
% fSample = sample rate of data (in Hz or Samples/sec)
% fNotch = filter notch frequency (in Hz)
% Bandwidth = notch 3-dB bandwidth (in Hz).  A bandwidth of 10 Hz is
%   recommended for 50 or 60 Hz notch filters; narrower bandwidths lead to
%   poor time-domain properties with an extended ringing response to
%   transient disturbances.
%
% Example:  If neural data was sampled at 30 kSamples/sec
% and you wish to implement a 60 Hz notch filter:
%
% out = notch_filter(in, 30000, 60, 10);

tstep = 1/fSample;
Fc = fNotch*tstep;

L = length(in);

% Calculate IIR filter parameters
d = exp(-2*pi*(Bandwidth/2)*tstep);
b = (1 + d*d)*cos(2*pi*Fc);
a0 = 1;
a1 = -b;
a2 = d*d;
a = (1 + d*d)/2;
b0 = 1;
b1 = -2*cos(2*pi*Fc);
b2 = 1;

out = zeros(size(in));
out(1) = in(1);
out(2) = in(2);
% (If filtering a continuous data stream, change out(1) and out(2) to the
%  previous final two values of out.)

% Run filter
for i=3:L
    out(i) = (a*b2*in(i-2) + a*b1*in(i-1) + a*b0*in(i) - a2*out(i-2) - a1*out(i-1))/a0;
end

return
