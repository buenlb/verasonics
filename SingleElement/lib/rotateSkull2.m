function rotateSkull2(RData)

alpha = 5; %rotation increment; use 5 or 10; do also use negative angles to change direction

Resource = evalin('base','Resource');
Receive = evalin('base','Receive');

lib = 'soniq';
pos = getPositionerSettings(lib);

angles = Resource.Parameters.angles;

idx = find(abs(pos.THETA.loc - angles) < 1e-6);

save([Resource.Parameters.saveDir, Resource.Parameters.saveName, 'angle', num2str(idx),'.mat'],...
    'RData','Resource','Receive')

if idx == length(angles)
    disp('Attempting to close VSX')
    VSXquit;
    VsClose;
    return
end
disp(['Point ', num2str(idx+1), ' of ', num2str(length(angles))])

i = angles(idx+1); %the next iteration

skulldims = [140 200];
zit = 1;
projn = mean(skulldims)/2 * sin(deg2rad(alpha)) / sin(deg2rad(90 - 2 * alpha));
xsh = 0;
ysh = 0;
%correction for accumulated error at 0, 90, 270, 360 degrees
if mod(alpha * i, 90) == 0
    zit = i;
end
for z = zit : i
    if mod(z, 2) == 0
        projns = -projn;
    else
        projns = projn;
    end
    xsh = xsh + projns * cos(deg2rad(alpha * i));
    ysh = ysh + projns * sin(deg2rad(alpha * i));
end
fprintf('angle %d: x = %.1f, y = %.1f, procn = %.1f\n', alpha * i, xsh, ysh, projns);
movePositionerAbs(lib,pos.THETA.Axis, -alpha * i);
movePositionerAbs(lib,pos.X.Axis, xsh);
movePositionerAbs(lib,pos.Y.Axis, -ysh);
return