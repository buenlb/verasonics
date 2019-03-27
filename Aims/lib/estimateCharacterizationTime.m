function time = estimateCharacterizationTime(Grid,Tx)
xyTime = Grid.xPoints*Grid.yPoints*(50+Grid.pause);
yzTime = Grid.zPoints*Grid.yPoints*(50+Grid.pause);
xzTime = Grid.zPoints*Grid.xPoints*(50+Grid.pause);

lambda = 1490/Tx.frequency;

findCenterTime = (ceil(21/lambda))^2*120+5*4*ceil(21/lambda)*200;

total = xyTime+yzTime+xzTime+findCenterTime;
total = total/1e3;

hours = floor(total/3600);
minutes = round((total-hours*3600)/60);
time = [num2str(hours),':',num2str(minutes)];