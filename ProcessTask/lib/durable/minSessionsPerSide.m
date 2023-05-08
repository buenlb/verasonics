function y = minSessionsPerSide(idxLeft,idxRight,y,threshold)
keepIdx = true(1,size(y,2));

keepIdx(sum(~isnan(y(idxLeft,:)),1)<threshold) = false;
keepIdx(sum(~isnan(y(idxRight,:)),1)<threshold) = false;

y([idxLeft,idxRight],~keepIdx) = nan;