locs = unique(tData.leftLocation,'rows');
% locs = locs(locs(:,3)<58,:);
locsLeft = locs;

idxLeft = cell(1,size(locs,1));
for ii = 1:size(locs,1)
    idxLeft{ii} = find(tData.leftLocation(:,1)==locs(ii,1)&tData.leftLocation(:,2)==locs(ii,2)...
        &tData.leftLocation(:,3)==locs(ii,3) & tData.lgn == -1 & tData.delay==0);
end

locs = unique(tData.rightLocation,'rows');
% locs = locs(locs(:,3)<58,:);
locsRight = locs;

idxRight = cell(1,size(locs,1));
for ii = 1:size(locs,1)
    idxRight{ii} = find(tData.rightLocation(:,1)==locs(ii,1)&tData.rightLocation(:,2)==locs(ii,2)...
        &tData.rightLocation(:,3)==locs(ii,3) & tData.lgn == 1 & tData.delay==0);
end

chLeft = zeros(size(idxLeft));
chLeftStd = zeros(size(idxLeft));
chLeftCell = cell(size(idxLeft));
xLabelsLeft = chLeftCell;
for ii = 1:length(idxLeft)
    chLeft(ii) = mean(tData.ch(idxLeft{ii}),'omitnan');
    chLeftStd(ii) = std(tData.ch(idxLeft{ii}),[],'omitnan');

    chLeftCell{ii} = tData.ch(idxLeft{ii});
    chLeftCell{ii} = chLeftCell{ii}(~isnan(chLeftCell{ii}));

    xLabelsLeft{ii} = ['<',num2str(locsLeft(ii,1)),',',num2str(locsLeft(ii,2)),',',num2str(locsLeft(ii,3)),'>'];
end

chRight = zeros(size(idxRight));
chRightStd = zeros(size(idxRight));
chRightCell = cell(size(idxLeft));
xLabelsRight = chLeftCell;
for ii = 1:length(idxRight)
    chRight(ii) = mean(tData.ch(idxRight{ii}),'omitnan');
    chRightStd(ii) = std(tData.ch(idxRight{ii}),[],'omitnan');

    chRightCell{ii} = tData.ch(idxRight{ii});
    chRightCell{ii} = chRightCell{ii}(~isnan(chRightCell{ii}));
    
    xLabelsRight{ii} = ['<',num2str(locsRight(ii,1)),',',num2str(locsRight(ii,2)),',',num2str(locsRight(ii,3)),'>'];
end

chC = tData.ch(tData.lgn==0&tData.delay==0);
figure;
ax = gca;
c1 = ax.ColorOrder(1,:);
c2 = ax.ColorOrder(2,:);
c = [repmat(c1,[size(locsLeft,1),1]);repmat(c2,[size(locsLeft,1),1])];
generateErrBarsCell([chLeftCell,chRightCell],'xlabels',[xLabelsLeft,xLabelsRight],...
    'compareTo',0*mean(chC,'omitnan'),'barColors',c,'nsessions',1)
