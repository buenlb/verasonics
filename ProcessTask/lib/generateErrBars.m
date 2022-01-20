function generateErrBars(varargin)
%#ok<*AGROW>

curIdx = 1;
skip = 0;
for ii = 1:nargin
    if skip
        skip = 0;
        continue
    end
    if ~isnumeric(varargin{ii})
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
            otherwise
                keyboard
                error([varargin{ii}, ' is not a valid property.'])
        end
    else
        skip = 0;
        avgs(curIdx) = mean(varargin{ii});
        sems(curIdx) = std(varargin{ii})/sqrt(length(varargin{ii}));
        inputIdx(curIdx) = ii;
        curIdx = curIdx+1;
    end
end

if exist('barColors','var')
    if length(avgs) ~= size(barColors,1)
        error('Number of barColors must equal number of averages');
    end
end

if ~exist('compareTo','var')
    compareTo = 0;
end

curIdx = 1;
for ii = 1:length(avgs)
    for jj = 1:length(avgs)
        if ii == jj
            [~,p(curIdx)] = ttest(varargin{inputIdx(ii)},compareTo);
            intervals{curIdx} = ii;
            curIdx = curIdx+1;
        elseif jj < ii
            [~,p(curIdx)] = ttest2(varargin{inputIdx(ii)},varargin{inputIdx(jj)});
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
    ax.XTickLabel = xlabels;
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