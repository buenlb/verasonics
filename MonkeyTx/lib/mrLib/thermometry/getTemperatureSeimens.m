% getTemperatureSeimens returns the temperature measured by the images
% found in path (or sys.img if that has already been set). It uses dynamic
% number sys.baseline for the baseline images.
% 
% @INPUTS
%   sys: Struct containing at least the field path or img.
%     @FIELDS
%       path: Directory in which to find dicoms of phase images
%       img: Phase images. If this field it must contain the images from
%          sys.path.
%       baseline: Dynamic to use as baseline. If not set, system
%          automatically uses the first dynamic
%   nSlices: number of thermometry slices
%       
% @OUTPUTS
%   T: Estimate of temperature
% 
% Taylor Webb
% University of Utah
% 

function T = getTemperatureSeimens(sys, nSlices, PLOTRESULTS)
%% Load images if they haven't been loaded already
if sys.path(end) ~= '/'
    sys.path = [sys.path, '/'];
end
if ~isfield(sys,'img')
    [img,header] = loadDicomDir(sys.path);
    header = header{9};
else
    img = sys.img;
    header = sys.imgHeader;
end

%% Set baseline default of 1 if the user didn't specify a dynamic
if ~isfield(sys,'baseline')
    baseline = 1;
else
    baseline = sys.baseline;
end

%% Convert to radians
img = img/max(abs(img(:)))*pi;
%% Get the set of files in order to read headers and display the computed number of dynamics
images = dir([sys.path,'*.IMA']);
if isempty(images)
    images = dir([sys.path,'*.dcm']);
end
nImages = size(img,3);
dynamics = nImages/nSlices;
disp(['      Number of dcm images in path: ', num2str(nImages), '. Number of temperature images: ', num2str(nImages), '. Number of Dymanics: ', num2str(dynamics)])

%% Generate the baseline
baselineImgs = (1+(baseline(1)-1)*nSlices):(nSlices+(baseline(end)-1)*nSlices);
baselineImg = zeros(size(img,1),size(img,2),nSlices);
for ii = 1:nSlices
    curSlices = baselineImgs(ii):nSlices:nSlices*baseline(end);
    baselineImg(:,:,ii) = mean(img(:,:,curSlices),3);
end

%% Find temperature
T = zeros(size(img,1),size(img,2),nSlices,dynamics-length(baseline));
imgIdx = 1;
for ii = 1:dynamics
    for jj = 1:nSlices        
        curImg = img(:,:,imgIdx);
        if ii == 1 && jj == 1
            header = dicominfo([sys.path, images(imgIdx).name]);
            B0 = double(header.MagneticFieldStrength);
            TE = double(header.EchoTime);
        else
            T(:,:,jj,ii) = myTempDrift2(B0,baselineImg(:,:,jj),curImg,TE);
            
            if PLOTRESULTS
                spRows = ceil(sqrt(nSlices));
                spCols = floor(sqrt(nSlices));
                if spRows*spCols < nSlices
                    spCols = spCols+1;
                end
                if jj == 1
                    h = figure;
                else
                    figure(h);
                end
                subplot(spRows,spCols,jj)
                imagesc(squeeze(T(:,:,jj,ii)),[0,10]);
                colorbar;
        %                 overlayImages(squeeze(T(:,:,imgIdx-baseline)), sqrt(reImg.^2+imImg.^2), h, 0, 25)
            end
        end
        if exist('h','var')
            set(h,'position',[1.9210   -0.2950    1.9200    1.0848]*1e3)
        end
        imgIdx = imgIdx+1;
    end
end