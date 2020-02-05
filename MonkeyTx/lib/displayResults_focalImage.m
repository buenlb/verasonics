function displayResults_focalImage(RData)
tic
persistent figHandle;
if isempty(figHandle)
    figHandle = figure;
end
try
    figure(figHandle);
catch
    figHandle = figure;
end
%% Get relevant structures from the base of the stack
Resource = evalin('base','Resource');
Trans = evalin('base','Trans');
Receive = evalin('base','Receive');

%% Determine which focus the system is on
curIdx = Resource.Parameters.curIdx
x = Resource.Parameters.x;
y = Resource.Parameters.y;
z = Resource.Parameters.z;

%% Load any existing results
img = Resource.Parameters.img;

%% Process Result
% Get time and distance vectors
t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);
d = t*0.5*1.492;
dt = t(2)-t(1);

% Get delays
xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

elements.x = xTx*1e-3;
elements.y = yTx*1e-3;
elements.z = zTx*1e-3;

for ii = 1:length(x)
    for jj = 1:length(y)
        elements = steerArray(elements,[x(ii),y(jj),z(curIdx)]*1e-3,Trans.frequency,0);
        delays = [elements.t]';

        %Delay and sum signals from each element
        curTotal = zeros(length(Receive(1).startSample:Receive(1).endSample),1);
        keyboard
        for kk = 1:length(delays)
            curS = RData(Receive(idx).startSample:Receive(idx).endSample,kk);
            curS = circshift(curS,[round(delays(kk)/(650e-3*dt)),1]);
            curTotal = curTotal+double(curS);
        end
        
        % Determine where in the signal to expect signal from the focus
        R = sqrt((xTx-x(ii)).^2+(zTx-z(curIdx)).^2+(yTx-y(jj)).^2);
        effectiveFocalDistance = max(R);

        % Determine voxel brightness
        curTotal = abs(hilbert(curTotal));
        img(ii,jj,curIdx) = max(curTotal(d>effectiveFocalDistance & d<effectiveFocalDistance+7));
    end
end
Resource.Parameters.img = img;
assignin('base','Resource',Resource);
%% Plot Results

figure(figHandle);
clf;
if length(y) > 1
    rows = ceil(sqrt(length(y)));
    cols = floor(sqrt(length(y)));
    if cols*rows < length(y)
        cols = cols+1;
    end

    for ii = 1:length(y)
        subplot(rows,cols,ii)
        imagesc(x,z,squeeze(img(:,ii,:))',[min(img(:)),max(img(:))])
        axis('equal')
        axis('tight')
        colorbar
        title(['y=',num2str(y(ii))]);
    end
    set(figHandle,'position',[2          42         958        1074])
else
    imagesc(x,z,squeeze(img(:,1,:))',[min(img(:)),max(img(:))])
    axis('equal')
    axis('tight')
    colorbar
    title(['y=',num2str(y(1))]);
    set(figHandle,'position',[2          42         958        1074])
end
if curIdx == length(x)
    save(Resource.Parameters.imageSaveName,'img','x','y','z','t');
end
toc