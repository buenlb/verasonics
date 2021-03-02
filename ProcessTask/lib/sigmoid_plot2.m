function [slope, bias, downshift, scale, y, x] = sigmoid_plot2(xdat, ydat, ics, color, params2fit)
%fit a sigmoid to y vs x for ics ics

if isempty(ics)
    ics = 1 : length(xdat);
end

global x;
global y;

xdat = xdat(ics);
ydat = ydat(ics);

% x = unique(xdat);
% x = x(~isnan(x));
x = unique(xdat);
y = [];
sem = [];
datcell = {}; %debug
for k = 1 : length(x)
    datcell{k} = ydat(xdat == x(k));
    y(k) = nanmean(ydat(xdat == x(k)));
    sem(k) = nansem(ydat(xdat == x(k)));
end
LW = 3;
% errorbar(x, y, sem, 'color', color, 'linewidth', LW, 'linestyle', 'none');

h = errorbar(x, y, sem, '.', 'color', color);
h.Color = color;
h.LineWidth = 1;
h.MarkerSize = 30;

% h = plot(x, y, '.', 'color', color);
% h.Color = color;
% h.LineWidth = 1;
% h.MarkerSize = 30;


% hold on; plot(x,sy, 'color', color, 'linewidth', LW); hold on;
% shadedErrorBar(x, y, sem, {'color', color});

y = [];
slope = [];
bias = [];
downshift = [];
scale = [];
for it = 1 : 1,
    for k = 1 : length(x),
        data = ydat(xdat == x(k));
%         y(k) = nanmean(datasample(data, length(data))); %sample with replacement
        y(k) = nanmean(data);
    end
    
    nics = isnan(y);
    y(nics) = [];
    x(nics) = [];
    
    fminsearchopt = optimset('LargeScale', 'off', 'Display', 'off', 'MaxFunEvals', 40000, 'MaxIter', 20000);
    slope0 = 0.05;
    bias0 = 5;
    downshift0 = 0.2;
    scale0 = 0.8;

    switch params2fit,
        case 2
            X0 = [slope0, bias0]; %starting value for the optimization
            [Xstar, FVAL, EXITFLAG, OUTPUT] = fminsearch('modelSigmoid', X0, fminsearchopt);
            slope(it) = Xstar(1);
            bias(it) = Xstar(2);
        case 4,
            X0 = [slope0, bias0, downshift0, scale0]; %starting value for the optimization
            [Xstar, FVAL, EXITFLAG, OUTPUT] = fminsearch('modelSigmoid_ext', X0, fminsearchopt);
            slope(it) = Xstar(1);
            bias(it) = Xstar(2);
            downshift(it) = Xstar(3);
            scale(it) = Xstar(4);
    end
end

%set(gcf, 'position', [488   237   568   490]);
set(gcf, 'position', [488   237   568   260]);


hold on;
finex = min(x) : (max(x) - min(x)) / 100 : max(x);
%plot(finex, sigmoid(finex, mean(slope), mean(bias)), 'color', color, 'linewidth', 2);
plot(finex, sigmoid_ext(finex, mean(slope), mean(bias), mean(downshift), mean(scale)), 'color', color, 'linewidth', 3);

% downshift = 0;
% scale = 1;
% plot(x, sigmoid_ext(x, -mean(slope), mean(bias), mean(downshift), mean(scale)), [color, '--']);

% errorbar(x, mean(ypoints, 1), jannansem(ypoints), 'color', color, 'linewidth', LW2, 'linestyle', 'none');

hold on;
LW = 3;
% x = min(x) : 1 : max(x);
% plot(x, sigmoid(x, -mean(slope), mean(bias)), 'color', color, 'linewidth', LW);
% plot(x, sigmoid(x, -mean(slope), prctile(bias, 95)), [color, '-']);
% plot(x, sigmoid(x, -mean(slope), prctile(bias, 5)), [color, '-']);

%cosmetics
% XL = 80;
% XLT = 80;
XL1 = min(x);
XL2 = max(x);
xtv = XL1 : (XL2 - XL1) / 4 : XL2;
%xtv = [-80, -40, 0, 40, 80];
set(gca, 'color', 'none', 'box', 'off', 'ytick', 0 : .25 : 1, 'yticklabel', 0 : 25 : 100, 'xtick', xtv, 'xticklabel', xtv, 'fontsize', 16);
xlim([XL1 - abs(XL2 - XL1) / 20, XL2 + abs(XL2 - XL1) / 20]);

%xl = [-20:40:140];
%xl = [-60:40:100];
%xticks(xl);
%xticklabels(xl);

ylim([0 1]);

% t(1)=xlabel('Difference in target onset times (ms)');
% t(2)=ylabel(sprintf('Rightward choices (%c)', '%'));
% for tt=1:2,
%     set(t(tt), 'fontsize', 20);
% end

decoratefig;