function [ispta, vss, ispta_skull] = lStimEnergy(dc,isi,p,duration,totDuration)

dc2 = duration/(isi);
isppa = p2I_brain(p)/1e4;
ispta = isppa*dc*dc2;
ispta_skull = ispta*2;
vss = (p*1e-3/55.2)^2*dc*dc2*totDuration*2*0.6133;