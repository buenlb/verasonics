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
% 
% Taylor Webb
% University of Utah

function [pass,distErr,powErr] = checkCoupling(gs,cr,singleElement)

if nargin < 3
    singleElement = 0;
end

maxErrDist = 2.3;
meanErrDist = 1.2;
maxErrPow = 30;
meanErrPow = 20;

gsParams = load(gs);
cr = load(cr);
gs = load(gsParams.fName);

[gsRaw,crRaw,~,d] = getRawTraces(gs,cr,singleElement);

if ~singleElement
    gridSize = 3;
else
    gridSize = 1;
end
blocks = selectElementBlocks(gridSize);
axIdx = 1;
if singleElement
    elementsOfInterest = gsParams.elementsOfInterest;
else
    elementsOfInterest = [74,79,124,125,194,199];
end
for ii = 1:length(blocks)
    centerElement = blocks{ii}(ceil(gridSize^2/2));
    if ismember(centerElement,elementsOfInterest)
        curCr = crRaw(:,ii);
        curGs = gsRaw(:,ii);

        curCr(d>gsParams.powerRange(2)) = 0;
        curCr(d<gsParams.powerRange(1)) = 0;

        curGs(d>gsParams.powerRange(2)) = 0;
        curGs(d<gsParams.powerRange(1)) = 0;

        % Determine distance error
        idxGs = find(curGs/max(curGs)>0.5);
        if isempty(idxGs)
            msgbox('WARNING: No signal exceeded threshold!')
            idxGs = 1;
        else
            idxGs = idxGs(1);
        end

        idxCr = find(curCr/max(curCr)>0.5);
        if isempty(idxCr)
            msgbox('WARNING: No signal exceeded threshold!')
            idxCr = 1;
        else
            idxCr = idxCr(1);
        end

        distErr(axIdx) = abs(d(idxGs)-d(idxCr));
        powErrTmp = max(curCr)/max(curGs);
        if powErrTmp > 1
            powErr(axIdx) = powErrTmp-1;
        else
            powErr(axIdx) = 1-powErrTmp;
        end
        
        axIdx = axIdx+1;
    end
end

if mean(distErr) <= meanErrDist && max(distErr) <= maxErrDist && ...
        100*mean(powErr) <= meanErrPow && 100*max(powErr) <= maxErrPow
    pass = true;
else
    pass = false;
end

disp(['Mean Error: ', num2str(mean(distErr),2), ' mm; Max Error: ', num2str(max(distErr),2),' mm',...
    '; Mean Pressure Difference: ', num2str(100*mean(powErr),2), '%; Max Pressure Difference: ', num2str(100*max(powErr),2),'%']);