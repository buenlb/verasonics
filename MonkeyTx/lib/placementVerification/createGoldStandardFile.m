function createGoldStandardFile(fName,svName)
data = load(fName);
sImg = data.singleElRaw;
gImg = data.griddedElRaw;

if isfield(data,'txSn')
	txSn = data.txSn;
else
	warning('No Serial Number found, assuming JAB800');
	txSn = 'JAB800';
end

%% Use single element image to determine power returned to each element
RcvData = sImg.RcvData;
Receive = sImg.Receive;
Resource = sImg.Resource;
Trans = transducerGeometry(0,txSn);

t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);
d = t*1.492/2+Receive(1).startDepth*Resource.Parameters.speedOfSound/(Trans.frequency*1e6)*1e3;

figure
hold on
for ii = 1:256
    plot(d,RcvData(Receive(ii).startSample:Receive(ii).endSample,ii));
end
[x,~] = ginput(2);
powerRange = x;
close all;

power = zeros(1,256);
mxPower = power;
totPower = 0;
totS = zeros(size(RcvData(Receive(ii).startSample:Receive(ii).endSample,ii)));
for ii = 1:256
    s = RcvData(Receive(ii).startSample:Receive(ii).endSample,ii);
    s = abs(hilbert(s));
    s(d<powerRange(1)) = 0;
    s(d>powerRange(2)) = 0;
%     s = s.^2;
    power(ii) = sum(s);
    mxPower(ii) = max(s);
    totPower = totPower+power(ii);
    totS = totS+s;
end

%% Use gridded element image to determine distance between 5 grids and the skull
RcvData = gImg.RcvData;
Receive = gImg.Receive;
Resource = gImg.Resource;

t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);
d = t*1.492/2+Receive(1).startDepth*Resource.Parameters.speedOfSound/(Trans.frequency*1e6)*1e3;

if strcmp(txSn,'JAB800')
    elementsOfInterest = [66,71,124,132,186,191];
elseif strcmp(txSn,'JEC482')
    elementsOfInterest = [81,82,129,130,177,178];
else
    error(['Unrecognized Tx:', txSn])
end
gridSize = 3;
blocks = selectElementBlocks(gridSize,txSn);
distIdx = 1;
skDist = zeros(size(elementsOfInterest));
threshold = 5e3;
for ii = 1:length(blocks)
    centerElement = blocks{ii}(ceil(gridSize^2/2))
    if ismember(centerElement,elementsOfInterest)
        s = zeros(size(Receive(ii).startSample:Receive(ii).endSample,blocks{ii}(1)));
        for jj = 1:gridSize^2
            curS = RcvData(Receive(ii).startSample:Receive(ii).endSample,blocks{ii}(jj));
            s = curS+s;
        end
        %% Ask the user to select a template for signal detection
        figure(1)
        plot(d,s)
%         goodS = input('Satisfactory Signal? (0/1) >>');
        goodS = 1;
        if goodS
            [x,~] = ginput(2);
            tmplt = s;
            tmplt = tmplt(d>x(1)&d<x(2));
        end
        s = abs(hilbert(s));
        s(d<powerRange(1)) = 0;
        s(d>powerRange(2)) = 0;
        idx = findFrontEdge(s,threshold);
        if isnan(idx)
            keyboard
        else
            skDist(distIdx) = d(idx);
            distIdx = distIdx+1;
        end
    end
end
if ~exist('tmplt','var')
    error('You didn''t select a signal template!');
end
%% Save results in specified location.
save(svName,'skDist','power','mxPower','powerRange','fName','elementsOfInterest','totPower','totS','tmplt','txSn');