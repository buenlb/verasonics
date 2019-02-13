function plotSingleElementAveraging(RData)
persistent figHandle;



if isempty(figHandle)
    figHandle = figure;
end
figure(figHandle);
plot(RData(:,1)/32);
drawnow
return