% Tests the placement of the array on the skull. Checks both the position
% and the returned power against the results in the file, goldStd. Saves
% the raw and processed data as a .mat file in svName.
% 
% @INPUTS
%   goldStd: mat file containing data for the "gold standard experiment."
%       This refers to the data acquired on the day of the MR scan.
%   svName: Full path and name in which to save the results of the current
%       test. The code will force a confirmation before overwriting an
%       existent file. This field is not required if fName is provided and
%       the function will not save any resuls if fName is provided. It is,
%       however, required if the hardware is used to acquire the data.
%   fName: Optional. Specifies the location of a file with the single and
%      gridded element data. If no file is provided then the function
%      imageSkull is run in order to obtain the data.
% 
% @OUTPUTS
%   posErr: 256 element vector with the difference in mm between the
%       estimated location of the skull in the current run compared to the
%       gold standard acquisition.
%   couplingErr: Difference in power (as a percentage) at each
%       individual element.
% 
% Taylor Webb
% Targeted Treatments Laboratory
% University of Utah
% March 2020

function [posError,couplingErr,rawTraces] = testArrayPlacement(goldStd,svName,fName)
%% Error checking
% Load Gold Standard Data
gs = load(goldStd);
if ~isfield(gs,'fName')
    error('Invalid gold standard file')
end
gsRaw = load(gs.fName);

if exist('fName','var')
    data = load(fName);
    sImg = data.singleElRaw;
    gImg = data.griddedElRaw;
else
    if exist(svName, 'file')
        ovw = input('A file already exists in the specified location, overwrite (this action is irreversible)? (0/1)>> ');
        if ~ovw
            error(['File: ', num2str(svName), ' already exists'])
        end
    end
    
    [singleElRaw,griddedElRaw] = imageSkull();
    save(svName,'singleElRaw','griddedElRaw')
    sImg = singleElRaw;
    gImg = griddedElRaw;
end

%% Show image for summary
[img,xa,ya,za] = griddedElementBModeImage(gImg.RcvData,gImg.Receive);
gsImg = griddedElementBModeImage(gsRaw.griddedElRaw.RcvData,gsRaw.griddedElRaw.Receive);
img(isnan(img)) = 0;
gsImg(isnan(gsImg)) = 0;
elements = transducerGeometry(0);
h = figure;
set(h,'position',[2          42        958        954]);
h2 = figure;
set(h2,'position',[962          42        958        954]);

% These images were produced with grids of elements so there won't be data
% at the edges of the array. Find where we expect data.
yFrames = unique(elements.ElementPos(:,2));
yFrames = yFrames(2:end-1);
width = 0.30;
height = 0.45;

for ii = 1:6
    figure(h2)
    if ii < 4
        sp2(ii) = axes('Position',[(ii-1)*width,0.5,width,height]);
    else
        sp2(ii) = axes('Position',[(ii-4)*width,0,width,height]);
    end
    [~,yIdx] = min(abs(ya-yFrames(ii)));
    imshowpair(squeeze(img(:,yIdx,:)),squeeze(gsImg(:,yIdx,:)));%,...
%         'falsecolor','xdata',za,'ydata',xa);
    axis('equal')
    axis('tight')
    makeFigureBig(h2);
    
    figure(h)
    if ii < 4
        sp(ii) = axes('Position',[(ii-1)*width,0.5,width,height]);
    else
        sp(ii) = axes('Position',[(ii-4)*width,0,width,height]);
    end
    [~,yIdx] = min(abs(ya-yFrames(ii)));
    imshow(squeeze(img(:,yIdx,:)),[0,1/10*max(img(:))]);%,...
%         'falsecolor','xdata',za,'ydata',xa);
    axis('equal')
    axis('tight')
    makeFigureBig(h);
end
axes(sp(2));
tt = title('Current Data');
tt.Position = [15.5,0.0105,0];
keyboard

axes(sp2(2));
tt = title('Overlay of Current Data to Gold Standard Data');
tt.Position = [15.5,0.0105,0];

axes(sp2(5));
title('Current: Green, Prior: Purple');

axes(sp(1))
tt = title('Front');
set(tt,'FontSize',12)

