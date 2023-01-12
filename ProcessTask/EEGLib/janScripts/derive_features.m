function [features, t, spikewaveforms, spikewaveformscell, rms, windowL, overlap, stimtimes, estimtimes] = derive_features(data, frequency_bands, spike_thrs, windowdur, rereference)
% Performs time-frequency analysis and spike extraction from Intan-recorded
% data
%
% 2019-03-20 Jan Kubanek
%
% INPUT:
% data: data loaded from the Intan acquisition
%
% frequency_bands: cell specifying the ranges of frequency bands to be
% used, in Hz
%
% spike_thr: %threshold in uV; if positive, looks for events above the
% treshold; else, below the threshold; if 0 or nan, no spike detection
%
% OUTPUT:
% features: the extracted time-frequency amplitudes, supplied with spike
% counts if spike_thr is supplied
%
% t: vector of times corresponding to the extracted features
% spikewaveforms: waveforms of signals exceeding spike_thr, plus minus a
% defined time interval

%if electrical stimulation is present
fs = data.frequency_parameters.amplifier_sample_rate;

windowL = windowdur * fs; %s; for slower rhythms (alpha, beta), use 0.5 s; for faster (gamma, HG), use 0.2 s or 0.1 s
overlap = windowL/2; %half overlap
% overlap = windowL/4; %quarter overlap; doesn't seem to work properly
% overlap = windowL; %no overlap

signals = data.amplifier_data;
CH = size(signals, 1);

B = numel(frequency_bands);
features = zeros((B + numel(spike_thrs)) * CH, floor(length(signals) / overlap) - 1);
count = 1;

spikewaveformscell = cell(CH, numel(spike_thrs));
rms = nan(CH, 1);


switch rereference
    case 'CAR' %common reference
        signals = signals - ones(size(signals, 1), 1) * mean(signals, 1); %subtract CAR
end
    
for ch = 1 : CH
    signal = signals(ch, :);
    %superimpose 60 Hz for testing
    %    s60Hz = 200 * sin(2 * pi * 60 * [1 : length(signal)] / fs);
    %    signal = signal + s60Hz;
    
    %spectral analysis (amplitude of LFPs in defined frequency bands)
    fprintf('computing time-frequency spectra\n');
    [s, f, t] = spectrogram(signal, windowL, overlap, [], fs, 'yaxis'); %uses the Hamming window by default, which is fine
    %    spectrum = abs(s); %amplitude is more normally distributed than power, so use amplitude instead of PSD
    spectrum = s .* conj(s) / (fs * windowL); %power spectral density
    
    for b = 1 : B
        freq_range = frequency_bands{b};
        ics = f >= freq_range(1) & f <= freq_range(2);
        features(count, :) = mean(spectrum(ics, :), 1); %average amplitude over the individual frequencies
        count = count + 1;
    end
    
    %spike detection    
    if ~isempty(spike_thrs)
        %high-pass > 300 Hz
        fprintf('detecting spikes\n');
        %highpass
%         d = fdesign.highpass('Fst,Fp,Ast,Ap', 240, 300, 40, 0.5, fs);
%         Hd = design(d, 'equiripple'); %FIR filter
%         signal = filtfilt(Hd.Numerator, 1, signal); %zero lag filtering (forth and back)

        %bandpass
        d = fdesign.bandpass('N,Fst1,Fp1,Fp2,Fst2,C',300, 250, 300, 3000, 3050, fs);
        d.Stopband1Constrained = true;
        d.Astop1 = 30;
        d.Stopband2Constrained = true;
        d.Astop2 = 30;
        Hd = design(d, 'equiripple'); %FIR filter
        signal = filtfilt(Hd.Numerator, 1, signal); %zero lag filtering (forth and back)
        
        %compute rms (= std)
        rms(ch) = std(signal);
        
        for s = 1 : numel(spike_thrs)
            spike_thr = spike_thrs(s);
            if imag(spike_thr) > 0
                overthreshold = double(abs(signal) > imag(spike_thr) * rms(ch)); %exceeding given number of standard deviations
            else
                if spike_thr > 0
                    overthreshold = double(signal > spike_thr);
                else
                    overthreshold = double(signal < spike_thr);
                end
            end
            doverthreshold = [0, diff(overthreshold)]; %the first time of reaching a threshold
            onsets = find(doverthreshold > 0);
            offsets = find(doverthreshold < 0);
            timebeforemax = 3.0e-3 * fs; %ms
            timeaftermax = 3.0e-3 * fs; %ms
            spikewaveforms = nan(numel(onsets), timebeforemax + timeaftermax + 1);
            spikemaxtimes = nan(numel(onsets), 1);
            for o = 1 : numel(onsets)
                [~, index] = max(signal(onsets(o) : offsets(o)));
                if ~isempty(index)
                    spikemaxtimes(o) = onsets(o) + index;
                    if spikemaxtimes(o) && (spikemaxtimes(o) + timeaftermax <= numel(signal) && spikemaxtimes(o) - timebeforemax > 1)
                        spikewaveforms(o, :) = signal(spikemaxtimes(o) - timebeforemax : spikemaxtimes(o) + timeaftermax);
                    end
                end
            end
            spikewaveformscell{ch, s} = spikewaveforms;
            spikes = zeros(size(signal));
            spikemaxtimes(isnan(spikemaxtimes)) = []; %remove the epochs that do not have maxima and so are not spikes
            spikes(spikemaxtimes) = 1;
            %spike counts within a window (using the same overlappping window as
            %above; but can use much smaller window for higher temporal precision
            spikesM = buffer(spikes, windowL, overlap);
            deltasize = size(spikesM, 2) - size(features, 2);
            features(count, :) = sum(spikesM(:, 2 : end - deltasize + 1), 1); %the number of spikes in each window
            count = count + 1;
        end
    end
end
