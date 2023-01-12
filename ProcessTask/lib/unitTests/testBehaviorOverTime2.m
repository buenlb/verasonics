% Test a false data set. This data should show a pronounced contralateral
% bias after sonication and no bias before

TESTDATA = 1;

idx = [idxLeft,idxRight];

tWindow = 5*60;
dt = 5*60;
tBefore = 10*60;
tAfter = 20*60;
tm = -tBefore:dt:tAfter;

y = nan(length(idx),length(tm));
epp = y;
side = nan(length(idx),1);
for ii = 1:length(idx)
    disp(['Session ', num2str(ii), ' of ', num2str(length(idx))]);
    mData = tData(idx(ii));
    prbBefore = [0.1,0.2,0.5,0.82,0.95];
    if mData.sonication.focalLocation(1)>0
        prbAfter = [0.15,0.3,0.55,0.87,0.98];
        side(ii) = 0;
    else
        prbAfter = [0.05,0.15,0.43,0.78,0.92];
        side(ii) = 1;
    end
    if TESTDATA
        delay = unique(mData.delay);
        if length(delay)>5
            continue
        end
        for jj = 1:length(mData.delay)
            dIdx = find(delay==mData.delay(jj));
            if mData.block(jj)<40
                prb = prbBefore;
            else
                prb = prbAfter;
            end
            if rand(1)<prb(dIdx)
                mData.ch(jj) = 1;
            else
                mData.ch(jj) = 0;
            end
        end
    end

    p50 = behaviorOverTime2(mData,0,tWindow);
    [epp(ii,:),y(ii,:)] = behaviorOverTime2(mData,tm,tWindow,p50);
end
%%
var2plot = y;
h = figure;
ax = gca;
hold on
shadedErrorBar(tm/60,100*mean(var2plot(side==0,:),1,'omitnan'),100*semOmitNan(var2plot(side==0,:),1),'lineprops',{'LineWidth',2,'Color',ax.ColorOrder(2,:)});
shadedErrorBar(tm/60,100*mean(var2plot(side==1,:),1,'omitnan'),100*semOmitNan(var2plot(side==1,:),1),'lineprops',{'LineWidth',2,'Color',ax.ColorOrder(1,:)});
% plot(tm/60,mean(var2plot(side==0,:),1,'omitnan'),tm/60,mean(var2plot(side==1,:),1,'omitnan'),'LineWidth',2)
xlabel('time (minutes)')
ylabel('Leftward Choices (%)')
% axis([-10,20,40,60])
makeFigureBig(h)
return
%% Load mouse simulation data
% This data was created using the mouse to simulate choices. There is no
% sonication (when the system is in test mode it does not execute the
% verasonics code that would lead to the sonication). I chose to make the
% sonication occur at block 20.
% 
% In this session I consciously sought to have a leftward bias before the
% sonication and a rightward bias after. To make it consistent I tried to
% avoid errors and chose the left target 3/4 times at zero delay before
% the sonication and the right target 3/4 times at zero delay after the
% sonication. The file is taylorTest20221019
mData = processTaskDataDurable('D:\Task\taylorTest20221019.mat');
blocks = mData.block;
sIdx = find(blocks==20);
sIdx = sIdx(1);
mData.sonicatedTrials = sIdx; 

p50 = behaviorOverTime2(mData,0,tWindow);
[epp,y,~,~,chVectors,dVectors] = behaviorOverTime2(mData,tm,tWindow,p50);

var2plot = y;
h = figure;
plot(tm/60,var2plot,'linewidth',2)
xlabel('Time (minutes)')
ylabel('Leftward Choices (%)')
% ylabel('leftward choices (%)')
makeFigureBig(h)

% Test delta calculation using returned sigmoids
h = figure;
idx = find(tm==0);
[slope,bias,downshift,scale] = fitSigmoid(dVectors(:,idx),chVectors(:,idx));
hold on;
ax = gca;
plot(dVectors(:,idx),chVectors(:,idx),'*','MarkerSize',8,'LineWidth',2)
ax.ColorOrderIndex = 1;
x = linspace(-120,120,1e3);
y1 = sigmoid_ext(x,slope,bias,downshift,scale);
plot(x,y1,'LineWidth',2)

np50 = -log(scale/(0.5-downshift)-1)/slope+bias;
if np50 ~= p50 
    error('Equal Probability point check failed!')
end
disp('Equal Probability Points Match!')

idx = idx+1;
[slope,bias,downshift,scale] = fitSigmoid(dVectors(:,idx),chVectors(:,idx));
hold on;
ax = gca;
plot(dVectors(:,idx),chVectors(:,idx),'*','MarkerSize',8,'LineWidth',2)
ax.ColorOrderIndex = 2;
x = linspace(-120,120,1e3);
y1 = sigmoid_ext(x,slope,bias,downshift,scale);
plot(x,y1,'LineWidth',2)

ny = sigmoid_ext(p50,slope,bias,downshift,scale);
ax.ColorOrderIndex = 1;
plot(p50,0.5,'^','LineWidth',2,'MarkerSize',8)
plot(p50,ny,'^','LineWidth',2,'MarkerSize',8)

if ny ~= y(idx)
    error('Delta check failed!')
end