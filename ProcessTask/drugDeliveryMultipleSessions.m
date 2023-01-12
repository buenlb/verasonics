clear; close all; clc;

CALVIN = 1;
HOBBES = 0;

if CALVIN
    pth = 'D:\Task\Calvin\Propofol\';
    pthP = pth;
    files = dir([pth,'*.mat',]);
    
    if exist([pth,'curData.mat'],'file')
        old = load([pth,'curData.mat']);
    end
    
    curIdx = 1;
    found = 0;
    for ii = 1:length(files)
        monk(curIdx) = 'c';
        inj(curIdx) = 'p';
        if strcmp(files(ii).name,'curData.mat')
            continue
        end
        if exist('old','var')
            disp(['File ', num2str(ii), ' of ', num2str(length(files))])
            for jj = 1:length(old.processedFiles)
                if strcmp([pth,files(ii).name],old.processedFiles{jj})
                    oldIdx = jj;
                    found = 1;
                    disp('Already Processed, Loading...')
                    break
                end
            end
        else
            found = 0;
        end
        if found
            if ~isfield(old.tData(oldIdx),'usBlock')
                old.tData(oldIdx).usBlock = 40;
            elseif isempty(old.tData(oldIdx).usBlock)
                old.tData(oldIdx).usBlock = 40;
            end
            tData(curIdx) = old.tData(oldIdx);
            processedFiles{curIdx} = old.processedFiles{oldIdx};
            curIdx = curIdx+1;
        else
            try
                tData(curIdx) = processTaskDataDurable([pth,files(ii).name]);
                processedFiles{curIdx} = [pth,files(ii).name];
                curIdx = curIdx+1;
            catch me
                keyboard
                warning(['Loading of file:', files(ii).name, ' failed.']);
            end
        end
        found = 0;
    end

    pth = 'D:\Task\Calvin\Saline\';
    files = dir([pth,'*.mat',]);
    
    found = 0;
    for ii = 1:length(files)
        monk(curIdx) = 'c';
        inj(curIdx) = 's';
        if strcmp(files(ii).name,'curData.mat')
            continue
        end
        if exist('old','var')
            disp(['File ', num2str(ii), ' of ', num2str(length(files))])
            for jj = 1:length(old.processedFiles)
                if strcmp([pth,files(ii).name],old.processedFiles{jj})
                    oldIdx = jj;
                    found = 1;
                    disp('Already Processed, Loading...')
                    break
                end
            end
        else
            found = 0;
        end
        if found
            if ~isfield(old.tData(oldIdx),'usBlock')
                old.tData(oldIdx).usBlock = 40;
            elseif isempty(old.tData(oldIdx).usBlock)
                old.tData(oldIdx).usBlock = 40;
            end
            tData(curIdx) = old.tData(oldIdx);
            processedFiles{curIdx} = old.processedFiles{oldIdx};
            curIdx = curIdx+1;
        else
            try
                tData(curIdx) = processTaskDataDurable([pth,files(ii).name]);
                processedFiles{curIdx} = [pth,files(ii).name];
                curIdx = curIdx+1;
            catch me
                warning(['Loading of file:', files(ii).name, ' failed.']);
            end
        end
        found = 0;
    end
    save([pthP,'curData.mat'],'tData','processedFiles');
end


