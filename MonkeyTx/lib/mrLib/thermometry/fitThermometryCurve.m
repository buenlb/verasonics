function [keepPoint, err] = fitThermometryCurve(t,T,firstDynamic,expectedPeakIdx)

if T(expectedPeakIdx) <= T(firstDynamic-1) || T(expectedPeakIdx) <= 0 || mean(T(expectedPeakIdx:expectedPeakIdx+2)) <= mean(T(1:firstDynamic)) || T(expectedPeakIdx+1) <=0
    keepPoint = false;
    err = inf;
    return
end

x = [t(firstDynamic:expectedPeakIdx)'-t(firstDynamic), ones(expectedPeakIdx-firstDynamic+1,1)];
y = log(T(firstDynamic:expectedPeakIdx));

b = (x'*x)\x'*y;
m = b(1);
rSquared = 1-sum((y-(m*x(:,1)+b(2))).^2)/sum((y-mean(y)).^2);

if m < 0
    keepPoint = false;
    err = inf;
    return
elseif rSquared < 0
    keepPoint = false;
    err = inf;
    return
else
    keepPoint = true;
    err = rSquared;
    return
end