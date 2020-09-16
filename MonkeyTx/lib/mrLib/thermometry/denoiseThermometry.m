function tDenoised = denoiseThermometry(T,firstDynamic,sonicationDuration,header)
tic
if nargin < 2
    firstDynamic = 4;
end

%% Find the expected peak
acqTime = findAcquisitionTime(header);
expectedPeakIdx = firstDynamic+ceil(sonicationDuration/acqTime);

tDenoised = zeros(size(T));
t = (0:(size(T,4)-1))*acqTime;

d = waitbar(0,'Loading Dicoms');
figure(d)
for ii = 1:size(T,1)
    for jj = 1:size(T,2)
        for kk = 1:size(T,3)
            curT = squeeze(T(ii,jj,kk,:));
            if max(abs(curT)) == 0
                continue
            else
                if(fitThermometryCurve(t,curT,firstDynamic,expectedPeakIdx))
                    tDenoised(ii,jj,kk,:) = curT;
                end
            end
        end
%         waitbar((jj+1)*ii/(size(T,1)*size(T,2)),d,'De-noising Thermometry')
    end
    waitbar((ii+1)/size(T,1),d,['De-noising Thermometry: Row ', num2str(ii), ' of ', num2str(size(T,1))]);
end
close(d);
toc