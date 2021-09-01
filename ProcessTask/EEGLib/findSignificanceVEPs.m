function [h,p] = findSignificanceVEPs(vep1,vep2,dim,ax,tA)
if dim == 1
    dim2 = 2;
else
    dim2 = 1;
end

if size(vep1,dim2)~=size(vep2,dim2)
    error('Length of EEG data must be the same')
end

h = zeros(size(vep1,dim2),1);
p = zeros(size(vep2,dim2),1);

for ii = 1:size(vep1,dim2)
    if dim == 2
        curV1 = vep1(ii,:);
        curV2 = vep2(ii,:);
    else
        curV1 = vep1(:,ii);
        curV2 = vep2(:,ii);
    end
    
    [h(ii),p(ii)] = ttest2(curV1,curV2);
end

if exist('ax','var')
    tmpH = zeros(size(h));
    tmpH([diff(h);0]>0) = 1;
    idxOn = find(tmpH);

    tmpH = zeros(size(h));
    tmpH([diff(h);0]<0) = 1;
    idxOff = find(tmpH);
    
    axes(ax);
    hold on;
    if length(idxOff)<length(idxOn)
        idxOff(end+1) = length(h);
    elseif length(idxOn)<length(idxOff)
        idxOn = [1;idxOn];
    end
    for ii = 1:length(idxOn)
        f = fill(1e3*[tA(idxOn(ii)),tA(idxOn(ii)),tA(idxOff(ii)),tA(idxOff(ii))],[ax.YLim,ax.YLim(2:-1:1)],'k');
        f.EdgeAlpha = 0.3;
        f.FaceAlpha = 0.3;
    end
end