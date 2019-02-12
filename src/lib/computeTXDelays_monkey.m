% computeTxDelays_monkey computes delays for the macaque transducer.
% 
% @INPUTS
%   focus: the desired focal location. Must be referenced to the same
%      origin as the element locations in Trans
%   Trans: Struct defining the transducer. This is the same struct expected
%      by VSX
% 
% @OUTPUTS
%   delays: Delays to apply to each element in order to focus at the
%     desired target

function computeTXDelays_monkey(focus,Trans)

elLocations = Trans.ElementPos;
