function decoratefig(tickfontsize, labelfontsize)
% fix matlab ugly default figure
% example: decoratefig(25,35); cleans up the figure and sets larger fonts

set(gca, 'color', 'none', 'box', 'off');

fig = get(gcf,'position');
figx = fig(3);
figy = fig(4);

% set data as your example
Xt=get(gca, 'XTick');
Xtl=get(gca, 'XTickLabel');
Xtl_cell = cellstr(Xtl);
Yt=get(gca, 'YTick');
Ytl=get(gca, 'YTickLabel');
Ytl_cell = cellstr(Ytl);

fsl = 25;
fst{1} = 18;
fsa = 18;
if nargin > 0,
% fst = get(findobj('type','text'),'FontSize');
% fsa = get(findobj('type','axes'),'FontSize');
    fst{1} = tickfontsize;
    fsa = tickfontsize;
    fsl = tickfontsize;
end

if nargin > 1,
    fsl = labelfontsize;
end

% Reduce the size of the axis so that all the labels fit in the figure.
pos = get(gca,'Position');
set(gca,'Position',[pos(1), pos(2) + 0.025, pos(3) 0.975 * (pos(4))])

ax = axis; % Current axis limits
axis(axis); % Set the axis limit modes (e.g. XLimMode) to manual
Yl = ax(3:4); % Y-axis limits
Xl = ax(1:2);

% Remove the default labels
set(gca,'XTickLabel','');
set(gca,'YTickLabel','');

% Place the text labels -- the value of delta modifies how far the labels 
% are from the axis.
%X labels
percx = 0.04;
t{1} = text(Xt, Yl(1) * ones(1,length(Xt)) - percx * (Yl(2) - Yl(1)), Xtl_cell);
% set(t{1}, 'HorizontalAlignment','left','VerticalAlignment','top')
set(t{1}, 'HorizontalAlignment','center','VerticalAlignment','middle')

%Y labels
percy = 0.014;
t{2} = text(Xl(1)*ones(1,length(Yt))-percy*(Xl(2) - Xl(1)), Yt, Ytl_cell);
% set(t, 'HorizontalAlignment','left','VerticalAlignment','top')
set(t{2}, 'HorizontalAlignment','right','VerticalAlignment','middle')

%Xlabel
percxl = 2.2 * percx;
h = get(gca,'xlabel');
pos = get(h,'position');
ylimits = get(gca,'ylim');
pos(2) = ylimits(1) - percxl * (ylimits(2) - ylimits(1));
set(h,'position', pos)

%Ylabel
percyl = size(Ytl, 2) * 2.5 * percy;
h = get(gca,'ylabel');
pos = get(h,'position');
xlimits = get(gca,'xlim');
pos(1) = xlimits(1) - percyl * (xlimits(2) - xlimits(1));
set(h,'position', pos)



for tt = 1 : length(t),
    set(t{tt}, 'fontsize', fsa);
end

set(get(gca, 'xlabel'), 'fontsize' , fsl);
set(get(gca, 'ylabel'), 'fontsize' , fsl);

% and continue with your other settings as required
if ~isempty(fst),
    set(findobj('type','text'),'FontSize',fst{1});
end
%  set(gca,'FontSize',fsl);
%  set(findobj('type','axes'),'FontSize',fsa);
h=get(gca,'Title');
set(h,'FontSize',fsl);