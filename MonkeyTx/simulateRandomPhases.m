[pLGN,x,y,z] = exponentialSteeringSimulation([-10.5,-1.5,58],0.48);
pInverted = exponentialSteeringSimulation([],0.48);


[~,idx] = min(abs(y--1.5e-3));
rng = max(abs(pLGN(:)));

[lgnMax,idxLGN] = max(abs(pLGN(:)));
[aLGN,idxLGN,bLGN] = ind2sub(size(pInverted),idxLGN);

h = figure;
imshow(squeeze(abs(pLGN(:,idx,:)))',[0,rng]);

[invertedMax,idxInverted] = max(abs(pInverted(:)));
[aInverted,idxInverted,bInverted] = ind2sub(size(pInverted),idxInverted);
h = figure;
imshow(squeeze(abs(pInverted(:,idxInverted,:)))',[0,rng]);
