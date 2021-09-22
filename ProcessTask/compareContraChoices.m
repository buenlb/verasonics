passed = passInitial;
idxNan = find(isnan(passed));
passed(idxNan) = passed(idxNan-1);

tdIdx = 1;
clear tData10
threshold = 00;
desiredTask = 0;
%% tData10_all
idx = selectSessions(tData,threshold,dc,freq,voltage,10,[],[],passed,desiredTask);
ch = [];
lgn = [];
delay = [];
result = [];
target = [];
task = [];
correctDelay = [];
for ii = 1:length(idx)
%     catIdx = ceil(length(tData(idx(ii)).ch)/2):length(tData(idx(ii)).ch);
%     if length(tData(idx(ii)).ch) < 400
%         continue
%     end
%     catIdx = 1:length(tData(idx(ii)).ch);
    catIdx = logical(~tData(idx(ii)).task);
%     catIdx = find(tData(idx(ii)).loc(1,1,:)<-7);
    
    ch = cat(1,tData(idx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(idx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(idx(ii)).delay(catIdx),delay);
    result = cat(1,tData(idx(ii)).result(catIdx),result);
    target = cat(3,tData(idx(ii)).loc(:,:,catIdx),target);
    task = cat(1,tData(idx(ii)).task(catIdx),task);
    correctDelay = cat(1,tData(idx(ii)).correctDelay(catIdx),correctDelay);
end
tData10(tdIdx) = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result,'loc',target,'task',task,'correctDelay',correctDelay);
tdIdx = tdIdx+1;

%% tData10_480
idx = selectSessions(tData,threshold,dc,freq,voltage,10,0.48,[],passed,desiredTask);
% idx = idx(1:end-2);
ch = [];
lgn = [];
delay = [];
result = [];
target = [];
task = [];
correctDelay = [];
for ii = 1:length(idx)
%     catIdx = ceil(length(tData(idx(ii)).ch)/2):length(tData(idx(ii)).ch);
%     if length(tData(idx(ii)).ch) < 400
%         continue
%     end
%     catIdx = 1:length(tData(idx(ii)).ch);
    catIdx = logical(~tData(idx(ii)).task);
%     catIdx = find(tData(idx(ii)).loc(1,1,:)<-7);
    
    ch = cat(1,tData(idx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(idx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(idx(ii)).delay(catIdx),delay);
    result = cat(1,tData(idx(ii)).result(catIdx),result);
    target = cat(3,tData(idx(ii)).loc(:,:,catIdx),target);
    task = cat(1,tData(idx(ii)).task(catIdx),task);
    correctDelay = cat(1,tData(idx(ii)).correctDelay(catIdx),correctDelay);
end
tData10(tdIdx) = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result,'loc',target,'task',task,'correctDelay',correctDelay);
tdIdx = tdIdx+1;

%% tData10_650
idx = selectSessions(tData,threshold,dc,freq,voltage,10,0.65,[],passed,desiredTask);
ch = [];
lgn = [];
delay = [];
result = [];
target = [];
task = [];
correctDelay = [];
for ii = 1:length(idx)
%     if length(unique(tData(idx(ii)).loc(1,1,:))) < 3
%         continue;
%     end
%     catIdx = ceil(length(tData(idx(ii)).ch)/2):length(tData(idx(ii)).ch);
%     if length(tData(idx(ii)).ch) < 400
%         continue
%     end
%     catIdx = 1:length(tData(idx(ii)).ch);
    catIdx = logical(~tData(idx(ii)).task);
%     catIdx = find(tData(idx(ii)).loc(1,1,:)<-7);
    
    ch = cat(1,tData(idx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(idx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(idx(ii)).delay(catIdx),delay);
    result = cat(1,tData(idx(ii)).result(catIdx),result);
    target = cat(3,tData(idx(ii)).loc(:,:,catIdx),target);
    task = cat(1,tData(idx(ii)).task(catIdx),task);
    correctDelay = cat(1,tData(idx(ii)).correctDelay(catIdx),correctDelay);
end
tData10(tdIdx) = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result,'loc',target,'task',task,'correctDelay',correctDelay);
tdIdx = tdIdx+1;

%% tData10_850
idx = selectSessions(tData,threshold,dc,freq,voltage,10,0.85,[],passed,desiredTask);
ch = [];
lgn = [];
delay = [];
result = [];
target = [];
task = [];
correctDelay = [];
for ii = 1:length(idx)
%     catIdx = ceil(length(tData(idx(ii)).ch)/2):length(tData(idx(ii)).ch);
%     if length(tData(idx(ii)).ch) < 400
%         continue
%     end
%     catIdx = 1:length(tData(idx(ii)).ch);
    catIdx = logical(~tData(idx(ii)).task);
%     catIdx = find(tData(idx(ii)).loc(1,1,:)<-7);
    
    ch = cat(1,tData(idx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(idx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(idx(ii)).delay(catIdx),delay);
    result = cat(1,tData(idx(ii)).result(catIdx),result);
    target = cat(3,tData(idx(ii)).loc(:,:,catIdx),target);
    task = cat(1,tData(idx(ii)).task(catIdx),task);
    correctDelay = cat(1,tData(idx(ii)).correctDelay(catIdx),correctDelay);
end
tData10(tdIdx) = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result,'loc',target,'task',task,'correctDelay',correctDelay);
tdIdx = tdIdx+1;
%% Blank
idx = find(dc==10 & freq == 0.48 & passed);
ch = [];
lgn = [];
delay = [];
result = [];
target = [];
task = [];
correctDelay = [];

tData10(tdIdx) = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result,'loc',target,'task',task,'correctDelay',correctDelay);
tdIdx = tdIdx+1;
%% tData50_all
idx = selectSessions(tData,threshold,dc,freq,voltage,50,[],[],passed,desiredTask);
ch = [];
lgn = [];
delay = [];
result = [];
target = [];
task = [];
correctDelay = [];
for ii = 1:length(idx)
%     catIdx = ceil(length(tData(idx(ii)).ch)/2):length(tData(idx(ii)).ch);
%     if length(tData(idx(ii)).ch) < 400
%         continue
%     end
%     catIdx = 1:length(tData(idx(ii)).ch);
    catIdx = logical(~tData(idx(ii)).task);
%     catIdx = find(tData(idx(ii)).loc(1,1,:)<-7);
    
    ch = cat(1,tData(idx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(idx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(idx(ii)).delay(catIdx),delay);
    result = cat(1,tData(idx(ii)).result(catIdx),result);
    target = cat(3,tData(idx(ii)).loc(:,:,catIdx),target);
    task = cat(1,tData(idx(ii)).task(catIdx),task);
    correctDelay = cat(1,tData(idx(ii)).correctDelay(catIdx),correctDelay);
end
tData10(tdIdx) = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result,'loc',target,'task',task,'correctDelay',correctDelay);
tdIdx = tdIdx+1;

%% idx50_48
idx = selectSessions(tData,threshold,dc,freq,voltage,50,0.48,[],passed,desiredTask);
ch = [];
lgn = [];
delay = [];
result = [];
target = [];
task = [];
correctDelay = [];
for ii = 1:length(idx)
%     catIdx = ceil(length(tData(idx(ii)).ch)/2):length(tData(idx(ii)).ch);
%     if length(tData(idx(ii)).ch) < 400
%         continue
%     end
%     catIdx = 1:length(tData(idx(ii)).ch);
    catIdx = logical(~tData(idx(ii)).task);
%     catIdx = find(tData(idx(ii)).loc(1,1,:)<-7);
    
    ch = cat(1,tData(idx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(idx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(idx(ii)).delay(catIdx),delay);
    result = cat(1,tData(idx(ii)).result(catIdx),result);
    target = cat(3,tData(idx(ii)).loc(:,:,catIdx),target);
    task = cat(1,tData(idx(ii)).task(catIdx),task);
    correctDelay = cat(1,tData(idx(ii)).correctDelay(catIdx),correctDelay);
end
tData10(tdIdx) = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result,'loc',target,'task',task,'correctDelay',correctDelay);
tdIdx = tdIdx+1;

%% tData50_650
idx = selectSessions(tData,threshold,dc,freq,voltage,50,0.65,[],passed,desiredTask);
ch = [];
lgn = [];
delay = [];
result = [];
target = [];
task = [];
correctDelay = [];
for ii = 1:length(idx)
%     catIdx = ceil(length(tData(idx(ii)).ch)/2):length(tData(idx(ii)).ch);
%     if length(tData(idx(ii)).ch) < 400
%         continue
%     end
%     catIdx = 1:length(tData(idx(ii)).ch);
    catIdx = logical(~tData(idx(ii)).task);
%     catIdx = find(tData(idx(ii)).loc(1,1,:)<-7);
    
    ch = cat(1,tData(idx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(idx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(idx(ii)).delay(catIdx),delay);
    result = cat(1,tData(idx(ii)).result(catIdx),result);
    target = cat(3,tData(idx(ii)).loc(:,:,catIdx),target);
    task = cat(1,tData(idx(ii)).task(catIdx),task);
    correctDelay = cat(1,tData(idx(ii)).correctDelay(catIdx),correctDelay);
end
tData10(tdIdx) = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result,'loc',target,'task',task,'correctDelay',correctDelay);
tdIdx = tdIdx+1;
%% Blank
idx = find(dc==10 & freq == 0.48 & passed);
ch = [];
lgn = [];
delay = [];
result = [];
target = [];
task = [];
correctDelay = [];

tData10(tdIdx) = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result,'loc',target,'task',task,'correctDelay',correctDelay);
tdIdx = tdIdx+1;
%% tData100_650
idx = selectSessions(tData,threshold,dc,freq,voltage,100,0.65,[],passed,desiredTask);
ch = [];
lgn = [];
delay = [];
result = [];
target = [];
task = [];
correctDelay = [];
for ii = 1:length(idx)
%     catIdx = ceil(length(tData(idx(ii)).ch)/2):length(tData(idx(ii)).ch);
%     if length(tData(idx(ii)).ch) < 400
%         continue
%     end
%     catIdx = 1:length(tData(idx(ii)).ch);
    catIdx = logical(~tData(idx(ii)).task);
%     catIdx = find(tData(idx(ii)).loc(1,1,:)<-7);
    
    ch = cat(1,tData(idx(ii)).ch(catIdx),ch);
    lgn = cat(1,tData(idx(ii)).lgn(catIdx),lgn);
    delay = cat(1,tData(idx(ii)).delay(catIdx),delay);
    result = cat(1,tData(idx(ii)).result(catIdx),result);
    target = cat(3,tData(idx(ii)).loc(:,:,catIdx),target);
    task = cat(1,tData(idx(ii)).task(catIdx),task);
    correctDelay = cat(1,tData(idx(ii)).correctDelay(catIdx),correctDelay);
end
tData10(tdIdx) = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),'lgn',lgn,'result',result,'loc',target,'task',task,'correctDelay',correctDelay);
tdIdx = tdIdx+1;
%%
contraChoices = plotContraChoices(tData10,'xlabels',{'10% All','10% 480','10% 650','10% 850','',...
    '50% All','50% 480','50% 650','',...
    '100% 650'},'yaxis',[40,60]);