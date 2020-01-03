function receiveBeamformingImage(RcvData,Trans,Receive)
%% Initialize Variables
c = 1.492; % Speed of sound in water in mm/us

RcvData = RcvData{1};

xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);
dt = t(2)-t(1);

d = 0.5*c*t; % Half because round trip
dx = 5;
x = min(xTx):dx:max(xTx);
y = unique(yTx);
z = min(zTx):dx:200;
[X,Y,Z] = ndgrid(x,y,z);

R = zeros([256,size(X)]);
s = zeros(256,length(t));
for ii = 1:256
    R(ii,:,:,:) = sqrt((X-xTx(ii)).^2+(Y-yTx(ii)).^2+(Z-zTx(ii)).^2);
    s(ii,:) = RcvData(Receive(1).startSample:Receive(1).endSample,ii);
end

%% Recevie Beamforming
img = zeros(size(X));
for ii = 1:size(X,1)
    disp(['Row ', num2str(ii), ' of ', num2str(size(X,1))])
    for jj = 1:size(X,2)
        for kk = 1:size(X,3)
            delays = R(:,ii,jj,kk)/c;
            minDelay = min(delays);
            delays = delays-minDelay;
            idxDelays = round(delays/dt)+1;
            curS = zeros(size(t));
            for ll = 1:256
                curS = curS+[zeros(1,idxDelays(ll)),s(ll,1:end-(idxDelays(ll)))];
            end
            curS = log10(abs(hilbert(curS)));
            img(ii,jj,kk) = curS(2*round(minDelay/dt)+1);
        end
    end
end    
%%
wdw = [1,4];
h = figure;
imagesc(x,z,squeeze(img(:,4,:))',[wdw]); colorbar;
xlabel('mm')
ylabel('mm')
makeFigureBig(h);

% 
h = figure;
subplot(241)
imshow(squeeze(img(:,1,:))',wdw);

subplot(242)
imshow(squeeze(img(:,2,:))',wdw);

subplot(243)
imshow(squeeze(img(:,3,:))',wdw);

subplot(244)
imshow(squeeze(img(:,4,:))',wdw);

subplot(245)
imshow(squeeze(img(:,5,:))',wdw);

subplot(246)
imshow(squeeze(img(:,6,:))',wdw);

subplot(247)
imshow(squeeze(img(:,7,:))',wdw);

subplot(248)
imshow(squeeze(img(:,8,:))',wdw);

%%
keyboard