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
%       nSlices: Number of slices - this must be set or an error is thrown.
%       
% @OUTPUTS
%   T: Estimate of temperature
%   estTreatmentTime: Estimate of each dynamic length based on fields in
%       the header. This allows for the plotting of temperature with time.
% 
% Taylor Webb
% University of Utah
% 

function [T, estTreatmentTime] = getTemperatureSeimens(sys, PLOTRESULTS)
%% Error checking
if~isfield(sys,'nSlices')
    error('You must specify the number of slices!')
end
nSlices = sys.nSlices;
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
nImageFiles = size(img,3);
nImages = nImageFiles - nSlices*2;
dynamics = nImages/nSlices;
disp(['      Number of dcm images in path: ', num2str(nImageFiles), '. Number of temperature images: ', num2str(nImages), '. Number of Dymanics: ', num2str(dynamics)])

%% Find temperature
imgIdx = nSlices+1; % For some reason the first set of slices is always blank on the data
baselineImgs = (nSlices+1+(baseline-1)*nSlices):(nSlices+(baseline-1)*nSlices+nSlices);
baselineImg = zeros(size(img,1),size(img,2),nSlices);
for ii = 1:dynamics+1
    for jj = 1:nSlices
        if imgIdx < baseline
            imgIdx = imgIdx+1;
            continue
        end        
        curImg = img(:,:,imgIdx);
        if ismember(imgIdx,baselineImgs)
            baselineImg(:,:,jj) = curImg;
            header = dicominfo([sys.path, images(imgIdx).name]);
            B0 = header.MagneticFieldStrength;
            TE = header.EchoTime;
            TR = double(header.RepetitionTime);
            rows = double(header.Rows);
            estTreatmentTime = TR*1e-3*rows/2*(nImages-2);
        else
            T(:,:,jj,ii) = myTempDrift2(B0,baselineImg(:,:,jj),curImg,TE); %#ok<AGROW>
            
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