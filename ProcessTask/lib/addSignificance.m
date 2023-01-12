function p = addSignificance(y1,y2,x,h,sigValue)

if ~exist('sigValue','var')
    sigValue = 0.05;
end

figure(h)
hold on

idx = find(size(y1)==length(x));
if isempty(idx)
    error('One of the dimensions of y must equal the length of x')
end

if idx == 2
    y1 = y1';
    y2 = y2';
end

ax = gca;
ymax = max(ax.YLim);
ymin = min(ax.YLim);

dx = x(2)-x(1);
p = zeros(size(x));
for ii = 1:length(x)
    [~,p(ii)] = ttest2(y1(ii,:),y2(ii,:));
%     p(ii) = p(ii)/2;
    if p(ii)<=sigValue
        patch([x(ii)-dx/2,x(ii)-dx/2,x(ii)+dx/2,x(ii)+dx/2],...
            [ymin,ymax,ymax,ymin],'k','edgealpha',0.1,'facealpha',0.1);
    end
end