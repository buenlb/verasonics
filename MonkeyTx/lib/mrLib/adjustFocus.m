% sys = adjustFocus(sys,newFocus,focalType)
% Adjust the focus in the struct sys with the focus given in the variable
% new Focus.
% 
% @INPUTS
%   sys: System struct
%   newFocus: Desired focal spot as an index, in MR coords, or in US
%       coords. If in US or MR coords it should be mm
%   focalType: Specifies whether new focus is an index into the MR matrix
%       (focalType = 'idx') or is specified in MR coordinates (focalType =
%       'MR') or US coordinates (focalType = 'US')
% 
% @OUTPUTS
%   sys: System struct with all relevant fields updated to the new focus
% 
% Taylor Webb
% University of Utah
% August 2020

function sys = adjustFocus(sys,newFocus,focalType)
x = sys.ux;
y = sys.uy;
z = sys.uz;

switch focalType
    case 'idx'
        focalSpotIdx = newFocus;
        focalSpot = ([x(focalSpotIdx(1)),y(focalSpotIdx(2)),z(focalSpotIdx(3))])*1e3;

        sys.focalSpot = focalSpot;
        sys.focalSpotIdx = focalSpotIdx;
        sys.focalSpotMr = [sys.ax(focalSpotIdx(1)), sys.ay(focalSpotIdx(2)), sys.az(focalSpotIdx(3))]*1e3;
    case 'MR'
        [~,focalSpotIdx(1)] = min(abs(sys.ax*1e3-newFocus(1)));
        [~,focalSpotIdx(2)] = min(abs(sys.ay*1e3-newFocus(2)));
        [~,focalSpotIdx(3)] = min(abs(sys.az*1e3-newFocus(3)));
        
        sys.focalSpotMr = newFocus;
        sys.focalSpot = ([x(focalSpotIdx(1)),y(focalSpotIdx(2)),z(focalSpotIdx(3))])*1e3;
        sys.focalSpotIdx = focalSpotIdx;
    case 'US'
        [~,focalSpotIdx(1)] = min(abs(sys.ux*1e3-newFocus(1)));
        [~,focalSpotIdx(2)] = min(abs(sys.uy*1e3-newFocus(2)));
        [~,focalSpotIdx(3)] = min(abs(sys.uz*1e3-newFocus(3)));
        
        sys.focalSpot = newFocus;
        sys.focalSpotMr = ([sys.ax(focalSpotIdx(1)),sys.ay(focalSpotIdx(2)),sys.az(focalSpotIdx(3))])*1e3;
        sys.focalSpotIdx = focalSpotIdx;
    otherwise
        error(['focalType ', focalType, ' is not defined.'])
end

%% Print result in both Tx and MR coordinates
displayFocalCoordinates(sys);