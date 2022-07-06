function z = zscore_omitnan(x,m)

if ~exist('m','var')
    m = mean(x,'omitnan');
end
z = (x-m)/std(x,[],'omitnan');