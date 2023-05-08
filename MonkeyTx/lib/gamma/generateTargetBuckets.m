function foci = generateTargetBuckets(focalLocation,nFoci,focalDev)
foci = cell(nFoci);
x = generateParameterDev(focalLocation(1),nFoci(1),focalDev(1));
y = generateParameterDev(focalLocation(2),nFoci(2),focalDev(2));
z = generateParameterDev(focalLocation(3),nFoci(3),focalDev(3));
for ii = 1:nFoci(1)
    for jj = 1:nFoci(2)
        for kk = 1:nFoci(3)
            foci{ii,jj,kk} = [x(ii),y(jj),z(kk)];
        end
    end
end