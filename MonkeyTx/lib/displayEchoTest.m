function displayEchoTest(RcvData,Trans,Receive)

RcvData = double(RcvData{1});

xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);

%% Show an image
d = 0.5*1.5*t; % Half because round trip and assuming 1.5 mm/usec velocity
dt = t(2)-t(1);
dx = 1.5*dt;
x = min(xTx):dx:max(xTx);
y = unique(yTx);
z = min(zTx):dx:d(end);

[X,Y,Z] = ndgrid(x,y,z);
img = zeros(size(X));
avging = zeros(size(X));

transients = load('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\MonkeyTx\lib\transientMeasurements.mat');
template = double(transients.RcvData{1}(Receive(124).startSample:Receive(124).endSample,124));
template = template(615:745);

for ii = 1:256
    disp(['Element ', num2str(ii), ' of 256'])
    elLabel{ii} = num2str(ii);
    s = RcvData(:,ii);
    s = s(Receive(ii).startSample:Receive(ii).endSample);
%     s = log10(abs(hilbert(s)));
    transSig = double(transients.RcvData{1}(Receive(ii).startSample:Receive(ii).endSample,ii));
%     
    transSig(t*0.5*1.492>20) = 0; 
    s = s-transSig;
    s(d<10) = 0;
    
    [xProjection,zProjection] = signalLocation(Trans.ElementPos(ii,:));
    
    [~,idx] = max(xcorr(s,template(end:-1:1)));
    idx = idx - length(s);

    if idx < 0
        continue
    end    
    
    xSk(ii) = xTx(ii)+xProjection*d(idx);
    ySk(ii) = yTx(ii);
    zSk(ii) = zTx(ii)+zProjection*d(idx);
%     for jj = 1:length(d)
%         [~,idx] = min(abs(X(:)-(xProjection*d(jj)+xTx(ii))).^2+abs(Z(:)-(zProjection*d(jj)+zTx(ii))).^2+abs(Y(:)-yTx(ii)).^2);
%    
%         img(idx) = img(idx)+s(jj);
%         avging(idx) = avging(idx)+1;
%     end
end
figure
plot3(xSk,ySk,zSk,'o')
text(xSk,ySk,zSk,elLabel)
axis('equal')
keyboard
% img(boolean(avging)) = img(boolean(avging))./avging(boolean(avging));
% %%
% wdw = [1,4];
% h = figure;
% subplot(241)
% imshow(squeeze(img(:,1,:))',wdw);
% 
% subplot(242)
% imshow(squeeze(img(:,2,:))',wdw);
% 
% subplot(243)
% imshow(squeeze(img(:,3,:))',wdw);
% 
% subplot(244)
% imshow(squeeze(img(:,4,:))',wdw);
% 
% subplot(245)
% imshow(squeeze(img(:,5,:))',wdw);
% 
% subplot(246)
% imshow(squeeze(img(:,6,:))',wdw);
% 
% subplot(247)
% imshow(squeeze(img(:,7,:))',wdw);
% 
% subplot(248)
% imshow(squeeze(img(:,8,:))',wdw);
% keyboard
%% Plot the power on each element
p = zeros(1,256);
for ii = 1:256
    s = RcvData(:,ii);
    s = s(Receive(ii).startSample:Receive(ii).endSample);
    s = log10(abs(hilbert(s)));
    % Get rid of transients
    s(d<20) = 0;
    p(ii) = (sum(s));
end

plotPhases(xTx,yTx,zTx,p);