axes(sp2(1))
tt = title('Front');
set(tt,'FontSize',12)

axes(sp(6))
tt = title('Back');
set(tt,'FontSize',12)

axes(sp2(6))
tt = title('Back');
set(tt,'FontSize',12)
%% Gridded Element Results (distance)
RcvData = gImg.RcvData;
Receive = gImg.Receive;
Resource = gImg.Resource;
Trans = transducerGeometry(0);
t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);
d = t*1.492/2+Receive(1).startDepth*Resource.Parameters.speedOfSound/(Trans.frequency*1e6)*1e3;

elementsOfInterest = gs.elementsOfInterest;
gridSize = 3;
blocks = selectElementBlocks(gridSize);
distIdx = 1;
skDist = zeros(size(elementsOfInterest));
blIDx = skDist;
threshold = 5e3;
for ii = 1:length(blocks)
    centerElement = blocks{ii}(ceil(gridSize^2/2));
    if ismember(centerElement,elementsOfInterest)
        blIdx(distIdx) = ii;
        s = zeros(size(RcvData(Receive(ii).startSample:Receive(ii).endSample,blocks{ii}(1))));
        for jj = 1:gridSize^2
            curS = double(RcvData(Receive(ii).startSample:Receive(ii).endSample,blocks{ii}(jj)));
            s = curS+s;
        end
        s = abs(hilbert(s));
        s(d<gs.powerRange(1)) = 0;
        s(d>gs.powerRange(2)) = 0;
        idx = findFrontEdge(s,threshold);
        if isnan(idx)
            keyboard
        else
            skDist(distIdx) = d(idx);
            distIdx = distIdx+1;
        end
    end
end
idx = find(abs(skDist-gs.skDist) > 1);
if isempty(idx)
    showPlots = questdlg(['All grids show good agreement on distance! Average error:',...
        num2str(mean(abs(skDist-gs.skDist))), 'mm. Show traces?']);
    if strcmp('Yes',showPlots)
        idx = 1:length(elementsOfInterest);
        showPlots = 1;
    else
        showPlots = 0;
    end
else
    showPlots = questdlg([num2str(length(idx)), ' show error greater than 1 mm! Average error:',...
        num2str(mean(abs(skDist-gs.skDist))), 'mm. Show traces?'],...
        'Distance Results','All','Only Errors','None','Only Errors');
    if strcmp('All',showPlots)
        idx = 1:length(elementsOfInterest);
        showPlots = 1;
    elseif strcmp('None',showPlots)
        showPlots = 0;
    else
        showPlots = 1;
    end
end
if showPlots
    gsRaw = load(gs.fName);
    gsReceive = gsRaw.griddedElRaw.Receive;
    gsRcvData = gsRaw.griddedElRaw.RcvData;
    h = figure;
%     set(h,'position',[1364          162         556        954])
    for ii = 1:length(idx)
        curIdx = blIdx(idx(ii));
        s = zeros(size(RcvData(Receive(ii).startSample:Receive(ii).endSample,blocks{1}(1))));
        for jj = 1:gridSize^2
            curS = double(RcvData(Receive(curIdx).startSample:Receive(curIdx).endSample,...
                blocks{curIdx}(jj)));
            s = curS+s;
        end
        s = abs(hilbert(s));
        s(d<gs.powerRange(1)) = 0;
        s(d>gs.powerRange(2)) = 0;

        sGs = zeros(size(gsRcvData(gsReceive(ii).startSample:gsReceive(ii).endSample,blocks{ii}(1))));
        for jj = 1:gridSize^2
            curS = double(gsRcvData(gsReceive(curIdx).startSample:gsReceive(curIdx).endSample,...
                blocks{curIdx}(jj)));
            sGs = curS+sGs;
        end
        sGs = abs(hilbert(sGs));
        sGs(d<gs.powerRange(1)) = 0;
        sGs(d>gs.powerRange(2)) = 0;

        subplot(length(idx),1,ii)
        plot(d,s,'-',d,sGs,'-','linewidth',2)
        hold on
        ax = gca;
        ax.ColorOrderIndex = 1;
        plot([skDist(idx(ii)),skDist(idx(ii))],[0,max(s)],'--',...
            [gs.skDist(idx(ii)),gs.skDist(idx(ii))],[0,max(s)],'--','linewidth',2)
