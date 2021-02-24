sonNo = 2;
% logFile = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\20201014\Logs\Euler3.mat';
% logFile = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\20201014\Logs\NormalizedPositions\Euler_20200910.mat';
logFile = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\20201202\Logs\Euler_20201202.mat';
load(logFile);
orientation = 'axial';
% sys.sonication(1).phaseSeriesNo = 68;
% sys.sonication(1).magSeriesNo = 67;
% sys.sonication(2).phaseSeriesNo = 70;
% sys.sonication(2).magSeriesNo = 69;
% sys.sonication(3).phaseSeriesNo = 76;
% sys.sonication(3).magSeriesNo = 75;
% sys.sonication(4) = sys.sonication(3);
% sys = adjustFocus(sys,[11,-1,67],'US');
% sys.sonication(4).focalSpot = sys.focalSpot;
% sys.sonication(4).focalSpotMr = sys.focalSpotMr;
% sys.sonication(4).focalSpotIdx = sys.focalSpotIdx;
% sys.sonication(4).phaseSeriesNo = 74;
% sys.sonication(4).magSeriesNo = 73;
% sys.sonication(6).phaseSeriesNo = 40;
% sys.sonication(6).magSeriesNo = 39;
sys.mrPath = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\20201014\Images\';
% sys.mrPath = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\20200910\Images\';
sys.mrPath = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\20201202\Images\';
sys.expPath = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\20201202\';
[T,tImg,tMagImg,tx,ty,tz,phHeader] = loadTemperatureSonication(sys,sonNo);

%%
T = denoiseThermometry(T,sys.sonication(sonNo).firstDynamic,sys.sonication(sonNo).duration,phHeader);

curT = T(:,:,:,sys.sonication(sonNo).firstDynamic+1);
curT(tMagImg<mean(tMagImg(:))) = 0;
%%
[~,thIdx(1)] = min(abs(sys.sonication(sonNo).focalSpotMr(1)*1e-3-tx));
[~,thIdx(2)] = min(abs(sys.sonication(sonNo).focalSpotMr(2)*1e-3-ty));
[~,thIdx(3)] = min(abs(sys.sonication(sonNo).focalSpotMr(3)*1e-3-tz));

figure
subplot(131)
imshow(curT(:,:,thIdx(3)-1),[0,2],'initialmagnification','fit')
subplot(132)
imshow(curT(:,:,thIdx(3)),[0,2],'initialmagnification','fit')
subplot(133)
imshow(curT(:,:,thIdx(3)+1),[0,2],'initialmagnification','fit')

%% Find maximum heating voxel
switch orientation
    case 'axial'
        windowSize = [4,4,1];
    case 'coronal'
        windowSize = [4 1 4];
end

tmpX = thIdx(1)-windowSize(1):thIdx(1)+windowSize(1);
tmpY = thIdx(2)-windowSize(2):thIdx(2)+windowSize(2);
tmpZ = thIdx(3)-windowSize(3):thIdx(3)+windowSize(3);

tmpT = curT(tmpX,tmpY,tmpZ);

[maxT,mxIdx] = max(tmpT(:));
[a,b,c] = ind2sub(size(tmpT),mxIdx);

maxIdx = [tmpX(a),tmpY(b),tmpZ(c)];
maxUS = thermometry2usCoords(sys,[tx(maxIdx(1)),ty(maxIdx(2)),tz(maxIdx(3))]);

%% Segment out HPBW focus
binT = curT>0.5*curT(maxIdx(1),maxIdx(2),maxIdx(3));

% st = regionprops('table',binT(:,:,maxIdx(3)),'Centroid',...
%     'MajorAxisLength','MinorAxisLength');

% st = regionprops(binT(:,:,maxIdx(3)),'Centroid',...
%     'MajorAxisLength','MinorAxisLength');
% for ii = 1:length(st)
%     dst(ii) = sqrt((st(ii).Centroid(2)-maxIdx(1))^2+(st(ii).Centroid(1)-maxIdx(2))^2);
% end
% [~,bstIdx] = min(dst)
cc = bwconncomp(binT,18);
st = regionprops(cc,binT,'centroid','area','pixelidxlist');
for ii = 1:length(st)
    dst(ii) = sqrt((st(ii).Centroid(2)-maxIdx(1))^2+(st(ii).Centroid(1)-maxIdx(2))^2+9*(st(ii).Centroid(3)-maxIdx(3))^2);
end

[~,bstIdx] = min(dst);
% dst(bstIdx) = nan;
% [~,bstIdx] = min(dst);
roi = false(size(binT));
roi(st(bstIdx).PixelIdxList) = true;
segT = curT;
segT(~roi) = 0;

switch orientation
    case 'axial'
        figure
        for ii = 1:size(binT,3)
            subplot(121)
            imshow(squeeze(curT(:,:,ii)),[0,2])
            if ii == maxIdx(3)
                hold on
                plot(maxIdx(2),maxIdx(1),'^')
            end

            subplot(122)
            imshow(squeeze(segT(:,:,ii)),[0,2])
            waitforbuttonpress
        end
    case 'coronal'
        figure
        for ii = 1:size(binT,2)
            subplot(121)
            imshow(squeeze(curT(:,ii,:)),[0,2])
            if ii == maxIdx(2)
                hold on
                plot(maxIdx(3),maxIdx(1),'^')
            end

            subplot(122)
            imshow(squeeze(segT(:,ii,:)),[0,2])
            waitforbuttonpress
        end
end
cm = round(centerOfMass(segT));
cmTh(1) = tx(cm(1));
cmTh(2) = ty(cm(2));
cmTh(3) = tz(cm(3));

cmUs = thermometry2usCoords(sys,cmTh);
st = st(bstIdx);

[maxT2,idx] = max(curT(roi));
[a,b,c] = ind2sub(size(curT),st.PixelIdxList(idx));
maxUS2 = thermometry2usCoords(sys,[tx(a),ty(b),tz(c)]);

%%
res = struct('sonication', sys.sonication(sonNo),'logfile',logFile,'sonNo',sonNo,...
    'roi',roi,'cm',cm,'st',st,'cmUs',cmUs,'maxUS',maxUS,'tx',tx,'ty',ty,'tz',tz,...
    'maxUS2',maxUS2,'maxT',maxT,'maxT2',maxT2);

% if exist('leftLGN','var')
%     leftLGN(end+1) = res;
% else 
%     leftLGN = res;
% end