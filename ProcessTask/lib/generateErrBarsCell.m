function generateErrBarsCell(sessions,varargin)
%#ok<*AGROW>

skip = 0;
for ii = 1:nargin-1
    if skip
        skip = 0;
        continue
    end
    switch varargin{ii}
        case 'xlabels'
            xlabels = varargin{ii+1};
            skip = 1;
        case 'compareTo'
            compareTo = varargin{ii+1};
            skip = 1; 
        case 'yaxis'
            yrange = varargin{ii+1};
            skip = 1;
        case 'barColors'
            barColors = varargin{ii+1};
            skip = 1;
        case 'nsessions'
            nSessions = varargin{ii+1};
            skip = 1;
        otherwise
            error([varargin{ii}, ' is not a valid property.'])
    end
end

if ~exist('nSessions','var')
    nSessions = 0;
end

curIdx = 1;
for ii = 1:size(sessions,1)
    for jj = 1:size(sessions,2)
        avgs(curIdx) = mean(sessions{ii,jj});
        sems(curIdx) = std(sessions{ii,jj})/sqrt(length(sessions{ii,jj}));
        inputIdx{curIdx} = [ii,jj];
        curIdx = curIdx+1;
    end
%     avgs(curIdx) = nan;
%     sems(curIdx) = nan;
    curIdx = curIdx+1;
end

if exist('barColors','var')
    if length(avgs) ~= size(barColors,1)
        keyboard
        error('Number of barColors must equal number of averages');
    end
end

if ~exist('compareTo','var')
    compareTo = 0;
end

curIdx = 1;
for ii = 1:length(avgs)
    for jj = 1:length(avgs)
        if isnan(avgs(ii)) || isnan(avgs(jj))
            continue
        end
        if ii == jj
            [~,p(curIdx)] = ttest(sessions{inputIdx{ii}(1),inputIdx{jj}(2)},compareTo);
            intervals{curIdx} = ii;
            curIdx = curIdx+1;
        elseif jj < ii
            [~,p(curIdx)] = ttest2(sessions{inputIdx{ii}(1),inputIdx{ii}(2)},sessions{inputIdx{jj}(1),inputIdx{jj}(2)});
            intervals{curIdx} = [jj,ii];
            curIdx = curIdx+1;
        end
    end
end
intervals = intervals(p<0.05);
p = p(p<0.05);

h = figure;
hold on
ax = gca;
% Loop through to get different colors
for ii = 1:length(avgs)
    eb = errorbar(ii,avgs(ii)-compareTo,sems(ii));
    set(eb,'linestyle','none','Color','k');
    ax.ColorOrderIndex = ii;
    b = bar(ii,avgs(ii)-compareTo);
    if exist('barColors','var')
        b.FaceColor = barColors(ii,:);
    end
end
if exist('xlabels','var')
    ax.XTick = 1:length(avgs);
    curIdx = 1;
    for ii = 1:size(sessions,1)
        for jj = 1:size(sessions,2)
            newXlabel{curIdx} = xlabels{ii,jj};
            curIdx = curIdx+1;
        end
        newXlabel{curIdx} = '';
        curIdx = curIdx+1;
    end
    ax.XTickLabel = newXlabel;
    xtickangle(90);
end

if exist('yrange','var')
    ax.YLim = yrange-compareTo;
end

sigstar(intervals,p);
makeFigureBig(h);

if compareTo
    for ii = 1:length(ax.YTickLabel)
        ax.YTickLabel{ii} = num2str(str2double(ax.YTickLabel{ii})+compareTo);
    end
end

if nSessions
    curIdx = 1;
    for ii = 1:size(sessions,1)
        for jj = 1:size(sessions,2)
            if isnan(sessions{ii,jj})
                curIdx = curIdx+1;
                continue;
            else
                text(curIdx-0.25,min(ax.YLim)+diff(ax.YLim)/8,['n=', num2str(length(sessions{ii,jj}))],'FontSize',14)
                curIdx = curIdx+1;
            end
        end
        curIdx = curIdx+1;
    end
end