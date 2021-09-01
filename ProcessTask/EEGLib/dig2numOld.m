function num = dig2numOld(t,dig)

bOn = find(diff(dig)>0);
bOff = find(diff(dig)<0);

num = round((t(bOff)-t(1))/3e-3);
num = sum(2.^(0:(num-2)));