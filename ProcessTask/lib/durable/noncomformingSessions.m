%% A record of sessions when something unexpected happened with ultrasound
ncs = {'Euler20220301_b.mat'};
sonicatedBlock = [26];
% ncs = {};
%% Sessions to be exluded. The reason is given above each session
% Euler20220208.mat: A sonication occured when the session was terminated.
%   The EEG showed no evidence of a trigger.
exc{1} = 'Euler20220208.mat';

% Euler20220323.mat: The log states that a second pulse began after the
%   initial ultrasound. While the probe was disconnected after the first
%   pulse, it is still likely that th US effected this session in
%   unpredictable ways.
exc{2} = 'Euler20220323.mat';