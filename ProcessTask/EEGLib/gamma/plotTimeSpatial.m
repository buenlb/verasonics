function [spatialSignalsLeft,spatialSignalsRight,nLeft,nRight] = plotTimeSpatial(eeg,tableEntries,log,tWindow,varargin)

% Error Checking: Make sure the number of table entries matches the number
% of sonications
if size(eeg,1)~=length(tableEntries)
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

if mod(length(varargin),2)
    error('Extra varialbes must be name-value pairs!')
end

hl = figure;
hr = figure;
ax = gca;
cl = ax.ColorOrder(1,:);

for ii = 1:2:length(varargin)
    switch varargin{ii}
        case 'rightFig'
            hr = varargin{ii+1};
            if nz>1
                warning('Overwriting any passed figures to do depth')
            end
        case 'leftFig'
            hl = varargin{ii+1};
            if nz>1
                warning('Overwriting any passed figures to do depth')
            end
        case 'Color'
            cl = varargin{ii+1};
        otherwise
            error(['Unrecognized name: ',varargin{ii}])
    end
end

%% Plot time-spectral results for each focus
dsRate = 10;
spatialSignalsLeft = nan(max(tableEntries)/2,length(eeg(1,1:dsRate:end)));
spatialSignalsRight = nan(max(tableEntries)/2,length(eeg(1,1:dsRate:end)));
nLeft = zeros(nx,ny);
nRight = zeros(nx,ny);
yLims = [-1,1]*100;
for ii = 1:nz
    if nz > 1
        hl = figure;
        hr = figure;
    end
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
            ax = gca;
            ltAx((jj-1)*nx+kk) = ax;
            shadedErrorBar(tWindow(1:dsRate:end),mean(eeg(tableEntries==curIdx,1:dsRate:end),1,'omitnan'),semOmitNan(eeg(tableEntries==curIdx,1:dsRate:end),1),...
                'lineprops',{'Color',cl})
            hold on
%             plot([0.1,0.1],yLims,'k--')
%             xlabel('Time (s)')
%             ylabel('Voltage (\muV)')
%             title(['<',num2str(xl(kk)),',',num2str(yl(jj)),',',num2str(zl(ii)),'>'])
            ax.YLim = yLims;
            ax.XTickLabel = {''};
            ax.YTickLabel = {''};
            makeFigureBig(hl)

            % Align Axes
            if kk>1
                ax.Position(1) = ltAx((jj-1)*nx+kk-1).Position(1)+ltAx((jj-1)*nx+kk-1).Position(3);
            end
            if jj>1
                ax.Position(2) = ltAx((jj-2)*nx+kk).Position(2)-ltAx((jj-2)*nx+kk).Position(4);
            end

            spatialSignalsLeft(curIdx,:) = mean(eeg(tableEntries==curIdx,1:dsRate:end),1,'omitnan');
            nLeft(kk,jj) = sum(~isnan(eeg(tableEntries==curIdx,end)));

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
            ax = gca;
            rtAx((jj-1)*nx+kk) = ax;
            shadedErrorBar(tWindow(1:dsRate:end),mean(eeg(tableEntries==curIdx,1:dsRate:end),1,'omitnan'),semOmitNan(eeg(tableEntries==curIdx,1:dsRate:end),1),...
                'lineprops',{'Color',cl})
            hold on
%             plot([0.1,0.1],yLims,'k--')
%             xlabel('Time (s)')
%             ylabel('Voltage (\muV)')
%             title(['<',num2str(xr(kk)),',',num2str(yr(jj)),',',num2str(zr(ii)),'>'])
            ax.YLim = yLims;
            ax.XTickLabel = {''};
            ax.YTickLabel = {''};
            makeFigureBig(hl)
            
            % Align Axes
            if kk>1
                ax.Position(1) = rtAx((jj-1)*nx+kk-1).Position(1)+rtAx((jj-1)*nx+kk-1).Position(3);
            end
            if jj>1
                ax.Position(2) = rtAx((jj-2)*nx+kk).Position(2)-rtAx((jj-2)*nx+kk).Position(4);
            end

            spatialSignalsRight(curIdx-max(tableEntries)/2,:) = mean(eeg(tableEntries==curIdx,1:dsRate:end),1,'omitnan');
            nRight(kk,jj) = sum(~isnan(eeg(tableEntries==curIdx,end)));
        end
    end
end
