% Uses three fiducials to find the transducer and estimate its angle. Used
% to register the ultrasound coordinates to the MR coordinates.
% 
% @INPUTS
%   img: 3D image data containing MR image of the transducer and fiducials
%   res: resolution of x, y, and z axes of img (in index order)
%   x0: Initial estimate of transducer position (index into img)
% 
% @OUTPUTS
%   txCenter: Final estimate of transducer center (index into img)
%   theta: angle between the transducers x-axis and the MRI x-axis
% 
% Taylor Webb
% University of Utah
% April 2020
function [txCenter,theta] = findTx(img,res,x0)
%% Fiducial characteristics (locations relative to center of transducer)
xDist = (169/2)*1e-3;
yDist = (35/2)*1e-3;
zDist = 9.53e-3;

%% Get template
fd = createFiducialTemplate(xDist,yDist,zDist,res,'vitE');

%% Find transducer

% Search space based on x0
searchDim = 1e-2;
maxPlane = x0(3)+round(searchDim/res(3))+ceil(size(fd,3)/2)+round(9.03e-3/res(3));
minPlane = x0(3)-(round(searchDim/res(3))+ceil(size(fd,3)/2))+round(9.03e-3/res(3));
zSearch = minPlane:maxPlane;
zSearch = zSearch(zSearch>0);
zSearch = zSearch(zSearch<=size(img,3));

expectedLocationsX = [x0(1)-round(xDist/res(1)),x0(1)+round(xDist/res(1)),x0(1)+round(xDist/res(1))];
expectedLocationsY = [x0(2),x0(2)+round(yDist/res(2)),x0(2)-round(yDist/res(2))];

% Search for individual fiducials in a restricted search space defined as a
% 1 cm square space (in xy) and everything up to maxPlane in z around where
% they are expected given x0
fidLoc = zeros(length(expectedLocationsX),3);
err = zeros(1,length(expectedLocationsX));
d = waitbar(0,'Auto Locating Transducer');
for ii = 1:length(expectedLocationsX)
    waitbar((ii-1)/length(expectedLocationsX),d);
    disp(['Finding fiducial ', num2str(ii)]);
    xSearch = (expectedLocationsX(ii)-(round(searchDim/res(1))+size(fd,1))):(expectedLocationsX(ii)+round(searchDim/res(1))+size(fd,1));
    xSearch = xSearch(xSearch>0);
    xSearch = xSearch(xSearch<=size(img,1));
    
    ySearch = (expectedLocationsY(ii)-(round(searchDim/res(2))+size(fd,2))):(expectedLocationsY(ii)+round(searchDim/res(2))+size(fd,2));
    ySearch = ySearch(ySearch>0);
    ySearch = ySearch(ySearch<=size(img,2));
    
    [result,lags] = xcorr3(img(xSearch,ySearch,zSearch),fd);
    
    [~,idx] = max(result(:)); % The 3D "beginning" of the pattern
    % Add indices to get to the "center" of the pattern.
    fidLoc(ii,1) = xSearch(lags{idx}(1))+floor(size(fd,1)/2);
    fidLoc(ii,2) = ySearch(lags{idx}(2))+floor(size(fd,2)/2);
    fidLoc(ii,3) = zSearch(lags{idx}(3))+floor(size(fd,3)/2);
    err(ii) = sqrt(((expectedLocationsX(ii)-fidLoc(ii,1))*res(1)).^2+...
                    ((expectedLocationsY(ii)-fidLoc(ii,2))*res(2)).^2+...
                    ((x0(3)-fidLoc(ii,3))*res(3)).^2);
end
waitbar((ii)/length(expectedLocationsX),d);
disp(['Mean error between initial estimate and single fiducial estimate: ', num2str(mean(err*1e3),2), ' mm.'])

% Determine a new x0 based on individual fiducials
theta = asin(res(1)*(fidLoc(3,1)-fidLoc(2,1))/(2*yDist)); % Estimated angle between x_tx and x_mri
x0(1) = round(xDist/res(1)*cos(theta)+fidLoc(1,1));
x0(2) = round(xDist/res(2)*sin(theta)+fidLoc(1,2));
x0(3) = round(mean(fidLoc(:,3)))-round(zDist/res(3));
txCenter = x0;
[me,err1,err2,err3] = compareCentroids(img,txCenter,theta,res,xDist,yDist,zDist);
disp(['Estimated Error: [',num2str(err1*1e3,2),',',num2str(err2*1e3,2),',',num2str(err3*1e3,2),'], mean: ', num2str(me*1e3,2)])
return

close(d);
[~,tmplt,~,tmpltCenter] = createFiducialTemplate(xDist,yDist,zDist,res,'vitE',theta);

% Search with full template
xSearch = (x0(1)-(round(0.5e-2/res(1))+size(tmplt,1))):(x0(1)+round(0.5e-2/res(1))+size(tmplt,1));
xSearch = xSearch(xSearch>0);
xSearch = xSearch(xSearch<=size(img,1));

ySearch = (x0(2)-(round(0.5e-2/res(2))+size(tmplt,2))):(x0(2)+round(0.5e-2/res(2))+size(tmplt,2));
ySearch = ySearch(ySearch>0);
ySearch = ySearch(ySearch<=size(img,2));

maxPlane = x0(3)+round(0.5e-2/res(3))+ceil(size(tmplt,3)/2);
minPlane = x0(3)-(round(0.5e-2/res(3))+ceil(size(tmplt,3)/2));
if maxPlane < size(tmplt,3)
    maxPlane = size(tmplt,3)+round(0.5e-2/res(3));
end
zSearch = minPlane:maxPlane;
zSearch = zSearch(zSearch>0);
zSearch = zSearch(zSearch<size(img,3));
disp('Searching with full template, could take up to two minutes.')

[result,lags] = xcorr3(img(xSearch,ySearch,zSearch),tmplt);

[~,idx] = max(result(:)); % The 3D "beginning" of the pattern
% Add indices to get to the "center" of the pattern.
txCenter(1) = xSearch(lags{idx}(1))+tmpltCenter(1)-1;
txCenter(2) = ySearch(lags{idx}(2))+tmpltCenter(2)-1;
txCenter(3) = zSearch(lags{idx}(3))+tmpltCenter(3)-1
