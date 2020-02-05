close all; clear elements
data = RcvData{1};

yFoci = -5:2:5;
xFoci = (-15:2:15);
zFoci = 30:3:60;

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
voxelBrightness = zeros(length(yFoci),length(xFoci),length(zFoci));
totals = cell(size(voxelBrightness));
dists = zeros(size(voxelBrightness));
for hh = 1:length(yFoci)
    for ii = 1:length(xFoci)
        for jj = 1:length(zFoci)
            elements = steerArray(elements,[xFoci(ii),yFoci(hh),zFoci(jj)]*1e-3,Trans.frequency,0);
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
            
            R = sqrt((xTx-xFoci(ii)).^2+(zTx-zFoci(jj)).^2+(yTx-yFoci(hh)).^2);
            effectiveFocalDistance = max(R);
            voxelIdx = find(d>effectiveFocalDistance & d<effectiveFocalDistance+7);

            totals{hh,ii,jj} = curTotal;
            dists(hh,ii,jj) = effectiveFocalDistance;

            curTotal = abs(hilbert(curTotal));
            voxelBrightness(hh,ii,jj) = sum(curTotal(voxelIdx));        
            if jj == 5 && ii == 5 && hh == 4
%                 keyboard
            end
            idx = idx + 1;
        end
    %     keyboard
    end
end
rows = ceil(sqrt(length(yFoci)));
cols = floor(sqrt(length(yFoci)));
if cols*rows < length(yFoci)
    cols = cols+1;
end

h = figure;
for ii = 1:length(yFoci)
    subplot(rows,cols,ii)
    imagesc(xFoci,zFoci,squeeze(voxelBrightness(ii,:,:))',[min(voxelBrightness(:)),max(voxelBrightness(:))])
    axis('equal')
    axis('tight')
    colorbar
    title(['y=',num2str(yFoci(ii))]);
end
set(h,'position',[2          42         958        1074])