if HOBBES
    pth = 'D:\Task\Hobbes\Propofol\';
    pthP = pth;
    files = dir([pth,'*.mat',]);
    
    if exist([pth,'curData.mat'],'file')
        old = load([pth,'curData.mat']);
    end
    
    curIdx = 1;
    found = 0;
    for ii = 1:length(files)
        monk(curIdx) = 'h';
        inj(curIdx) = 'p';
        if strcmp(files(ii).name,'curData.mat')
            continue
        end
        if exist('old','var')
            disp(['File ', num2str(ii), ' of ', num2str(length(files))])
            for jj = 1:length(old.processedFiles)
                if strcmp([pth,files(ii).name],old.processedFiles{jj})
                    oldIdx = jj;
                    found = 1;
                    disp('Already Processed, Loading...')
                    break
                end
            end
        else
            found = 0;
        end
        if found
            if ~isfield(old.tData(oldIdx),'usBlock')
                old.tData(oldIdx).usBlock = 40;
            elseif isempty(old.tData(oldIdx).usBlock)
                old.tData(oldIdx).usBlock = 40;
            end
            tData(curIdx) = old.tData(oldIdx);
            processedFiles{curIdx} = old.processedFiles{oldIdx};
            curIdx = curIdx+1;
        else
            try
                tData(curIdx) = processTaskDataDurable([pth,files(ii).name]);
                processedFiles{curIdx} = [pth,files(ii).name];
                curIdx = curIdx+1;
            catch me
                warning(['Loading of file:', files(ii).name, ' failed.']);
            end
        end
        found = 0;
    end

    pth = 'D:\Task\Hobbes\Saline\';
    files = dir([pth,'*.mat',]);
    
    found = 0;
    for ii = 1:length(files)
        monk(curIdx) = 'h';
        inj(curIdx) = 's';
        if strcmp(files(ii).name,'curData.mat')
            continue
        end
        if exist('old','var')
            disp(['File ', num2str(ii), ' of ', num2str(length(files))])
            for jj = 1:length(old.processedFiles)
                if strcmp([pth,files(ii).name],old.processedFiles{jj})
                    oldIdx = jj;
                    found = 1;
                    disp('Already Processed, Loading...')
                    break
                end
            end
        else
            found = 0;
        end
        if found
            if ~isfield(old.tData(oldIdx),'usBlock')
                old.tData(oldIdx).usBlock = 40;
            elseif isempty(old.tData(oldIdx).usBlock)
                old.tData(oldIdx).usBlock = 40;
            end
            tData(curIdx) = old.tData(oldIdx);
            processedFiles{curIdx} = old.processedFiles{oldIdx};
            curIdx = curIdx+1;
        else
            try
                tData(curIdx) = processTaskDataDurable([pth,files(ii).name]);
                processedFiles{curIdx} = [pth,files(ii).name];
                curIdx = curIdx+1;
            catch me
                warning(['Loading of file:', files(ii).name, ' failed.']);
            end
        end
        found = 0;
    end
    save([pthP,'curData.mat'],'tData','processedFiles');
end

%% Find behavior over time
window = 300;
windowStep = 10;
tm = -window:windowStep:15*60;
ch = nan(length(tData),length(tm));
chZero = ch;
chZeroBaseline = nan(size(tData));
trTm = cell(length(tData));
for ii = 1:length(tData)
    disp(['Processsing Session: ', num2str(ii), ' of ', num2str(length(tData))])
    [~,ch(ii,:),chZero(ii,:),chZeroBaseline(ii),trTm{ii}] = drugDeliveryOverTime(tData(ii),tm,window,window);
    title(num2str(ii))
end

% Select relevant sessions
curLeft = 1;
curRight = 1;
curLeftS = 1;
curRightS = 1;

idxLeft = [];
idxRight = [];
idxLeftS = [];
idxRightS = [];

for ii = 1:length(tData)
    if tData(ii).sonicationProperties.FocalLocation(1)<0 && inj(ii) == 'p'
        idxLeft(curLeft) = ii;
        curLeft = curLeft+1;
    elseif tData(ii).sonicationProperties.FocalLocation(1)>0 && inj(ii) == 'p'
        idxRight(curRight) = ii;
        curRight = curRight+1;
    elseif tData(ii).sonicationProperties.FocalLocation(1)<0 && inj(ii) == 's'
        idxLeftS(curLeftS) = ii;
        curLeftS = curLeftS+1;
    elseif tData(ii).sonicationProperties.FocalLocation(1)>0 && inj(ii) == 's'
        idxRightS(curRightS) = ii;
        curRightS = curRightS+1;
    end
