% Test getDurableSigmoids.m
%
% The following test creates a sigmoid that should average to perfect (all
% 1s and 0s at the edges and exactly 0.5 in the middle.
% 
% It then creates a sigmoid that should average to a leftward bias.
% 
% Taylor Webb
% October 2022

%% Test basic functionality
chVectors = nan(5,3,3);
chVectors(:,:,1) = [0,0,0;0,0,0;0.75,0.75,0.25;1,1,1;1,1,1];
chVectors(:,:,2) = [0,0,0;0,0,0;0.25,0.8,0.2;1,1,1;1,1,1];
chVectors(:,:,3) = [0,0,0;0,0,0;0.5,0.7,0.3;1,1,1;1,1,1];

delays = [-90;-45;0;45;90];
dVectors = repmat(delays,[1,3,3]);

[cSlope(1),cBias(1),cDownshift(1),cScale(1)] = fitSigmoid(delays,[0,0,0.5,1,1]);
[cSlope(2),cBias(2),cDownshift(2),cScale(2)] = fitSigmoid(delays,[0,0,0.75,1,1]);
[cSlope(3),cBias(3),cDownshift(3),cScale(3)] = fitSigmoid(delays,[0,0,0.25,1,1]);

[slope,bias,downshift,scale] = getDurableSigmoids(dVectors,chVectors);

if sum(cSlope'==slope)~=length(slope)
    error('Wrong Slope!')
end
if sum(cBias'==bias)~=length(bias)
    error('Wrong Bias!')
end
if sum(cDownshift'==downshift)~=length(downshift)
    error('Wrong Shift!')
end
if sum(cScale'==scale)~=length(scale)
    error('Wrong Scale!')
end

disp('Passed basic functionality test! Tests data with the same delays');

%% Test NaNs
chVectors = nan(5,3,3);
chVectors(:,:,1) = [0,nan,0;0,nan,0;0.75,nan,0.25;1,nan,1;1,nan,1];
chVectors(:,:,2) = [0,0,0;0,0,0;0.25,0.8,0.2;1,1,1;1,1,1];
chVectors(:,:,3) = [0,0,0;0,0,0;0.5,0.7,0.3;1,1,1;1,1,1];

delays = [-90;-45;0;45;90];
dVectors = repmat(delays,[1,3,3]);

[cSlope(1),cBias(1),cDownshift(1),cScale(1)] = fitSigmoid(delays,[0,0,0.5,1,1]);
[cSlope(2),cBias(2),cDownshift(2),cScale(2)] = fitSigmoid(delays,[0,0,0.75,1,1]);
[cSlope(3),cBias(3),cDownshift(3),cScale(3)] = fitSigmoid(delays,[0,0,0.25,1,1]);

[slope,bias,downshift,scale] = getDurableSigmoids(dVectors,chVectors);

if sum(cSlope'==slope)~=length(slope)
    error('Wrong Slope!')
end
if sum(cBias'==bias)~=length(bias)
    error('Wrong Bias!')
end
if sum(cDownshift'==downshift)~=length(downshift)
    error('Wrong Shift!')
end
if sum(cScale'==scale)~=length(scale)
    error('Wrong Scale!')
end

disp('Passed NaN test! Tests data with the same delays and a Nan entry');

%% Test Different Delays and NaNs together
chVectors = nan(5,3,5);
chVectors(:,:,1) = [0,nan,0;0,nan,0;0.75,nan,0.25;1,nan,1;1,nan,1];
chVectors(:,:,2) = [0,0,0;0,0,0;0.25,0.8,0.2;1,1,1;1,1,1];
chVectors(:,:,3) = [0,0,0;0,0,0;0.5,0.7,0.3;1,1,1;1,1,1];
chVectors(:,:,4) = [0,0,0;0,0,0;0.25,0.8,0.2;1,1,1;1,1,1];
chVectors(:,:,5) = [0,0,0;0,0,0;0.75,0.7,0.3;1,1,1;1,1,1];

delays = [-90;-45;0;45;90];
dVectors = repmat(delays,[1,3,3]);
delays2 = [-120;-60;0;60;120];
dVectors(:,:,4:5) = repmat(delays2,[1,3,2]);
delays = unique(dVectors);

[cSlope(1),cBias(1),cDownshift(1),cScale(1)] = fitSigmoid(delays,[0,0,0,0,0.5,1,1,1,1]);
[cSlope(2),cBias(2),cDownshift(2),cScale(2)] = fitSigmoid(delays,[0,0,0,0,.75,1,1,1,1]);
[cSlope(3),cBias(3),cDownshift(3),cScale(3)] = fitSigmoid(delays,[0,0,0,0,0.25,1,1,1,1]);

[slope,bias,downshift,scale] = getDurableSigmoids(dVectors,chVectors);

if sum(cSlope'==slope)~=length(slope)
    error('Wrong Slope!')
end
if sum(cBias'==bias)~=length(bias)
    error('Wrong Bias!')
end
if sum(cDownshift'==downshift)~=length(downshift)
    error('Wrong Shift!')
end
if sum(cScale'==scale)~=length(scale)
    error('Wrong Scale!')
end

disp('Passed varied delays test! Tests data with the different delays and a Nan entry');
