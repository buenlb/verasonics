function [] = capture_freq(lib, saveLocation,freq)
    N = 10;
    wv = {};
    name = [saveLocation,'freq_',num2str(freq),'KHz'];
    for i = 1:10
        [wv{i}, t] = getSoniqWaveform(lib,[name,num2str(i),'.snq']);
        pause(0.01)
    end
    save([name,'.mat'],'wv','t');
end

