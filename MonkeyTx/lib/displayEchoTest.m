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


distanceFromTx = zeros(size(xTx));
xSk = zeros(size(xTx));
ySk = xSk;
zSk = xSk;
elLabel = cell(size(xTx));
h = figure;
subplot(211)
hold on;
for ii = 1:length(xTx)
    disp(['Element ', num2str(ii), ' of 256'])
    elLabel{ii} = num2str(ii);
    s = RcvData(:,ii);
    s = s(Receive(ii).startSample:Receive(ii).endSample);
%     s = log10(abs(hilbert(s)));
    transSig = double(transients.RcvData{1}(Receive(ii).startSample:Receive(ii).endSample,ii));
%     
    transSig(t*0.5*1.492>20) = 0; 
    s = s-transSig;
%     s(d<10) = 0;
    
    [xProjection,zProjection] = signalLocation(Trans.ElementPos(ii,:));
    
    [~,idx] = max(xcorr(s,template(end:-1:1)));
    idx = idx - length(s);

    if idx < 0
        continue
    end    
    
    xSk(ii) = xTx(ii)+xProjection*d(idx);
    ySk(ii) = yTx(ii);
    zSk(ii) = zTx(ii)+zProjection*d(idx);

    cMap = colormap('hot');
    maxDistance = 15; % maximum distance for purpose of colormap in mm
    distanceFromTx(ii) = sqrt((xSk(ii)-xTx(ii))^2+(ySk(ii)-yTx(ii))^2+(zSk(ii)-zTx(ii))^2);
    cIdx = round((distanceFromTx(ii)/maxDistance)*size(cMap,1));
    
    if cIdx>size(cMap,1)
        cIdx = size(cMap,1);
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
plotPhases2D(distanceFromTx);