% close all
passed = true(size(tData));
% passed(isnan(passed)) = 1;
% passed = ~passed;
idxNan = find(isnan(passed));
passed(idxNan) = false;

validDelays = 0;
threshold = 20;
task = 0;
idx10 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,10,[],[],passed,task);
idx10_48 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,10,0.48,[],passed,task);
idx10_65 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,10,0.65,[],passed,task);
idx10_85 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,10,0.85,[],passed,task);

idx50 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,50,[],[],passed,task);
idx50_48 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,50,0.48,[],passed,task);
idx50_65 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,50,0.65,[],passed,task);
idx50_85 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,50,0.85,[],passed,task);

idx100 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,100,[],[],passed,task);
idx100_48 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,100,0.48,[],passed,task);
idx100_65 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,100,0.65,[],passed,task);

[ses10,~,lLgn10,rLgn10,ctl10] = plotContraChoices(tData(idx10),'delays',validDelays);
[ses10_48,~,lLgn10_48,rLgn10_48,ctl10_48] = plotContraChoices(tData(idx10_48),'delays',validDelays);
[ses10_65,~,lLgn10_65,rLgn10_65,ctl10_65] = plotContraChoices(tData(idx10_65),'delays',validDelays);
[ses10_85,~,lLgn10_85,rLgn10_85,ctl10_85] = plotContraChoices(tData(idx10_85),'delays',validDelays);

[ses50,~,lLgn50,rLgn50,ctl50] = plotContraChoices(tData(idx50),'delays',validDelays);
[ses50_48,~,lLgn50_48,rLgn50_48,ctl50_48] = plotContraChoices(tData(idx50_48),'delays',validDelays);
[ses50_65,~,lLgn50_65,rLgn50_65,ctl50_65] = plotContraChoices(tData(idx50_65),'delays',validDelays);
[ses50_85,~,lLgn50_85,rLgn50_85,ctl50_85] = plotContraChoices(tData(idx50_85),'delays',validDelays);

[ses100,~,lLgn100,rLgn100,ctl100] = plotContraChoices(tData(idx100),'delays',validDelays);
[ses100_48,~,lLgn100_48,rLgn100_48,ctl100_48] = plotContraChoices(tData(idx100_48),'delays',validDelays);
[ses100_65,~,lLgn100_65,rLgn100_65,ctl100_65] = plotContraChoices(tData(idx100_65),'delays',validDelays);

generateErrBars(100*ses10,100*ses10_48,100*ses10_65,100*ses10_85,nan,...
    100*ses50,100*ses50_48,100*ses50_65,nan,...
    100*ses100_65,...
    'xlabels',{'10% All','10% 480','10% 650','10% 850','',...
    '50% All','50% 480','50% 650','',...
    '100% 650'},'compareTo',50,'yaxis',[40,60]);
ylabel('% Contralateral Choices')

text(0.5,-5,['n=',num2str(length(idx10))]);
text(1.5,-5,['n=',num2str(length(idx10_48))]);
text(2.5,-5,['n=',num2str(length(idx10_65))]);
text(3.5,-5,['n=',num2str(length(idx10_85))]);

text(5.5,-5,['n=',num2str(length(idx50))]);
text(6.5,-5,['n=',num2str(length(idx50_48))]);
text(7.5,-5,['n=',num2str(length(idx50_65))]);

text(9.5,-5,['n=',num2str(length(idx100))]);

%% 650 kHz Only
generateErrBars(100*ses10_65,100*ses50_65,100*ses100_65,...
    'xlabels',{'10%','50%','100%'},...
    'compareTo',50,...
    'yaxis',[40,60]);
ylabel('% Contralateral Choices')

%% ANOVA
clear lm
lm(:,1) = ses10_65;
if length(ses50_65)>length(ses10_65)
    lm = [lm;nan(length(ses50_65)-length(ses10_65),1)];
    lm(:,2) = ses50_65;
else
    lm(1:length(ses50_65),2) = ses50_65;
end

if length(ses100_65)>size(lm,1)
    lm = [lm;nan(length(ses100_65)-size(lm,1),2)];
    lm(:,3) = ses100_65;
else
    lm(1:length(ses100_65),3) = ses50_65;
end
lm(lm==0) = nan;
anova1(lm);

%% Linear fit
lm = fitlm([10,50,100],[mean(ses10_65),mean(ses50_65),mean(ses100_65)]);

%% Left vs Right
h = figure;
ax = gca;
barColors(1,:) = ax.ColorOrder(1,:);
barColors(2,:) = ax.ColorOrder(3,:);
barColors(3,:) = ax.ColorOrder(2,:);
barColors(4,:) = ax.ColorOrder(2,:);
barColors(5,:) = ax.ColorOrder(1,:);
barColors(6,:) = ax.ColorOrder(3,:);
barColors(7,:) = ax.ColorOrder(2,:);
barColors(8,:) = ax.ColorOrder(2,:);
barColors(9,:) = ax.ColorOrder(1,:);
barColors(10,:) = ax.ColorOrder(3,:);
barColors(11,:) = ax.ColorOrder(2,:);

generateErrBars(100*lLgn10_65,100*ctl10_65,100*rLgn10_65,nan,...
    100*lLgn50_65,100*ctl50_65,100*rLgn50_65,nan,...
    100*lLgn100_65,100*ctl100_65,100*rLgn100_65,...
    'xlabels',{'Left LGN, 10%','No US','Right LGN 10%','',...
    'Left LGN, 50%','No US','Right LGN 50%','',...
    'Left LGN, 100%','No US','Right LGN 100%','',},...
    'compareTo',50,'yaxis',[20,50],...
    'barColors',barColors);
ylabel('% Leftward Choices')

%% Session averaged Sigmoids
