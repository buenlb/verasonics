function correctDelay = findDelayErrors(trial_data)

if ~isfield(trial_data{end},'us')
    trial_data = trial_data(1:end-1);
end

for ii = 1:length(trial_data)
    if abs(abs(trial_data{ii}.timingOffset)-1e3*abs(trial_data{ii}.event_time(4)-trial_data{ii}.event_time(3))) > 7 % the frame period is about 8.3 ms so if it is greater than 9 ms it is off by a frame or more.
        correctDelay(ii) = false;
    else
        correctDelay(ii) = true;
    end    
end