function m = myCell2Mat(cl)
if ~isrow(cl) && ~iscolumn(cl)
    error('This only works for 1D cell arrays')
end

mxDim = 0;
for ii = 1:length(cl)
    if length(cl{ii})>mxDim
        mxDim = length(cl{ii});
    end
end

m = nan(length(cl),mxDim);
for ii = 1:length(cl)
    m(ii,1:length(cl{ii})) = cl{ii};
end