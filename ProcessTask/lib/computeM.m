function m = computeM(tData,startEvent,endEvent,offsets)

if nargin < 2
    startEvent = 'usOn';
    endEvent = [];
    offsets = [0,0];
elseif nargin < 3
    endEvent = [];
    offsets = [0,0];
elseif nargin <4
    offsets = [0,0];
end

startEventNo = nan;
if isempty(endEvent)
    endEventNo = -1;
else
    endEventNo = nan;
end
for ii = 1:length(tData.timing(1).eventNames)
    if strcmp(startEvent,tData.timing(1).eventNames{ii})
        startEventNo = ii;
    end
    if ~isempty(endEvent)
        if strcmp(endEvent,tData.timing(1).eventNames{ii})
            endEventNo = ii;
        end
    end
end
if isnan(startEventNo) && ~strcmp(startEvent,'usOn')
    error([startEvent, ' not a recognized event!'])
elseif isnan(startEventNo)
    startEventNo = 0;    
end

if isnan(endEventNo)
    error([endEvent, ' not a recognized event!'])
end

ch = tData.ch;
m = zeros(size(ch));
for ii = 1:length(ch)
    if startEventNo > 0
        time1 = tData.timing(ii).eventTimes{startEventNo};
    else
        time1 = tData.timing(ii).eventTimes(3)-0.15; % Us onset
    end
    
    if endEventNo > 0
        time2 = tData.timing(ii).eventTimes(endEventNo);
    else
        time2 = inf;
    end
    
    if time1 > time2
        error('The starting event must preceed the end event');
    end
    
    time1 = time1+offsets(1)*1e-3;
    time2 = time2+offsets(2)*1e-3;
    
    x = tData.timing(ii).eyePos(:,1);
    t = tData.timing(ii).eyeTm;
    x = x(t>=time1 & t<=time2);
    m(ii) = sum(x<0)/length(x);
end