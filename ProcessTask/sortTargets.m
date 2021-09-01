clear x y z
passed = passFinal;
passed(isnan(passed)) = false;
idx = find(freq==0.85 & passed);

for ii = 1:length(idx)
    curX = unique(targets{idx(ii)}(:,1));
    curY = unique(targets{idx(ii)}(:,2));
    curZ = unique(targets{idx(ii)}(:,3));
    x(:,ii) = curX;
    y(:,ii) = curY;
    z(:,ii) = curZ;
end

cLeftIdx = idx((x(1,:)==-10));
lLeftIdx = idx((x(1,:)==-12));
rLeftIdx = idx((x(1,:)==-8));

cRightIdx = idx((x(2,:)==12));
lRightIdx = idx((x(2,:)==10));
rRightIdx = idx((x(2,:)==14));
%% Left
ch = [];
lgn = [];
delay = [];
result = [];
for ii = 1:length(cLeftIdx)
    catIdx = 1:length(tData(cLeftIdx(ii)).ch);
    
    ch = cat(1,tData(cLeftIdx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(cLeftIdx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(cLeftIdx(ii)).delay(catIdx),delay);
    result = cat(1,tData(cLeftIdx(ii)).result(catIdx),result);
end
tDataCenter = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result);
plotTaskResultsZeroDelay(tDataCenter,[1,1,0]);
title('Center Target')
ax = gca;
ax.YLim = [10,50];
ax.XLim = [1,5];

ch = [];
lgn = [];
delay = [];
result = [];
for ii = 1:length(lLeftIdx)
    catIdx = 1:length(tData(lLeftIdx(ii)).ch);
    
    ch = cat(1,tData(lLeftIdx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(lLeftIdx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(lLeftIdx(ii)).delay(catIdx),delay);
    result = cat(1,tData(lLeftIdx(ii)).result(catIdx),result);
end
tDataCenter = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result);
plotTaskResultsZeroDelay(tDataCenter,[1,1,0]);
title('Left Target')
ax = gca;
ax.YLim = [10,50];
ax.XLim = [1,5];

ch = [];
lgn = [];
delay = [];
result = [];
for ii = 1:length(rLeftIdx)
    catIdx = 1:length(tData(rLeftIdx(ii)).ch);
    
    ch = cat(1,tData(rLeftIdx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(rLeftIdx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(rLeftIdx(ii)).delay(catIdx),delay);
    result = cat(1,tData(rLeftIdx(ii)).result(catIdx),result);
end
tDataCenter = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result);
plotTaskResultsZeroDelay(tDataCenter,[1,1,0]);
title('Right Target')
ax = gca;
ax.YLim = [10,50];
ax.XLim = [1,5];

%% Right
ch = [];
lgn = [];
delay = [];
result = [];
for ii = 1:length(cRightIdx)
    catIdx = 1:length(tData(cRightIdx(ii)).ch);
    
    ch = cat(1,tData(cRightIdx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(cRightIdx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(cRightIdx(ii)).delay(catIdx),delay);
    result = cat(1,tData(cRightIdx(ii)).result(catIdx),result);
end
tDataCenter = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result);
plotTaskResultsZeroDelay(tDataCenter,[0,1,1]);
title('Center Target')
ax = gca;
ax.YLim = [10,50];
ax.XLim = [1,5];

ch = [];
lgn = [];
delay = [];
result = [];
for ii = 1:length(lRightIdx)
    catIdx = 1:length(tData(lRightIdx(ii)).ch);
    
    ch = cat(1,tData(lRightIdx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(lRightIdx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(lRightIdx(ii)).delay(catIdx),delay);
    result = cat(1,tData(lRightIdx(ii)).result(catIdx),result);
end
tDataCenter = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result);
plotTaskResultsZeroDelay(tDataCenter,[0,1,1]);
title('Left Target')
ax = gca;
ax.YLim = [10,50];
ax.XLim = [1,5];

ch = [];
lgn = [];
delay = [];
result = [];
for ii = 1:length(rRightIdx)
    catIdx = 1:length(tData(rRightIdx(ii)).ch);
    
    ch = cat(1,tData(rRightIdx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(rRightIdx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(rRightIdx(ii)).delay(catIdx),delay);
    result = cat(1,tData(rRightIdx(ii)).result(catIdx),result);
end
tDataCenter = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result);
plotTaskResultsZeroDelay(tDataCenter,[0,1,1]);
title('Right Target')
ax = gca;
ax.YLim = [10,50];
ax.XLim = [1,5];