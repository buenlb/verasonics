function num = dig2num(t,dig)

bOn = find(diff(dig)>0);
bOff = find(diff(dig)<0);

if length(bOn)~=length(bOff)
    keyboard
    error('Number of ons not equal to number of offs!')
end

binNum = [];
for ii = 1:length(bOn)
    nOnes(ii) = round((t(bOff(ii))-t(bOn(ii)))/3e-3);
    if ii < length(bOn)
        nZeros(ii) = round((t(bOn(ii+1))-t(bOff(ii)))/3e-3);
        binNum = cat(2,binNum,[ones(1,nOnes(ii)),zeros(1,nZeros(ii))]);
    else
        binNum = cat(2,binNum,ones(1,nOnes(ii)));
    end
end
num = bin2dec(num2str(binNum(2:end-1)));
