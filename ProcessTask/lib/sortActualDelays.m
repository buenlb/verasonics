function delays = sortActualDelays(tData)

totAd = [];
for ii = 1:length(tData)
    ad = unique(round(tData(ii).actualDelay).*sign(tData(ii).delay));
    ad = ad(~isnan(ad));
    
    difAd = [10;diff(ad)];
    ad = ad(difAd>1e3/240);
    
    totAd = [totAd,;ad];
end
delays = unique(totAd);

difAd = [10;diff(delays)];
delays = delays(difAd>1e3/240);