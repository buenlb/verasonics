close all; clear elements
data = RcvData{1};

xFoci = -15:3:15;
zFoci = 35:5:70;

xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

elements.x = xTx*1e-3;
elements.y = yTx*1e-3;
elements.z = zTx*1e-3;

t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);
d = t*0.5*1.492;
dt = t(2)-t(1);

idx = 1;
for ii = 1:length(xFoci)
    for jj = 1:length(zFoci)
        elements = steerArray(elements,[xFoci(ii),0,zFoci(jj)]*1e-3,Trans.frequency,0);
        delays = [elements.t]';
        curTotal = zeros(length(Receive(idx).startSample:Receive(idx).endSample),1);
        for kk = 1:length(delays)
            curS = data(Receive(idx).startSample:Receive(idx).endSample,kk);
            curS = circshift(curS,[round(delays(kk)/(650e-3*dt)),1]);
            curTotal = curTotal+double(curS);
%             if kk == 4
%                 keyboard
%             end
        end
        if ii == 4 && jj == 5
%             keyboard
        end
        R = sqrt((xTx-xFoci(ii)).^2+(zTx-zFoci(jj)).^2+yTx.^2);
        effectiveFocalDistance = max(R);
        voxelIdx = find(d>effectiveFocalDistance & d<effectiveFocalDistance+7);
        
        totals{ii,jj} = curTotal;
        dists(ii,jj) = effectiveFocalDistance;
        
        curTotal = abs(hilbert(curTotal));
        voxelBrightness(ii,jj) = sum(curTotal(voxelIdx));        
        
        idx = idx + 1;
    end
%     keyboard
end

figure
imagesc(xFoci,zFoci,voxelBrightness')
axis('equal')
axis('tight')