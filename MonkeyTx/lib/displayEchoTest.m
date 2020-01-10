% Displays the results of an echo test. This is a test done by firing a
% short burst from each element of the 256 element doppler array and
% listening to the echo. This code displays the location of the first echo
% as an approximation of the location of the skull. It uses signals
% recorded in pure water to eliminate transients and assumes a pencil beam
% from each element
% 
% @INPUTS
%   RcvData: RcvData Cell array returned by VSX
%   Trans: Trans structure created by the script defining the VSX run.
%   Receive: Receive structure created by the script defining the VSX run.
% 
% @OUTPUTS
%   None but two plots showing the estimated geometry of the skull are
%       created.
% 
% Taylor Webb
% University of Utah
% January 2020

function displayEchoTest(RcvData,Trans,Receive)

RcvData = double(RcvData{1});

xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);
d = 0.5*1.5*t; % Half because round trip and assuming 1.5 mm/usec velocity

transients = load('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\transientMeasurements.mat');
template = double(transients.RcvData{1}(Receive(124).startSample:Receive(124).endSample,124));
template = template(615:745);

brokenElements = brokenElementsDoppler1();

% Threshold for cross correlation. If the cross correlation never exceeds
% this threshold within the range where the skull could be then the delay
% will be set to zero, suggesting there may be no coupling for that
% particular element.
threshold = 150; 

distanceFromTx = zeros(size(xTx));
xSk = zeros(size(xTx));
ySk = xSk;
zSk = xSk;
transientPower = xSk;
elLabel = cell(size(xTx));
h = figure;
subplot(211)
hold on;
for ii = 1:length(xTx)
    if ismember(ii,brokenElements)
        distanceFromTx(ii) = nan;
        transientPower(ii) = nan;
        continue
    end
    disp(['Element ', num2str(ii), ' of 256'])
    elLabel{ii} = num2str(ii);
    s = RcvData(:,ii);
    s = s(Receive(ii).startSample:Receive(ii).endSample);
%     s = log10(abs(hilbert(s)));
    transSig = double(transients.RcvData{1}(Receive(ii).startSample:Receive(ii).endSample,ii));
%     
    transSig(t*0.5*1.492>20) = 0; 
    s = s-transSig;
    transientPower(ii) = sum(abs(s(s<5).^2));
    [xProjection,zProjection] = signalLocation(Trans.ElementPos(ii,:));
    
    filtered = xcorr(s,template(end:-1:1));
    filtered = filtered(length(s):end);
    [~,idx] = max(filtered);
    if filtered(idx)*max(s)/max(filtered) < threshold
        idx = 1;
    end
    
%     if d(idx) < 5 % This is likely an artifact of the transients at the beginning of the signal, look for other peaks
%         [pks,locs] = findpeaks(filtered);
%         mxPk = max(pks);
%         newPkLocs = find(pks.'>1/10*mxPk & d(locs) > 5);
%         if ~isempty(newPkLocs)
%             [~,idx] = max(filtered(locs(newPkLocs)));
%             idx = locs(idx);
%         end
%     end
    
    xSk(ii) = xTx(ii)+xProjection*d(idx);
    ySk(ii) = yTx(ii);
    zSk(ii) = zTx(ii)+zProjection*d(idx);

    cMap = colormap('hot');
    maxDistance = 15; % maximum distance for purpose of colormap in mm
    distanceFromTx(ii) = sqrt((xSk(ii)-xTx(ii))^2+(ySk(ii)-yTx(ii))^2+(zSk(ii)-zTx(ii))^2);
    cIdx = round((distanceFromTx(ii)/maxDistance)*size(cMap,1));
    
    if cIdx>size(cMap,1)
        cIdx = size(cMap,1);
    elseif cIdx == 0
        cIdx = 1;
    end
    
    plot3(xSk(ii),ySk(ii),zSk(ii),'o','Color',cMap(cIdx,:))
end
axis('equal')
subplot(212)
plot3(xSk,ySk,zSk,'.')
text(xSk,ySk,zSk,elLabel)
axis('equal')
makeFigureBig(h);

%% Plot the distance for each element in 2D
% plotPhases2D(distanceFromTx);
delays = zeros(8,32);
for ii = 1:length(distanceFromTx)
    x = ceil(ii/8);
    if mod(ii,8)
        y = mod(ii,8);
    else
        y = 8;
    end
    delays(y,x) = distanceFromTx(ii);
    tPower(y,x) = transientPower(ii);
end
hDistance = figure;
subplot(211)
imagesc([1,32],[1,8],delays,'AlphaData',double(~isnan(delays)))
ax = gca;
ax.CLim = [7,15];
ax.XTick = [1,32];
ax.XTickLabel = {'8','256'};
ax.YTick = [1,8];
title('Distance from Tx')
colorbar
axis('equal')
axis('tight')
makeFigureBig(hDistance)

subplot(212)
imagesc([1,32],[1,8],tPower,'AlphaData',double(~isnan(tPower)))
ax = gca;
% ax.CLim = [0,15];
ax.XTick = [1,32];
ax.XTickLabel = {'8','256'};
ax.YTick = [1,8];
title('Transient Power')
colorbar
axis('equal')
axis('tight')
makeFigureBig(hDistance)

%% Allow the user to look at individual elements
h = figure;
while 1
    disp('Select an element to see the signal from that element.')
    disp('Use <ctrl>+c or close the figure to quit.')
    figure(hDistance);
    set(hDistance,'position',[962    42   958   954])
    [x,y] = ginput(1);
    
    elementNo = (round(x)-1)*8+round(y);
    
    disp(['Estimated Distance From Element:', num2str(distanceFromTx(elementNo))])

    s = RcvData(:,elementNo);
    s = s(Receive(elementNo).startSample:Receive(elementNo).endSample);
    transSig = double(transients.RcvData{1}(Receive(elementNo).startSample:Receive(elementNo).endSample,elementNo));
    transSig(t*0.5*1.492>20) = 0; 
    sNormalized = s-transSig;
    
    sEnv = abs(hilbert(s));
    sNormalizedEnv = abs(hilbert(sNormalized));
    
    sEnv = 20*log10(sEnv/max(sEnv));
    sNormalizedEnv = 20*log10(sNormalizedEnv/max(sNormalizedEnv));
    
    figure(h);
    clf;
    subplot(411);
    plot(d,s);
    ylabel('V')
    title(['Raw Signal (Estimated Distance: ', num2str(distanceFromTx(elementNo)), ')'])
    makeFigureBig(h)
    
    subplot(412)
    plot(d,sEnv);
    title('Envelope')
    ylabel('dB')
    makeFigureBig(h)
    
    filtered = (xcorr(sNormalized,template(end:-1:1))).';
    filtered = filtered*max(sNormalized)/max(filtered(length(s):end));
    subplot(413);
    plot(d,sNormalized,'-',d,filtered(length(s):end),'--');
    title('Raw Signal After Subtracting Transients')
    makeFigureBig(h)
    
    subplot(414)
    plot(d,sNormalizedEnv)
    ylabel('dB')
    xlabel('distance (mm)')
    title('Envelope after subtraction')
    makeFigureBig(h)
    set(h,'position',[2    42   958   954]);
    drawnow
end