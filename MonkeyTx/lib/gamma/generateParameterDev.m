% Creates a vector representing nParams possible values of a parameter 
% centered at center with deviation paramDev
% 
% Taylor Webb
% University of Utah

function x = generateParameterDev(center,nParams,paramDev)
if mod(nParams,2)
    tmp = -floor(nParams/2):floor(nParams/2);
else
    tmp = -(nParams/2-0.5):(nParams/2-0.5);
end
tmp = tmp*paramDev;
x = tmp+center;