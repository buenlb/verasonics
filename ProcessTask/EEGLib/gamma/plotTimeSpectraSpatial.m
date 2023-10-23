function plotTimeSpectraSpatial(ts,tableEntries,log,fftX,t)

% Error Checking: Make sure the number of table entries matches the number
% of sonications
if size(ts,3)~=length(tableEntries)
    error('Sonications and table entries don''t match!')
end

% Sort locations. The subplots will be placed as if looking down from
% above. If there are more than one locations in the superior/inferior
% dimension multiple figures will be generated. Left and right locations
% will be separated (the code assumes that a negative x is left and a
% positive x is right).
tab = log.paramTable;

foci = reshape([tab.focus],[3,24])';
left = foci(foci(:,1)<0,:,:);
right = foci(foci(:,1)>0,:,:);

xl = unique(left(:,1));
yl = unique(left(:,2));
zl = unique(left(:,3));

xr = unique(right(:,1));
yr = unique(right(:,2));
zr = unique(right(:,3));

nx = length(unique(left(:,1)));
ny = length(unique(left(:,2)));
nz = length(unique(left(:,3)));

% For now, the code assumes that the left and right sonications are
% successfull. It will throw an error here if that isn't true.
if nx ~= length(unique(right(:,1)))
    error('Number of lateral foci inconsistent between left and right!')
elseif ny ~= length(unique(right(:,2)))
    error('Number of anterior/posterior foci inconsistent between left and right!')
elseif nz ~= length(unique(right(:,3)))
    error('Number of superior/inferior foci inconsistent between left and right!')
end

%% Plot time-spectral results for each focus
colorAx = [-1,1]*50;
for ii = 1:nz
    hl = figure;
    hr = figure;
    for jj = 1:ny
        for kk = 1:nx
            % LEFT
            figure(hl);
            subplot(ny,nx,(jj-1)*nx+kk)

            % Figure out which table entry this corresponds to
            curIdx = nan;
            for ll = 1:length(tab)
                if tab(ll).focus(1)==xl(kk) & tab(ll).focus(2)==yl(jj) & tab(ll).focus(3)==zl(ii)
                    curIdx = ll;
                    break
                end
            end

            % Plot the average spectra for this location
            curTs = mean(ts(:,:,tableEntries==curIdx),3,'omitnan');
            imagesc(t,fftX,curTs);
            caxis(colorAx)
            title(['<',num2str(xl(kk)),',',num2str(yl(jj)),',',num2str(zl(ii)),'>'])
            makeFigureBig(hl);

            % RIGHT
            figure(hr);
            subplot(ny,nx,(jj-1)*nx+kk)

            % Figure out which table entry this corresponds to
            curIdx = nan;
            for ll = 1:length(tab)
                if tab(ll).focus(1)==xr(kk) & tab(ll).focus(2)==yr(jj) & tab(ll).focus(3)==zr(ii)
                    curIdx = ll;
                    break
                end
            end

            % Plot the average spectra for this location
            curTs = mean(ts(:,:,tableEntries==curIdx),3,'omitnan');
            imagesc(t,fftX,curTs);
            caxis(colorAx)
            title(['<',num2str(xr(kk)),',',num2str(yr(jj)),',',num2str(zr(ii)),'>'])
            makeFigureBig(hr);
        end
    end
end