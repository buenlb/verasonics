% Plot the spectra for specific table entries
function h = plotSpectraSpecificParams(tableIds,ts,tEntries,fftX,avgTimes,h)
if ~exist('h','var')
    h = figure;
end
if isempty(h)
    h = figure;
end
% tableIds = [12,8,11,21,22,17];

curBands = [];
tmp = 0;
for ii = 1:length(tableIds)
    curBands = cat(3,curBands,ts(:,:,tEntries==tableIds(ii)));
end

dth = [0.5,8];
alpha = [8,14];
beta = [14,30];
gamma = [30,70];
hg = [70,200];

% bands = {alpha,beta,gamma,hg};
% bandLabels = {'Alpha','Beta','Gamma','High Gamma'};
bands = {gamma};
bandLabels = {'Gamma'};

bndIdx = cell(size(bandLabels));
for ii = 1:length(bands)
    bndIdx{ii} = find(fftX>=bands{ii}(1) & fftX<bands{ii}(2));
end

figure(h);
ax = gca;
hold on;
for ii = 1:length(bands)
    curSp = squeeze(mean(curBands(bndIdx{ii},:,:),1,'omitnan'));
    eb = semOmitNan(curSp,2);
    curSp = mean(curSp,2,'omitnan');

    shadedErrorBar(avgTimes,curSp,eb,'lineprops',{'Color',ax.ColorOrder(ax.ColorOrderIndex,:)})
end
xlabel('Time (s)');
ylabel('Percent Change');
legend(bandLabels,'location','southeast');
ax.XLim = [0,max(avgTimes)];
makeFigureBig(h);