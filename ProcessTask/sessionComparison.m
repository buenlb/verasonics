close all
passed = true(size(tData));
% passed(isnan(passed)) = 1;
% passed = ~passed;
idxNan = find(isnan(passed));
passed(idxNan) = false;

validDelays = 0;
threshold = 20;
task = 0;

% p_voltages = [10.3];
p_voltages = [5.8,15,24];
% p_dc = [10,100];
p_dc = [10,50,100];
p_freq = [0.65];

ses = cell(length(p_voltages),length(p_dc),length(p_freq));
idx = cell(length(p_voltages),length(p_dc),length(p_freq));
validIdx = idx;

% Number of trials to include
nTrials = [];

% Ignore non-US Trials
ignorePreTrials = 0;

% v2p = 72.8;
v2p = 51.2;

for ii = 1:length(p_voltages)
    for jj = 1:length(p_dc)
        for kk = 1:length(p_freq)
            disp(['DC: ', num2str(p_dc(jj)), '%, Pressure: ', num2str(p_voltages(ii)*v2p),' MPa, Freq: ', num2str(p_freq(kk)), 'MHz.'])
            idx{ii,jj,kk} = selectSessions(tData,threshold,validDelays,dc,freq,voltage,p_dc(jj),p_freq(kk),p_voltages(ii),passed,task);
            
            for ll = 1:length(idx{ii,jj,kk})
                tDataIdx = idx{ii,jj,kk}(ll);
                preTrials = tData(tDataIdx).preUsTrials;
                if preTrials == 0
                    preTrials = 1;
                end
                if isempty(nTrials)
                    if ignorePreTrials
                        curIdx = preTrials:length(tData(tDataIdx).ch);
                    else
                        curIdx = 1:length(tData(tDataIdx).ch);
                    end
                else
                    if ignorePreTrials
                        curIdx = (preTrials+nTrials(1)):(nTrials(end)+preTrials);
                    else
                        curIdx = 1:nTrials;
                    end
                end
                curIdx = curIdx(curIdx<length(tData(tDataIdx).ch));
                
                % Remove trials where the voltage changed (this means I
                % quite sonicating)
                
                % I didn't record voltage on each trial in the earlest
                % trials. Detect these cases and make sure those trials
                % don't get thrown out
                if sum(~isnan(tData(tDataIdx).leftVoltage))==0
                    voltageIdx = true(size(curIdx))';
                else
                    voltageIdx = tData(tDataIdx).leftVoltage(curIdx) == p_voltages(ii)...
                        & tData(tDataIdx).rightVoltage(curIdx) == p_voltages(ii);
                end
                
                % Remove trials where there was a long pause before the
                % sonication
                if 0
                    trDelay = [tData(tDataIdx).timing(curIdx).startTime];
                    trDelay = [0,diff(trDelay)];
                    delayIdx = trDelay'<20;
                else
                    delayIdx = true(size(curIdx))';
                end
                
%                 if length(delayIdx)>nTrials
%                     delayIdx = delayIdx(1:nTrials);
%                     voltageIdx = voltageIdx(1:nTrials);
%                 end
%                 
                curIdx = curIdx(voltageIdx & delayIdx);
                if isempty(curIdx)
                    keyboard
                end
                validIdx{ii,jj,kk}{ll} = curIdx;
            end
            ses{ii,jj,kk} = plotContraChoices(tData(idx{ii,jj,kk}),'delays',validDelays,'index',validIdx{ii,jj,kk});
%             keyboard
            ses{ii,jj,kk} = ses{ii,jj,kk}(~isnan(ses{ii,jj,kk}));
            if isempty(idx{ii,jj,kk})
                xLabels{ii,jj,kk} = '';
            else
                xLabels{ii,jj,kk} = [num2str(p_dc(jj)),'% DC ', num2str(p_voltages(ii)*v2p*1e-3,2), ' MPa'];
            end
        end
    end
end
% ses{p_voltages==24,p_dc==100,p_freq==0.65} = nan;
generateErrBarsCell(ses','compareTo',0.5,'xlabels',xLabels','nsessions',1)
return
%% 10 Percent
idx10 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,10,[],10.3,passed,task);
idx10_48 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,10,0.48,[],passed,task);
idx10_65 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,10,0.65,10.3,passed,task);
idx10_85 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,10,0.85,[],passed,task);

