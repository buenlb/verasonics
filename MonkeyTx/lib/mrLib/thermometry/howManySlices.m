function nSlices = howManySlices(header)
sliceLocs = [];
curLoc = header{1}.SliceLocation;
idx = 1;
while ~ismember(curLoc,sliceLocs)
    sliceLocs(idx) = curLoc;
    idx = idx+1;
    curLoc = header{idx}.SliceLocation;
end
nSlices = length(sliceLocs);