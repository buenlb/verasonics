idx1 = 1:length(tData);

wSize = 5*60;
wSkip = 30;
tWindows1 = -2*wSize:wSkip:20*60;
hGamma = nan(length(idx1),length(tWindows1));
gamma = hGamma;
for ii = 1:length(idx1)
    if isnan(timeOfSonication(ii))
        continue
    end

    featuresChannelsAveraged = nan(size(features{idx1(ii)},1)/2,size(features{idx1(ii)},2),2);
    featuresChannelsAveraged(:,:,1) = features{idx1(ii)}(1:length(frequencies),:);
    featuresChannelsAveraged(:,:,2) = features{idx1(ii)}(length(frequencies)+1:end,:);
    featuresChannelsAveraged = mean(featuresChannelsAveraged,3,'omitnan');
    
    tWindows = tWindows1+timeOfSonication(ii);

    cur_hGamma = mean(featuresChannelsAveraged(frequencies>70,:),1,'omitnan');
    cur_gamma = mean(featuresChannelsAveraged(frequencies>30 & frequencies<70,:),1,'omitnan');
    for jj = 1:length(tWindows)
        idx = find(tFeatures{idx1(ii)}>tWindows(jj)&tFeatures{idx1(ii)}<tWindows(jj)+wSize);
        if isempty(idx)
            continue
        else
            hGamma(ii,jj) = mean(cur_hGamma(idx),'omitnan');
            gamma(ii,jj) = mean(cur_gamma(idx),'omitnan');
        end
    end
end

%%

h = figure;
ax = gca;
plotVep(tWindows1/60+5,gamma([idxLeft,idxRight],:),1,ax,{'Color',ax.ColorOrder(1,:)})
hold on
plotVep(tWindows1/60+5,gamma(idxCtl,:),1,ax,{'Color',ax.ColorOrder(3,:)})
axis([-5,20,0,5e3])
makeFigureBig(h);

h = figure;
ax = gca;
plotVep(tWindows1/60+5,hGamma([idxLeft,idxRight],:),1,ax,{'Color',ax.ColorOrder(1,:)})
hold on
plotVep(tWindows1/60+5,hGamma(idxCtl,:),1,ax,{'Color',ax.ColorOrder(3,:)})
axis([-5,20,0,2e3])
makeFigureBig(h);
