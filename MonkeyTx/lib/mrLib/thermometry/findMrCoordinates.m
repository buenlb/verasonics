function [x,y,z,res,dimOrder] = findMrCoordinates(header)

if ~strcmp(header{1}.PatientPosition,'HFP')
    error(['This system assumes a head first prone position but PatientPosition is ', header{1}.PatientPosition])
end
row = double(header{1}.ImageOrientationPatient(1:3));
col = double(header{1}.ImageOrientationPatient(4:6));

% Close enough to non-oblique is close enough
if sum(abs(row))-1>1e-6
    keyboard
    error('Oblique images not yet implemented!')
elseif sum(abs(col))-1>1e-6
    keyboard
    error('Oblique images not yet implemented!')
end
col(abs(col)<1e-6) = 0;
row(abs(row)<1e-6) = 0;

% Whichever dimension is not a row or column is the slice dimension
tmp = [1,2,3];
sliceDim = tmp(~(row|col));

res = zeros(1,3);
res(sliceDim) = header{1}.SliceThickness;

pos = double(header{1}.ImagePositionPatient);
nRows = double(header{1}.Rows);
nCols = double(header{1}.Columns);

if row(1)
    res(1) = double(header{1}.PixelSpacing(2));
    x = linspace(pos(1),pos(1)+row(1)*res(1)*(nCols-1),nCols);
    xDim = 2;
elseif row(2)
    res(2) = double(header{1}.PixelSpacing(2));
    y = linspace(pos(2),pos(2)+row(2)*res(2)*(nCols-1),nCols);
    yDim = 2;
else
    res(3) = double(header{1}.PixelSpacing(2));
    z = linspace(pos(3),pos(3)+row(3)*res(3)*(nCols-1),nCols);
    zDim = 2;
end

if col(1)
    res(1) = double(header{1}.PixelSpacing(1));
    x = linspace(pos(1),pos(1)+col(1)*res(1)*(nRows-1),nRows);
    xDim = 1;
elseif col(2)
    res(2) = double(header{1}.PixelSpacing(1));
    y = linspace(pos(2),pos(2)+col(2)*res(2)*(nRows-1),nRows);
    yDim = 1;
else
    res(3) = double(header{1}.PixelSpacing(1));
    z = linspace(pos(3),pos(3)+col(3)*res(3)*(nRows-1),nRows);
    zDim = 1;
end

if length(header) > 1
    sgn = sign(double(header{2}.SliceLocation)-double(header{1}.SliceLocation));
    if sliceDim == 1
        x = linspace(pos(1),pos(1)+sgn*res(1)*(length(header)-1),length(header));
        xDim = 3;
    elseif sliceDim == 2
        y = linspace(pos(2),pos(2)+sgn*res(2)*(length(header)-1),length(header));
        yDim = 3;
    else
        z = linspace(pos(3),pos(3)+sgn*res(3)*(length(header)-1),length(header));
        zDim = 3;
    end
else
    if sliceDim == 1
        x = pos(1);
    elseif sliceDim == 2
        y = pos(2);
    else
        z = pos(3);
    end
end

dimOrder = [xDim,yDim,zDim];