function [sessionAvg,cChoices,lLgn,rLgn,ctl] = plotContraChoices(tData,varargin)

if isempty(tData)
    sessionAvg = nan;
    cChoices = nan;
    lLgn = nan;
    rLgn = nan;
    ctl = nan;
    return
end

validDelays = [];
validIndex = [];
if exist('varargin','var')
    skip = 0;
    for ii = 1:length(varargin)
        if skip
            skip = 0;
            continue
        end
        switch varargin{ii}
            case 'xlabels'
                xlabels = varargin{ii+1};
                skip = 1;
            case 'yaxis'
                yrange = varargin{ii+1};
                skip = 1;
            case 'delays'
                validDelays = varargin{ii+1};
                skip = 1;
            case 'index'
                validIndex = varargin{ii+1};
                skip = 1;
            otherwise
                error([varargin{ii}, ' is not a valid property.'])
        end
    end
end

h = figure;
hold on;
ax = gca;
cChoices = cell(1,length(tData));
sessionAvg = zeros(1,length(tData));
lLgn = zeros(size(tData));
rLgn = lLgn;
ctl = rLgn;
for ii = 1:length(tData)
    curT = tData(ii);
    
    if ~isempty(validDelays)
        curT.ch(~ismember(curT.delay,validDelays)) = nan;
    end
    
    if ~isempty(validIndex)
        tmp = false(size(curT.ch));
        if max(validIndex{ii})>length(curT.ch)
            warning('Valid Index contains entries outside of the current session');
        end
        tmp(validIndex{ii}) = true;
        curT.ch(~tmp) = nan;
    end
    
    curT.ch(~curT.correctDelay) = nan;

    correctContra = sum(~isnan(curT.ch) & ((curT.lgn == -1 & curT.delay < 0) | (curT.lgn == 1 & curT.delay > 0)));
    correctIntra = sum(~isnan(curT.ch) & ((curT.lgn == -1 & curT.delay > 0) | (curT.lgn == 1 & curT.delay < 0)));
    if correctContra < correctIntra
        idx = find(~isnan(curT.ch) & ((curT.lgn == -1 & curT.delay > 0) | (curT.lgn == 1 & curT.delay < 0)));
        curT.ch(idx(1:(correctIntra-correctContra))) = nan;
    elseif correctContra > correctIntra
        idx = find(~isnan(curT.ch) & ((curT.lgn == -1 & curT.delay < 0) | (curT.lgn == 1 & curT.delay > 0)));
        curT.ch(idx(1:(correctContra-correctIntra))) = nan;
    end
    
    contraChoices = zeros(size(curT.ch));
    contraChoices((curT.lgn == 1 & curT.ch == 1) | (curT.lgn == -1 & curT.ch == 0)) = 1;
    contraChoices(isnan(curT.ch)) = nan;
    contraChoices(curT.lgn==0) = nan;
%     contraChoices(abs(curT.delay)>0) = nan;
    contraChoices(curT.task==1) = nan;

    erBar = errorbar(1+ii,mean(contraChoices,'omitnan')*100-50,100/sqrt(sum(~isnan(contraChoices)))*std(contraChoices,[],'omitnan'));
    erBar.Color = [0,0,0];
    erBar.LineStyle = 'none';
    ax.ColorOrderIndex = ii;
    bar(1+ii,mean(contraChoices,'omitnan')*100-50)
    
    correctContra = sum(~isnan(curT.ch) & ((curT.lgn == -1 & curT.delay < 0) | (curT.lgn == 1 & curT.delay > 0)));
    correctIntra = sum(~isnan(curT.ch) & ((curT.lgn == -1 & curT.delay > 0) | (curT.lgn == 1 & curT.delay < 0)));
    if correctContra ~= correctIntra
        keyboard
    end
    
    cChoices{ii} = contraChoices(~isnan(contraChoices));
    sessionAvg(ii) = mean(contraChoices,'omitnan');
    if isnan(sessionAvg(ii))
        keyboard
    end
    
    lLgn(ii) = mean(curT.ch(~isnan(curT.ch) & curT.lgn==-1 & curT.task==0));
    rLgn(ii) = mean(curT.ch(~isnan(curT.ch) & curT.lgn==1 & curT.task==0));
    ctl(ii) = mean(curT.ch(~isnan(curT.ch) & curT.lgn==0 & curT.task==0));
end

curIdx = 1;
for ii = 1:length(tData)
    for jj = 1:length(tData)
        if isempty(cChoices{ii}) || isempty(cChoices{jj})
            continue
        end
        if ii==jj
            intervals{curIdx} = ii+1;
            
            [~,p(curIdx)] = ttest(cChoices{ii},0.5);
            curIdx = curIdx+1;
        elseif jj < ii
            intervals{curIdx} = [jj+1,ii+1];
            [~,p(curIdx)] = ttest2(cChoices{jj},cChoices{ii});
            curIdx = curIdx+1;
        end
    end
end
intervals = intervals(p<0.05);
p = p(p<0.05);
sigstar(intervals,p)

if exist('xlabels','var')
    ax.XTick = 2:(length(tData)+1);
    ax.XTickLabel = xlabels;
    xtickangle(90);
end

if exist('yrange','var')
    ax.YLim = yrange-50;
end

ylabel('% Contralateral Choices')
makeFigureBig(h);
for ii = 1:length(ax.YTickLabel)
    ax.YTickLabel{ii} = num2str(str2double(ax.YTickLabel{ii})+50);
end