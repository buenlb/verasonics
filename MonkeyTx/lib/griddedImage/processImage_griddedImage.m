function rawImg = processImage_griddedImage(RData)
VERBOSE = 1;
% Create Figure Window
if VERBOSE
    persistent figHandle;
    if isempty(figHandle)
        figHandle = figure;
    end
    try
        figure(figHandle);
    catch
        figHandle = figure;
    end
end

% Get necessary variables from base
Resource = evalin('base','Resource');
Receive = evalin('base','Receive');
Trans = evalin('base','Trans');

gridSize = Resource.Parameters.gridSize;
frequency = Trans.frequency;

blocks = selectElementBlocks(gridSize);


%% If complete plot results and exit
if Resource.Parameters.curGridIdx > length(blocks)
    img = Resource.Parameters.img./Resource.Parameters.imgAvg;
    
    Xa = Resource.Parameters.Xa;
    Ya = Resource.Parameters.Ya;
    Za = Resource.Parameters.Za;

    xa = squeeze(Xa(:,1,1));
    ya = squeeze(Ya(1,:,1));
    za = squeeze(Za(1,1,:));
    
    h = figure;
    yFrames = unique(Trans.ElementPos(:,2));
    rows = floor(sqrt(length(yFrames)));
    cols = ceil(sqrt(length(yFrames)));
    if rows*cols < length(yFrames)
        cols = cols+1;
    end

    for ii = 1:rows*cols
        subplot(rows,cols,ii)
        [~,yIdx] = min(abs(ya-yFrames(ii)));
        imagesc(za,xa,squeeze(img(:,yIdx,:)),[0,max(img(:))]);
        title(['y=',num2str(ya(yIdx))]);
        colorbar
        drawnow
    end
    set(h,'position',[1          41        1920        1083]);
    drawnow
    
    closeVSX();
    return;
end

%% Process data
curBlock = blocks{Resource.Parameters.curGridIdx};
if Resource.Parameters.curGridIdx == 1
    tic
else
    disp(['Beginning Process Step: ', num2str(toc)]);
end
disp(['Iteration: ', num2str(Resource.Parameters.curGridIdx), ' of ', num2str(length(blocks))])
centerElementPos = Trans.ElementPos(curBlock(ceil(gridSize^2/2)),:);

focX = Resource.Parameters.focalSpotsX;
focY = Resource.Parameters.focalSpotsY;
focZ = Resource.Parameters.focalSpotsZ;

% Time/distance vectors
t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);
dt = t(2)-t(1);
d = t*1.492/2+Receive(1).startDepth*Resource.Parameters.speedOfSound/(Trans.frequency*1e6)*1e3;
disp(['Starting Interpolation: ', num2str(toc)]);
idx = 1;
for ii = 1:length(focX)
    for jj = 1:length(focY)
        for kk = 1:length(focZ)
            % Find the correct delays
            xTx = Trans.ElementPos(curBlock,1);
            yTx = Trans.ElementPos(curBlock,2);
            zTx = Trans.ElementPos(curBlock,3);

            elements.x = xTx*1e-3;
            elements.y = yTx*1e-3;
            elements.z = zTx*1e-3;
            
            [xa,ya,za] = element2arrayCoords(focX(ii),...
                focY(jj),focZ(kk), centerElementPos);
            
            elements = steerArray(elements,...
                [xa,ya,za]*1e-3,...
                frequency,0);
            delays = [elements.t]';
            
            % Delay and sum the signal
            curTotal = zeros(length(Receive(1).startSample:Receive(1).endSample),1);
            for ll = 1:length(curBlock)
                curS = RData(Receive(idx).startSample:Receive(idx).endSample,curBlock(ll));
                curS = circshift(curS,[round(delays(kk)/(650e-3*dt)),1]);
                curTotal = curTotal+double(curS);
            end
            R = sqrt((xTx-focX(ii)).^2+(yTx-focY(jj)).^2+(zTx-focZ(kk)).^2);
            effectiveFocalDistance = max(R);

            if effectiveFocalDistance > d(end)
                warning('Effective focal distance is outside of receive depth!')
                img(ii,jj,kk) = 0;
            else
                % Determine voxel brightness
                curTotal = abs(hilbert(curTotal));
                img(ii,jj,kk) = max(curTotal(d>effectiveFocalDistance & d<effectiveFocalDistance+7));
                if img(ii,jj,kk) == 0
                    img(ii,jj,kk) = 0.1;
                end
            end
            idx = idx+1;
            Xe(ii,jj,kk) = focX(ii);
            Ye(ii,jj,kk) = focY(jj);
            Ze(ii,jj,kk) = focZ(kk);
        end
    end
end

%% Put the result in array space and add it to the img
Xa = Resource.Parameters.Xa;
Ya = Resource.Parameters.Ya;
Za = Resource.Parameters.Za;

xa = squeeze(Xa(:,1,1));
ya = squeeze(Ya(1,:,1));
za = squeeze(Za(1,1,:));

[Xar,Yar,Zar] = array2elementCoords(Xa,Ya,Za,centerElementPos);

rawImg = img;

img = interp3(Ye,Xe,Ze,img,Yar,Xar,Zar,'spline',0);
disp(['Interpolation Complete: ', num2str(toc)]);
imgAvg = zeros(size(img));
imgAvg(img ~= 0) = 1;


img = Resource.Parameters.img + img;
Resource.Parameters.img = img;
Resource.Parameters.imgAvg = Resource.Parameters.imgAvg + imgAvg;

assignin('base','Resource', Resource);

if VERBOSE
    figure(figHandle)
    clf
    yFrames = unique(Trans.ElementPos(:,2));
    rows = floor(sqrt(length(yFrames)));
    cols = ceil(sqrt(length(yFrames)));
    if rows*cols < length(yFrames)
        cols = cols+1;
    end

    for ii = 1:rows*cols
        subplot(rows,cols,ii)
        [~,yIdx] = min(abs(ya-yFrames(ii)));
        imagesc(za,xa,squeeze(img(:,yIdx,:)),[0,max(img(:))]);
        title(['y=',num2str(ya(yIdx))]);
        colorbar
        drawnow
    end
    set(figHandle,'position',[1          41        1920        1083]);
    drawnow

    disp(['Saving Data: ', num2str(toc)]);
    if Resource.Parameters.curGridIdx == 1
        header = struct('gridSize',gridSize,'frequency',frequency,...
        'focalSpotsX',focX,'focalSpotsY',focY,...
        'focalSpotsZ',focZ,'Xa',Xa,'Ya',Ya,'Za',Za);
        save([Resource.Parameters.saveDir, Resource.Parameters.logFileName], 'header')
    end
    save([Resource.Parameters.saveDir,'block',num2str(Resource.Parameters.curGridIdx),'.mat'],'RData');
    disp(['Completed Process Step: ', num2str(toc)]);
end