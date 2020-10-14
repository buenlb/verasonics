    % sys = adjustTxCenter(sys,newCenter,type)
% Adjust the transducer center in the struct sys with the center given in 
% the variable newCenter.
% 
% @INPUTS
%   sys: System struct
%   newCenter: Desired center of the transducer an index or in MR coords. 
%       If in MR coords it should be in m.
%   type: Specifies whether new focus is an index into the MR matrix
%       (type = 'idx') or is specified in MR coordinates (focalType = 'MR')
% 
% @OUTPUTS
%   sys: System struct with all relevant fields updated to the new center
% 
% Taylor Webb
% University of Utah
% August 2020

function sys = adjustTxCenter(sys,newCenter,type)
switch type
    case 'idx'
        sys.txCenterIdx = newCenter;
        sys.txCenter = [sys.ax(newCenter(1)),sys.ay(newCenter(2)),sys.az(newCenter(3))];
    case 'MR'
        [~,sys.txCenterIdx(1)] = min(abs(sys.ax-newCenter(1)));
        [~,sys.txCenterIdx(2)] = min(abs(sys.ay-newCenter(2)));
        [~,sys.txCenterIdx(3)] = min(abs(sys.az-newCenter(3)));
        sys.txCenter = newCenter;
    otherwise
        error(['Center type ', type, ' not defined.'])
end

sys.ux = sys.ux-sys.ux(sys.txCenterIdx(1));
sys.uy = sys.uy-sys.uy(sys.txCenterIdx(2));
sys.uz = sys.uz-sys.uz(sys.txCenterIdx(3));

sys.txImg = displayTxLoc(sys);