function plotElementLocation(ax,loc,width,elements)
axes(ax)
xLim = ax.XLim;
yLim = ax.YLim;
hold on
x = linspace(loc(1),loc(1)+width,32);
ax.Units = 'Inches';
pos = ax.Position;
height = (diff(yLim)/diff(xLim))*(pos(3)/pos(4))*width;
y = linspace(loc(2),loc(2)+height,8);

for ii = 1:8
    for jj = 1:32
        elNo = (jj-1)*8+ii;
        if ismember(elNo,elements)
            plot(x(jj),y(ii),'sr','markersize',4);
        else
            plot(x(jj),y(ii),'sk','markersize',4);
        end
    end
end

txt = text(x(15),y(1)-(y(2)-y(1)),'x->');
set(txt,'FontWeight','Bold')
txt = text(x(1)-2*(x(2)-x(1)),y(2),'y->');
set(txt,'Rotation',90);
set(txt,'FontWeight','Bold')

ax.XLim = xLim;
ax.YLim = yLim;