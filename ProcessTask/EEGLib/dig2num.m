function num = dig2num(t,dig,bitWidth)
bOn = find(diff(dig)>0);
bOff = find(diff(dig)<0);

if length(bOn)~=length(bOff)
    warning('Number of ons not equal to number of offs!')
    num = nan;
    return
end

binNum = [];
for ii = 1:length(bOn)
    nOnes(ii) = floor((t(bOff(ii))-t(bOn(ii)))/bitWidth);
    if ii < length(bOn)
        nZeros(ii) = floor((t(bOn(ii+1))-t(bOff(ii)))/bitWidth);
        binNum = cat(2,binNum,[ones(1,nOnes(ii)),zeros(1,nZeros(ii))]);
    else
        binNum = cat(2,binNum,ones(1,nOnes(ii)));
    end
end
num = bin2dec(num2str(binNum(2:end-1)));

if isempty(num)
    num = nan;
end