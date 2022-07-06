% combineSessions(idx,tData) combines the structs referenced by idx in
% tData. 
function t = combineSessions(idx,tData)
ch = [];
lgn = [];
delay = [];
result = [];
target = [];
task = [];
correctDelay = [];
timing = [];
leftVoltage = [];
rightVoltage = [];
brightnessOffset = [];
delayVector = [];
dc = [];
prf = [];
targIdx = [];
leftLocation = [];
rightLocation = [];
brightnessOffsetVector = [];
actualDelay = [];
preUs = zeros(size(idx));

for ii = 1:length(idx)
    ch = cat(1,tData(idx(ii)).ch,ch);
    lgn = cat(1,tData(idx(ii)).lgn,lgn);
    delay = cat(1,tData(idx(ii)).delay,delay);
    result = cat(1,tData(idx(ii)).result,result);
    target = cat(3,tData(idx(ii)).loc,target);
    task = cat(1,tData(idx(ii)).task,task);
    correctDelay = cat(1,tData(idx(ii)).correctDelay,correctDelay);
    timing = cat(2,tData(idx(ii)).timing,timing);
    leftVoltage = cat(1,tData(idx(ii)).leftVoltage,leftVoltage);
    rightVoltage = cat(1,tData(idx(ii)).rightVoltage,rightVoltage);
    brightnessOffset = cat(1,tData(idx(ii)).brightnessOffset,brightnessOffset);
    delayVector = cat(2,tData(idx(ii)).delayVector,delayVector);
    dc = cat(1,tData(idx(ii)).dc,dc);
%     targIdx = cat(1,tData(idx(ii)).targIdx,targIdx);
    prf = cat(1,tData(idx(ii)).prf,prf);
    leftLocation = cat(1,tData(idx(ii)).leftLocation,leftLocation);
    rightLocation = cat(1,tData(idx(ii)).rightLocation,rightLocation);
    brightnessOffsetVector = cat(2,tData(idx(ii)).brightnessOffsetVector,brightnessOffsetVector);
    actualDelay = cat(1,tData(idx(ii)).actualDelay,actualDelay);
    preUs(ii) = tData(idx(ii)).preUsTrials;
end

if sum(preUs(2:end))>0
    warning(['Later structures have pre-US trials (preUs:', num2str(preUs),').'])
end

t = struct('ch',ch,'delay',delay,'delayVector',sort(unique(delay)),...
    'lgn',lgn,'result',result,'loc',target,'task',task,...
    'correctDelay',correctDelay,'timing',timing,'leftVoltage',leftVoltage,...
    'rightVoltage',rightVoltage,'brightnessOffset',brightnessOffset,...
    'dc',dc,'prf',prf,'leftLocation',leftLocation,...
    'rightLocation',rightLocation,'actualDelay',actualDelay,'preUsTrials',preUs(1),...
    'targIdx',targIdx);
t.delayVector = unique(delayVector);
t.brightnessOffsetVector = unique(brightnessOffsetVector);
