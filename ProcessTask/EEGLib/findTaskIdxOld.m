function idx = findTaskIdxOld(t,dig)

dfDig = diff(dig);
idxOn = find(dfDig>0);
idxOff = find(dfDig<0);

idxOn2 = find(diff(t(idxOn))>200e-3);

taskIdx = 0;
checkThese = 2.^(1:15)-1;
for ii = 1:length(idxOn2)
    if ismember(ii-1,checkThese)
        tst = dig2numOld(t(idxOn(idxOn2(ii)):idxOn(idxOn2(ii))+100e-3*20e3),dig(idxOn(idxOn2(ii)):idxOn(idxOn2(ii))+100e-3*20e3));
        if tst ~= ii-1
            keyboard
        end
    end
    idx(ii) = idxOn(idxOn2(ii));
end