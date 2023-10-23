function plotBandsSpatial(ts,tableEntries,log,fftX,t)

dth = [0.5,8];
alpha = [8,14];
beta = [14,30];
gamma = [30,70];
hg = [70,200];
% bands = {dth,alpha, beta, gamma,hg};
% bandLabels = {'Delta/Theta','Alpha','Beta','Gamma','High Gamma'};
bands = {alpha,beta,gamma,hg};
bandLabels = {'Alpha','Beta','Gamma','High Gamma'};

bndIdx = cell(size(bandLabels));
for ii = 1:length(bands)
    bndIdx{ii} = find(fftX>=bands{ii}(1) & fftX<bands{ii}(2));
end


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
yLims = [-1,1]*50;
xLims = [0,max(t)];
anovaWindow = 4;
anovaIdx = find(t>0.1 & t<=anovaWindow);
mxBndL = cell(length(bands));
mxBndR = mxBndL;
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
            ax = gca;
            clear bnds bndLabel;
            curBndIdx = 1;
            try
            for mm = 1:length(bands)
                curTs = mean(ts(bndIdx{mm},:,tableEntries==curIdx),3,'omitnan');
                curTstd = semOmitNan(curTs,1);
                % curTstd = std(curTs,[],1,'omitnan');
                curTs = mean(curTs,1,'omitnan');
                shadedErrorBar(t,curTs,curTstd,'lineprops',{'Color',ax.ColorOrder(mm+1,:)});
                bnds(:,curBndIdx:curBndIdx+sum(tableEntries==curIdx)-1) = squeeze(mean(ts(bndIdx{mm},anovaIdx,tableEntries==curIdx),1,'omitnan'));
                bndLabel(curBndIdx:curBndIdx+sum(tableEntries==curIdx)-1) = mm;
                curBndIdx = curBndIdx+sum(tableEntries==curIdx);
                mxBndL{mm}(jj,kk) = mean(curTs(anovaIdx),'omitnan');
%                 keyboard
            end
            catch
                keyboard
            end
            bndLabel = repmat(bndLabel,[size(bnds,1),1]);
            tmLabel = repmat(t(anovaIdx)',[1,size(bnds,2)]);
            
            % p = anovan(bnds(:),{bndLabel(:),tmLabel(:)},'varnames',{'Band','Time'},'display','off');
            p = anovan(bnds(:),{bndLabel(:)},'varnames',{'Band'},'display','off');
            
%             if p(1)<0.001
%                 title(['***<',num2str(xl(kk)),',',num2str(yl(jj)),',',num2str(zl(ii)),'>'])
%             elseif p(1)<0.01
%                 title(['**<',num2str(xl(kk)),',',num2str(yl(jj)),',',num2str(zl(ii)),'>'])
%             elseif p(1)<0.05
%                 title(['*<',num2str(xl(kk)),',',num2str(yl(jj)),',',num2str(zl(ii)),'>'])
%             else
%                 title(['<',num2str(xl(kk)),',',num2str(yl(jj)),',',num2str(zl(ii)),'>'])
%             end
            ax.YLim = [yLims];
            ax.XTickLabel = {''};
            ax.YTickLabel = {''};
            ax.XLim = xLims;
            makeFigureBig(hl);
            if kk == 1 && jj == 1
                legend(bandLabels)
            end

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
            clear bnds bndLabel;
            curBndIdx = 1;
            for mm = 1:length(bands)
                curTs = mean(ts(bndIdx{mm},:,tableEntries==curIdx),3,'omitnan');
                curTstd = semOmitNan(curTs,1);
                % curTstd = std(curTs,[],1,'omitnan');
                curTs = mean(curTs,1,'omitnan');
                shadedErrorBar(t,curTs,curTstd,'lineprops',{'Color',ax.ColorOrder(mm+1,:)});
                bnds(:,curBndIdx:curBndIdx+sum(tableEntries==curIdx)-1) = squeeze(mean(ts(bndIdx{mm},anovaIdx,tableEntries==curIdx),1,'omitnan'));
                bndLabel(curBndIdx:curBndIdx+sum(tableEntries==curIdx)-1) = mm;
                curBndIdx = curBndIdx+sum(tableEntries==curIdx);

                mxBndR{mm}(jj,kk) = mean(curTs(anovaIdx),'omitnan');
            end
            bndLabel = repmat(bndLabel,[size(bnds,1),1]);
            tmLabel = repmat(t(anovaIdx)',[1,size(bnds,2)]);
            
            % p = anovan(bnds(:),{bndLabel(:),tmLabel(:)},'varnames',{'Band','Time'},'display','off');
            p = anovan(bnds(:),{bndLabel(:)},'varnames',{'Band'},'display','off');
            
%             if p(1)<0.001
%                 title(['***<',num2str(xr(kk)),',',num2str(yr(jj)),',',num2str(zr(ii)),'>'])
%             elseif p(1)<0.01
%                 title(['**<',num2str(xr(kk)),',',num2str(yr(jj)),',',num2str(zr(ii)),'>'])
%             elseif p(1)<0.05
%                 title(['*<',num2str(xr(kk)),',',num2str(yr(jj)),',',num2str(zr(ii)),'>'])
%             else
%                 title(['<',num2str(xr(kk)),',',num2str(yr(jj)),',',num2str(zr(ii)),'>'])
%             end
            ax.YLim = [yLims];
            ax.XTickLabel = {''};
            ax.YTickLabel = {''};
            ax.XLim = xLims;
            makeFigureBig(hr);
            if kk == 1 && jj == 1
                legend(bandLabels)
            end
        end
    end
end
%%
cx = [-1,1]*20;
for ii = 1:length(bands)
    h = figure;
    subplot(121)
    imagesc(xl,yl,mxBndL{ii})
    caxis(cx)
    title([bandLabels{ii},' Left'])
    makeFigureBig(h)

    subplot(122)
    imagesc(xr,yr,mxBndR{ii})
    title([bandLabels{ii},' Right'])
    caxis(cx)
    makeFigureBig(h)
    colorbar
end
