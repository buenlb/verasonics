function newAx = plotElementLocation2(ax1,axSize,elementNo,mkSize)
if nargin < 4
    mkSize = 2;
end
newPos = [ax1.Position(1)+(1-axSize(1))*ax1.Position(3),...
            ax1.Position(2)+(1-axSize(2))*ax1.Position(4),...
            axSize(1)*ax1.Position(3),...
            axSize(2)*ax1.Position(4)];
newAx = axes('Position',newPos,'Visible','Off');
hold on;
x = linspace(-1,1,32);
y = linspace(-1,1,8);
y = y(end:-1:1);
for ii = 1:length(x)
    for jj = 1:length(y)
        elNo = (ii-1)*8+jj;
        if ismember(elNo,abs(elementNo))
            if elementNo(abs(elementNo) == elNo) > 0
                plot(x(ii),y(jj),'sr','markersize',mkSize);
            else
                plot(x(ii),y(jj),'sg','markersize',mkSize);
            end
        else
            plot(x(ii),y(jj),'sk','markersize',mkSize);
        end
    end
end

axis([-1.2,1.2,-1.2,1.2]);