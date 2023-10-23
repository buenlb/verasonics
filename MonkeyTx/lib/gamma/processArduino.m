function [num,idxNum,tNum] = processArduino(t,dig,bitWidth)
bOn = find(diff(dig)>0);

bitsRemain = 1;
curBitIdx = bOn(1);
maxBits = 9;
dt = t(2)-t(1);
ii = 1;
while bitsRemain
%     keyboard
    disp(['Processing bit ', num2str(ii)])
    curTime = t(curBitIdx:(curBitIdx+maxBits*(round(bitWidth/dt)+round(200e-6/dt))+1));
    curBit = dig(curBitIdx:(curBitIdx+maxBits*(round(bitWidth/dt)+round(200e-6/dt))+1));

    num(ii) = dig2num(curTime,curBit,bitWidth); %#ok<*AGROW> 
    
    idxNum(ii) = curBitIdx;
    tNum(ii) = t(curBitIdx);

    tmpIdx = find(t(bOn) > max(curTime));
    if isempty(tmpIdx)
        return
    end
    curBitIdx = bOn(tmpIdx(1));
    
    ii = ii+1;
end
