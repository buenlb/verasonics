function [slope, bias, downshift, scale,err] = fitSigmoid(delays,choices)

delayVector = sort(unique(delays));
if length(delayVector)~=length(delays)
    y = zeros(size(delayVector));
    for ii = 1:length(delayVector)
        y(ii) = mean(choices(delays==delayVector(ii)),'omitnan');
    end
else
    y = choices;
end

if isrow(y)
    y = y';
end
if isrow(delayVector)
    delayVector = delayVector';
end

validIdx = ~isnan(delayVector) & ~isnan(y);
y = y(validIdx);
delayVector = delayVector(validIdx);
if isempty(delayVector)
    slope = nan;
    bias = nan;
    downshift = nan;
    scale = nan;
    err = inf;
    return
end
%% Set fminsearch options and starting point
fminsearchopt = optimset('LargeScale', 'off', 'Display', 'off', 'MaxFunEvals', 40000, 'MaxIter', 20000);
slope0 = 0.05;
bias0 = 5;
downshift0 = 0.2;
scale0 = 0.8;

%% Find parameters
x0 = [slope0, bias0, downshift0,scale0];
x = fminsearch(@(x)sigmoidCost(x,y,delayVector),x0,fminsearchopt);

if (sum(x==x0)==length(x))
    keyboard
end

slope = x(1);
bias = x(2);
downshift = x(3);
scale = x(4);
err = sigmoidCost(x,y,delayVector);
