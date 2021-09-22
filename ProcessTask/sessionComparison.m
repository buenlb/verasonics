close all
passed = passInitial;
idxNan = find(isnan(passed));
passed(idxNan) = passed(idxNan-1);

threshold = 50;
task = 0;
idx10 = selectSessions(tData,threshold,dc,freq,voltage,10,[],[],passed,task);
idx10_48 = selectSessions(tData,threshold,dc,freq,voltage,10,0.48,[],passed,task);
idx10_65 = selectSessions(tData,threshold,dc,freq,voltage,10,0.65,[],passed,task);
idx10_85 = selectSessions(tData,threshold,dc,freq,voltage,10,0.85,[],passed,task);

idx50 = selectSessions(tData,threshold,dc,freq,voltage,50,[],[],passed,task);
idx50_48 = selectSessions(tData,threshold,dc,freq,voltage,50,0.48,[],passed,task);
idx50_65 = selectSessions(tData,threshold,dc,freq,voltage,50,0.65,[],passed,task);
idx50_85 = selectSessions(tData,threshold,dc,freq,voltage,50,0.85,[],passed,task);

idx100 = selectSessions(tData,threshold,dc,freq,voltage,100,[],[],passed,task);
idx100_48 = selectSessions(tData,threshold,dc,freq,voltage,100,0.48,[],passed,task);
idx100_65 = selectSessions(tData,threshold,dc,freq,voltage,100,0.65,[],passed,task);

ses10 = plotContraChoices(tData(idx10));
ses10_48 = plotContraChoices(tData(idx10_48));
ses10_65 = plotContraChoices(tData(idx10_65));
ses10_85 = plotContraChoices(tData(idx10_85));

ses50 = plotContraChoices(tData(idx50));
ses50_48 = plotContraChoices(tData(idx50_48));
ses50_65 = plotContraChoices(tData(idx50_65));
% ses50_85 = plotContraChoices(tData(idx50_85));

ses100 = plotContraChoices(tData(idx100));
% ses100_48 = plotContraChoices(tData(idx100_48));
ses100_65 = plotContraChoices(tData(idx100_65));

generateErrBars(100*ses10,100*ses10_48,100*ses10_65,100*ses10_85,nan,...
    100*ses50,100*ses50_48,100*ses50_65,nan,...
    100*ses100_65,...
    'xlabels',{'10% All','10% 480','10% 650','10% 850','',...
    '50% All','50% 480','50% 650','',...
    '100% 650'},'compareTo',50,'yaxis',[40,60]);
ylabel('% Contralateral Choices')