end
chZero = chZero-repmat(chZeroBaseline',[1,size(chZero,2)]);

%%
v2Plot = ch;
leftY = 100*mean(v2Plot(idxLeft,:),1,'omitnan');
leftYSem = 100*semOmitNan(v2Plot(idxLeft,:),1);

rightY = 100*mean(v2Plot(idxRight,:),1,'omitnan');
rightYSem = 100*semOmitNan(v2Plot(idxRight,:),1);

leftYS = 100*mean(v2Plot(idxLeftS,:),1,'omitnan');
leftYSemS = 100*semOmitNan(v2Plot(idxLeftS,:),1);

rightYS = 100*mean(v2Plot(idxRightS,:),1,'omitnan');
rightYSemS = 100*semOmitNan(v2Plot(idxRightS,:),1);

contraY = [-v2Plot(idxLeftS,:);v2Plot(idxRightS,:)];
contraYSem = 100*semOmitNan(contraY,1);
contraY = 100*mean(contraY,1,'omitnan');


h = figure;
hold on
ax = gca;
% shadedErrorBar(tm/60+window/60,leftY,leftYSem,'lineprops',{'Color',ax.ColorOrder(1,:),'linewidth',2});
% shadedErrorBar(tm/60+window/60,rightY,rightYSem,'lineprops',{'Color',ax.ColorOrder(2,:),'linewidth',2});
shadedErrorBar(tm/60+window/60,leftYS,leftYSemS,'lineprops',{'Color',ax.ColorOrder(3,:),'linewidth',2});
shadedErrorBar(tm/60+window/60,rightYS,rightYSemS,'lineprops',{'Color',ax.ColorOrder(4,:),'linewidth',2});
plot([window/60,window/60]+1,100*[-0.5,0.5],'k--')
xlabel('Time (minutes)')
ylabel('Leftward Choices (%)')
legend('Left P+','Right P+','Left P-', 'Right P-')
% axis([0,20,-20,20])
axis([0,20,20,80])
makeFigureBig(h)


h = figure;
hold on
ax = gca;
shadedErrorBar(tm/60+window/60,contraY,contraYSem,'lineprops',{'Color',ax.ColorOrder(2,:),'linewidth',2});
xlabel('Time (minutes)')
ylabel('\Delta Contralateral Choices (%)')
% legend('Left P+','Right P+','Left P-', 'Right P-')
% axis([0,20,-20,20])
makeFigureBig(h)

%%
% Plot individual Sessions
h = figure;
ax = gca;
hold on;
for ii = 1:length(idxLeft)
    ax.ColorOrderIndex = 1;
    plt(1) = plot(tm/60+window/60,v2Plot(idxLeft(ii),:),'--','linewidth',2);
end
for ii = 1:length(idxRight)
    ax.ColorOrderIndex = 2;
    plt(2) = plot(tm/60+window/60,v2Plot(idxRight(ii),:),'linewidth',2);
end
plot([window/60,window/60]+1,[-0.5,0.5],'k--')
legend(plt,'Left LGN', 'Right LGN');
makeFigureBig(h);
xlabel('Time (minutes)');
ylabel('Leftward Choices at PEP (%)')
%%
h = figure;
tmPt = -20;
leftB = 100*mean(chZeroBaseline(idxLeft));
leftP = (chZero(idxLeft,tm==tmPt));
leftPSem = 100*semOmitNan(chZero(idxLeft,tm==tmPt),1);

rightB = 100*mean(chZeroBaseline(idxRight));
rightP = (chZero(idxRight,tm==tmPt));
rightPSem = 100*semOmitNan(chZero(idxRight,tm==tmPt),1);

[~,p] = ttest2(rightP,leftP);

hold on;
ax = gca;
% bar(2:3,[100*mean(leftP),100*mean(rightP)],'BaseValue',mean([leftB,rightB]),'FaceColor',ax.ColorOrder(1,:),'EdgeColor',ax.ColorOrder(1,:));
bar(2:3,[100*mean(leftP,'omitnan'),100*mean(rightP,'omitnan')],'FaceColor',ax.ColorOrder(1,:),'EdgeColor',ax.ColorOrder(1,:));
eb = errorbar(2:3,[100*mean(leftP,'omitnan'),100*mean(rightP,'omitnan')],[leftPSem,rightPSem]);
set(eb,'linestyle','none','Color',ax.ColorOrder(1,:));
sigstar([2:3],p)
ax.XTick = 2:3;
ax.XTickLabel = {'Left LGN','Right LGN'};
ylabel('Leftward Choices at Delay = 0');
% axis([1,4,20,60])
makeFigureBig(h)
% bar(2:3,[leftB,leftP],'BaseValue',mean([leftB,rightB]),'FaceColor',ax.ColorOrder(1,:));
% bar(5:6,[rightB,rightP],'BaseValue',mean([leftB,rightB]),'FaceColor',ax.ColorOrder(2,:));