%         plotElementLocation(ax,[gs.powerRange(2)-5,max([0.75*max(sGs),0.75*max(s)])],...
%             5,blocks{curIdx});
        ylabel('a.u.')
        axis([gs.powerRange',0,max([max(s),max(sGs)])])
        if ii == length(idx)
            xlabel('distance (mm)');
        else
            ax.XTick = [];
        end
        title(['Err: ', num2str(abs(skDist(idx(ii))-gs.skDist(idx(ii))),2)])
        if ii == 1
            lgd = legend('Current','Gold Standard','location','northwest');
%             set(lgd,'position', [0.0276    0.9303    0.3435    0.0545]);
        end
        makeFigureBig(h);
    end
end

%% Single Element Results (power)
Receive = sImg.Receive;
Resource = sImg.Resource;
Trans = transducerGeometry(0);
RcvData = sImg.RcvData;

t = 1e6*(0:(Receive(1).endSample-1))/(Receive(1).ADCRate*1e6/Receive(1).decimFactor);
d = t*1.492/2+Receive(1).startDepth*Resource.Parameters.speedOfSound/(Trans.frequency*1e6)*1e3;
power = zeros(1,256);
mxPower = power;
totPower = 0;
totS = zeros(size(RcvData(Receive(ii).startSample:Receive(ii).endSample,ii)));
rawTraces = zeros(256,length(d));
for ii = 1:size(RcvData,2)
    s = RcvData(Receive(ii).startSample:Receive(ii).endSample,ii);
    rawTraces(ii,:) = s;
    s = abs(hilbert(s));
    s(d < gs.powerRange(1)) = 0;
    s(d > gs.powerRange(2)) = 0;
%     s = s.^2;
    power(ii) = sum(s);
    mxPower(ii) = max(s);
    totPower = totPower+power(ii);
    totS = totS+s;
end
%% Visualize total power on each element
pctThreshold = 0.2;
xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

plotElementValues(xTx,yTx,zTx,power/max(power))
title('Total power on individual elements')
h = gcf;
h.Position = [h.Position(1)-h.Position(3)/2,h.Position(2:4)];

pctPower = 100*(power-gs.power)./gs.power;
pctPower(pctPower<-pctThreshold*100) = -pctThreshold*100;
pctPower(pctPower>pctThreshold*100) = pctThreshold*100;
plotElementValues(xTx,yTx,zTx,pctPower,'jet')
title('Percent difference')
h = gcf;
h.Position = [h.Position(1)-h.Position(3)/2,h.Position(2)-h.Position(4),h.Position(3:4)];

%% Visualize trouble spots by showing where power differences exceed different thresholds
curThreshold = 0.1;
idx1 = find(abs(power-gs.power)./gs.power > curThreshold & power > gs.power & abs(mxPower-gs.mxPower)./gs.mxPower > curThreshold);
idx2 = find(abs(power-gs.power)./gs.power > curThreshold & power < gs.power & abs(mxPower-gs.mxPower)./gs.mxPower > curThreshold);

h = figure;
h.Position = [h.Position(1)+h.Position(3)/2,h.Position(2)-h.Position(4),h.Position(3:4)];
subplot(221)
ax = gca;
ax2 = plotElementLocation2(ax,[1,1/2],[idx1,-idx2],4);
axes(ax);
ax.Visible = 'off';
ax.Title.Visible = 'on';
title([num2str(curThreshold*100), '% Threshold'])
makeFigureBig(h,14,14);
axes(ax2)

curThreshold = 0.2;
idx1 = find(abs(power-gs.power)./gs.power > curThreshold & power > gs.power & abs(mxPower-gs.mxPower)./gs.mxPower > curThreshold);
idx2 = find(abs(power-gs.power)./gs.power > curThreshold & power < gs.power & abs(mxPower-gs.mxPower)./gs.mxPower > curThreshold);

subplot(222)
ax = gca;
ax2 = plotElementLocation2(ax,[1,1/2],[idx1,-idx2],4);
axes(ax);
ax.Visible = 'off';
ax.Title.Visible = 'on';
title([num2str(curThreshold*100), '% Threshold'])
makeFigureBig(h,14,14);
axes(ax2)

curThreshold = 0.35;
idx1 = find(abs(power-gs.power)./gs.power > curThreshold & power > gs.power & abs(mxPower-gs.mxPower)./gs.mxPower > curThreshold);
idx2 = find(abs(power-gs.power)./gs.power > curThreshold & power < gs.power & abs(mxPower-gs.mxPower)./gs.mxPower > curThreshold);

subplot(223)
ax = gca;
ax2 = plotElementLocation2(ax,[1,1/2],[idx1,-idx2],4);
axes(ax);
ax.Visible = 'off';
ax.Title.Visible = 'on';
title([num2str(curThreshold*100), '% Threshold'])
makeFigureBig(h,14,14);
axes(ax2)

curThreshold = 0.5;
idx1 = find(abs(power-gs.power)./gs.power > curThreshold & power > gs.power & abs(mxPower-gs.mxPower)./gs.mxPower > curThreshold);
idx2 = find(abs(power-gs.power)./gs.power > curThreshold & power < gs.power & abs(mxPower-gs.mxPower)./gs.mxPower > curThreshold);

subplot(224)
ax = gca;
ax2 = plotElementLocation2(ax,[1,1/2],[idx1,-idx2],4);
axes(ax);
ax.Visible = 'off';
ax.Title.Visible = 'on';
title([num2str(curThreshold*100), '% Threshold'])
makeFigureBig(h,14,14);
axes(ax2)

%% Plot total power and mark whether each element is above or below the gold standard
idx1 = find(abs(power-gs.power)./gs.power > pctThreshold & power > gs.power & abs(mxPower-gs.mxPower)./gs.mxPower > pctThreshold);
idx2 = find(abs(power-gs.power)./gs.power > pctThreshold & power < gs.power & abs(mxPower-gs.mxPower)./gs.mxPower > pctThreshold);
idx = [idx1,idx2];

if ~isempty(idx)
    h = figure;
    plot(d,totS/max(gs.totS),'--',d,gs.totS/max(gs.totS),'-','linewidth',2)
    ax = gca;
    xlabel('Distance (mm)')
    ylabel('Voltage (a.u.)')
    axis([gs.powerRange',0,max([1,max(totS/max(gs.totS))])])
    makeFigureBig(h);
    plotElementLocation2(ax,[1/3,1/6],[idx1,-idx2])
    h.Position = [h.Position(1)+h.Position(3)/2,h.Position(2:4)];
    drawnow
    
    showPlots = questdlg(['Current Power/GS Power: ', num2str(totPower/gs.totPower,2),...
        '. ', num2str(length(idx)), ' elements exceed threshold! Show Offending Elements?']);
    
    if strcmp('Yes',showPlots)
        gsReceive = gsRaw.singleElRaw.Receive;
        gsRcvData = gsRaw.singleElRaw.RcvData;
        for ii = 1:ceil(length(idx)/5)
            h = figure(99);
            clf;
            set(h,'position',[2          42        958        954])
            for jj = 1:5
                if (ii-1)*5+jj <= length(idx)
                    curIdx = idx((ii-1)*5+jj);
                else
                    continue;
                end
                s = RcvData(Receive(curIdx).startSample:Receive(curIdx).endSample,curIdx);
                s = abs(hilbert(s));

                sGs = gsRcvData(gsReceive(curIdx).startSample:gsReceive(curIdx).endSample,curIdx);
                sGs = abs(hilbert(sGs));
                subplot(5,1,jj)
                plot(d,s,'--',d,sGs,'-','linewidth',2)
                ax = gca;
                plotElementLocation2(ax,[1/2,1/2],sign(power(curIdx)-gs.power(curIdx))*curIdx)
                xlabel('distance (mm)')
                ylabel('a.u.')
                title(['Element ', num2str(curIdx)])
                makeFigureBig(h);
            end        
            waitforbuttonpress
        end
    elseif strcmp('Cancel',showPlots)
        return
    end
end
posError = skDist-gs.skDist;
couplingErr = (power-gs.power)./gs.power;