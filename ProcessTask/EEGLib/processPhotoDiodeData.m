function [sFiltered,delay] = processPhotoDiodeData(s)

%% Filter
hp = 1;
lp = 20;
wp = [0 hp lp 50];
mags = [0,1,0];
devs = [0.2 0.1 0.2];
[n,wn,beta,fType] = kaiserord(wp,mags,devs,20e3);
n = n+rem(n,2);
myFilt = fir1(n,wn,fType,kaiser(n+1,beta),'scale');
delay = mean(grpdelay(myFilt,size(s,2),20e3));

sFiltered = zeros(size(s));
for ii = 1:2
    curS = filter(myFilt,1,s(ii,:));
    curS = curS(delay+1:end);
    sFiltered(ii,1:length(curS)) = curS;
end
