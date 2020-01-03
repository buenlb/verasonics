function [COMx,COMy] = find2Dcenter(data)

data2 = data.data < min(min(data.data))/2;
for ii=1:length(data.x)
    for jj=1:length(data.y)
    data_ii = data2(ii,jj);
    weightedValx(ii,jj) = data2(ii,jj)*data.x(ii);
    weightedValy(ii,jj) = data2(ii,jj)*data.y(jj);
    end
end
COMx = -1*sum(sum(weightedValx))./sum(sum(data2));
COMy = -1*sum(sum(weightedValy))./sum(sum(data2));

