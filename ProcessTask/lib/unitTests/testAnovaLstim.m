function testAnovaLstim(data,band,lgn,mField,subject,bnd,dc,magnet,monkey)
bnd = bnd(dc==50,:);

idx = find(dc==50 & magnet == 1);
idx2 = find(dc==50 & magnet == 0);
tmp = nan(length(idx),size(bnd(1).shortWindow.bndDuring,2));
tmp2 = nan(length(idx2),size(bnd(1).shortWindow.bndDuring,2));
for ii = 1:length(idx)
    tmp(ii,:) = mean(bnd(idx(ii),3).shortWindow.bndDuring(1:2:end,:),1,'omitnan')/mean(bnd(idx(ii),3).shortWindow.bndDuring(1:2:end,1),'omitnan');
    tmp2(ii,:) = mean(bnd(idx2(ii),3).shortWindow.bndDuring(1:2:end,:),1,'omitnan')/mean(bnd(idx2(ii),3).shortWindow.bndDuring(1:2:end,1),'omitnan');
end
tm = 1:size(tmp,2);
h = figure;
shadedErrorBar(tm,mean(tmp,1),semOmitNan(tmp,1),'lineprops',{'linewidth',2})
shadedErrorBar(tm,mean(tmp2,1),semOmitNan(tmp2,1),'lineprops',{'linewidth',2})
