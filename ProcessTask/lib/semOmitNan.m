function s = semOmitNan(v,dim)
if ~exist('dim','var')
    dim = 1;
end

if length(size(v))>2
    error('I haven''t implemented more than two dimensions')
elseif ~isrow(v) && ~iscolumn(v)
    s = std(v,[],dim,'omitnan');
    n = sum(~isnan(v),dim);
    s = s./sqrt(n);
else
    s = std(v,[],dim,'omitnan')/sqrt(sum(~isnan(v)));
end