% 10 Percent, 1.2 MPa
% idx10_65_1p2 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,10,[],24,passed,task);

%50 Percent
idx50 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,50,[],[],passed,task);
idx50_48 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,50,0.48,[],passed,task);
idx50_65 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,50,0.65,[],passed,task);
idx50_85 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,50,0.85,[],passed,task);

% 100 Percent
idx100 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,100,[],[],passed,task);
idx100_48 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,100,0.48,10.3,passed,task);
idx100_65 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,100,0.65,[],passed,task);

% 100 Percent, 1.2 MPa
% idx100_65_1p2 = selectSessions(tData,threshold,validDelays,dc,freq,voltage,100,[],24,passed,task);

[ses10,~,lLgn10,rLgn10,ctl10] = plotContraChoices(tData(idx10),'delays',validDelays);
[ses10_48,~,lLgn10_48,rLgn10_48,ctl10_48] = plotContraChoices(tData(idx10_48),'delays',validDelays);
[ses10_65,~,lLgn10_65,rLgn10_65,ctl10_65] = plotContraChoices(tData(idx10_65),'delays',validDelays);
[ses10_85,~,lLgn10_85,rLgn10_85,ctl10_85] = plotContraChoices(tData(idx10_85),'delays',validDelays);

% [ses10_65_1p2,~,lLgn10_65_1p2,rLgn10_65_1p2,ctl10_65_1p2] = plotContraChoices(tData(idx10_65_1p2),'delays',validDelays);

[ses50,~,lLgn50,rLgn50,ctl50] = plotContraChoices(tData(idx50),'delays',validDelays);
[ses50_48,~,lLgn50_48,rLgn50_48,ctl50_48] = plotContraChoices(tData(idx50_48),'delays',validDelays);
[ses50_65,~,lLgn50_65,rLgn50_65,ctl50_65] = plotContraChoices(tData(idx50_65),'delays',validDelays);
[ses50_85,~,lLgn50_85,rLgn50_85,ctl50_85] = plotContraChoices(tData(idx50_85),'delays',validDelays);

[ses100,~,lLgn100,rLgn100,ctl100] = plotContraChoices(tData(idx100),'delays',validDelays);
[ses100_48,~,lLgn100_48,rLgn100_48,ctl100_48] = plotContraChoices(tData(idx100_48),'delays',validDelays);
[ses100_65,~,lLgn100_65,rLgn100_65,ctl100_65] = plotContraChoices(tData(idx100_65),'delays',validDelays);

% [ses100_65_1p2,~,lLgn100_65_1p2,rLgn100_65_1p2,ctl100_65_1p2] = plotContraChoices(tData(idx100_65_1p2),'delays',validDelays);

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

%% Pressure changes
generateErrBars(100*ses10_65,100*ses10_65_1p2,nan,100*ses100_65,...
    'xlabels',{'10 %, 0.75 MPa','10 %, 1.2 MPa','','100 %, 0.75 MPa'},...
    'compareTo', 50);
return
%% ANOVA
clear lm
ses10_65 = ses{2,1};
ses50_65 = ses{2,2};
ses100_65 = ses{2,3}(1:18);
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
[~,tbl] = anova1(lm);
% for t = 2 : size(tbl, 1) - 2
%     fprintf('%s \t F(%d,%d) = %.2g, p = %.2g\n', tbl{t, 1}, tbl{t, 3}, tbl{size(tbl, 1) - 1, 3}, tbl{t, 6}, tbl{t, 7});
% end

%% ANOVAN
clear lm group
lm = [ses10_65,ses50_65,ses100_65];
[group{1:length(ses10_65)}] = deal('10');
[group{(length(ses10_65)+1):(length(ses50_65)+length(ses10_65))}] = deal('50');
[group{(length(ses10_65)+length(ses50_65)+1):(length(ses100_65)+length(ses50_65)+length(ses10_65))}] = deal('100');
[~,tbl] = anovan(lm,{group},'model', 'linear', 'varnames', {'magnet'}, 'display', 'off');
for t = 2 : size(tbl, 1) - 2
    fprintf('%s \t F(%d,%d) = %.2g, p = %.2g\n', tbl{t, 1}, tbl{t, 3}, tbl{size(tbl, 1) - 1, 3}, tbl{t, 6}, tbl{t, 7});
end

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
