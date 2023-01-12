function [z,zSem] = zscore_omitnan(x,dimSessions)

if max(imag(x(:))>1e-10)
    error('Imaginary x!')
end
x = real(x);

if length(size(x))>2
    error('expected matrix')
end
if dimSessions~= 1 && dimSessions~=2
    error('dimSessions must be either 1 or 2')
end
if dimSessions == 1
    dimTime = 2;
else
    dimTime = 1;
end
m = mean(x,dimTime,'omitnan');
s = std(x,[],dimTime,'omitnan');
if dimSessions == 1
    m = repmat(m,[1,size(x,dimTime)]);
    s = repmat(s,[1,size(x,dimTime)]);
else
    m = repmat(m,[size(x,dimTime),1]);
    s = repmat(s,[size(x,dimTime),1]);
end

z = (x-m)./s;
zSem = semOmitNan(z,dimSessions);
z = mean(z,dimSessions,'omitnan');
