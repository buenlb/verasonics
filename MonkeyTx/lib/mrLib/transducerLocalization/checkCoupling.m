% checkCoupling uses the raw signals containted in gs and cr to check if
% the coupling as measured in cr is similar enough to the coupling measured
% in gs. If it is, it returs true in the variable pass. It also returns the
% computed errors.
% 
% @USAGE [pass,distErr,powErr] = checkCoupling(gs,cr)
% @INPUTS
%   gs: full file name of gold standard data
%   cr: full file name of current data
%   singleElement: Optional, flag that determines whether to use single
%       elements or a 3X3 grid. Defaults to 0
% 
% @OUTPUTS
%   pass: True if the following conditions are met:
%       mean(distErr) < 1.2 mm
%       max(distErr) > 2.3 mm
%       mean(powErr) < 20%
%       max(pwErr) < 30%
%   distErr: Distance error (mm) computed at 6 locations
%   powErr: Power error (percent) computed at the same 6 locations
%   totErrPow: Power error (percent) averaged across all elements
%   gsSignals: signals used in the above computation for the gold standard
%       data
%   crSignals: Signals used in the above computation for the current data
%   gsSkullIdx: Estimated index of skull reflection for gold standard data
%   crSkullIdx: Estimated index of skull reflection for current data
% 
% Taylor Webb
% University of Utah

function [pass,distErr,powErr,totErrPow,gsSignals,crSignals,gsSkullIdx,crSkullIdx,d,elementsOfInterest] = checkCoupling(gs,cr,singleElement)

if nargin < 3
    singleElement = 0;
end

maxErrDist = 2.3;
meanErrDist = 1.15;
maxErrPow = 50;
meanErrPow = 30;

gsParams = load(gs);

if isfield(gsParams,'txSn')
    txSn = gsParams.txSn;
else
	warning('No Serial Number found, assuming JAB800');
	txSn = 'JAB800';
end

[gsRaw,crRaw,~,d] = getRawTraces(gsParams.fName,cr,singleElement);

if ~singleElement
    gridSize = 3;
else
    gridSize = 1;
end
blocks = selectElementBlocks(gridSize,txSn);
axIdx = 1;
if ~singleElement
    elementsOfInterest = gsParams.elementsOfInterest;
else
    elementsOfInterest = [74,79,124,125,194,199];
end

powErr = zeros(1,length(elementsOfInterest));
distErr = zeros(1,length(elementsOfInterest));
crSkullIdx = zeros(1,length(elementsOfInterest));
gsSkullIdx = zeros(1,length(elementsOfInterest));
crSignals = zeros(size(crRaw,1),length(elementsOfInterest));
gsSignals = zeros(size(crRaw,1),length(elementsOfInterest));
for ii = 1:length(blocks)
    centerElement = blocks{ii}(ceil(gridSize^2/2));
    if ismember(centerElement,elementsOfInterest)
        if singleElement
            idx = [centerElement-9:centerElement-7,centerElement-1:centerElement+1,centerElement+7:centerElement+9];
            curCr = mean(crRaw(:,idx),2);
            curGs = mean(gsRaw(:,idx),2);
        else
            curCr = crRaw(:,ii);
            curGs = gsRaw(:,ii);
        end

        curCr(d>gsParams.powerRange(2)) = 0;
        curCr(d<gsParams.powerRange(1)) = 0;

        curGs(d>gsParams.powerRange(2)) = 0;
        curGs(d<gsParams.powerRange(1)) = 0;

        crSignals(:,axIdx) = curCr;
        gsSignals(:,axIdx) = curGs;

        % Determine distance error
        idxGs = find(curGs/max(curGs)>0.5);
        if isempty(idxGs)
            msgbox('WARNING: No signal exceeded threshold!')
            idxGs = 1;
        else
            idxGs = idxGs(1);
        end

        tmp = curCr-max(curCr)/max(curGs)*curGs(idxGs);
        idx = find(diff(sign(tmp)));
        if isempty(idx)
            idxCr = 1;
        else
            [~,tmpIdx] = min(abs(idx-idxGs));
            idxCr = idx(tmpIdx);
        end
        
        crSkullIdx(axIdx) = idxCr;
        gsSkullIdx(axIdx) = idxGs;
        
        distErr(axIdx) = (d(idxGs)-d(idxCr));
        powErrTmp = max(curCr)/max(curGs);
        if powErrTmp > 1
            powErr(axIdx) = powErrTmp-1;
        else
            powErr(axIdx) = 1-powErrTmp;
        end

        axIdx = axIdx+1;
    end
end

%% Find total average
curCr = crRaw;
curGs = gsRaw;
curCr(d>gsParams.powerRange(2) | d<gsParams.powerRange(1),:) = 0;
curGs(d>gsParams.powerRange(2) | d<gsParams.powerRange(1),:) = 0;

curPw = max(mean(curCr,2));
gsPw = max(mean(curGs,2));
totErrPow = (curPw-gsPw)/gsPw;
% if curPw > gsPw
%     totErrPow = 1-gsPw/curPw;
% else
%     totErrPow = 1-curPw/gsPw;
% end
if mean(distErr) <= meanErrDist && max(distErr) <= maxErrDist && ...
        100*totErrPow <= meanErrPow% && 100*max(powErr) <= maxErrPow
    pass = true;
else
    pass = false;
end

disp(['Mean Error: ', num2str(mean(distErr),2), ' mm; Max Error: ', num2str(max(distErr),2),' mm'])
disp(['Mean Pressure Difference: ', num2str(100*mean(powErr),2), '%; Max Pressure Difference: ', num2str(100*max(powErr),2),'%; Total Pressure Difference: ', num2str(100*totErrPow,2),'%']);