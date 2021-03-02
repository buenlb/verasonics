% processTaskData plots sigmoids for the task result and returns a struct
% with the results
% 
% @INPUTS
%   fName: file name from which to load the task data structure. This file
%       must contain the task_data struct created by the server.
%   plotResults: Optional, specify whether or not to plot results. Defaults
%       to 0
% 
% @OUTPUTS
%   tData: struct with fields:
%         result: a vector with a 1 for each trial in which a correct 
%           choice was made, a zero for incorrect choices, 2 if a 
%           contra-hemifield result is detected, 3 if no fixation was
%           achieved, 4 if he fixated but broke it pre-maturely, and 5 if
%           he fixated by failed to make a choice.
%         lgn: -1 if the left LGN was sonicated, 1 if it was the right, and
%           0 if no LGN was sonicated
%         delay: delay in ms used for each trial
%         delayVector: List of all possible delays
%         ch: 1 for a leftward choice, 0 for a rightward choice, nan if no
%           choice was made
% 
% Taylor Webb
% University of Utah

function tData = processTaskData(fName,plotResults)

if nargin < 2
    plotResults = 0;
end

trialData = load(fName);
trial_data = trialData.trial_data;

% Sometimes it populates a trial that doesn't finish. If this is the case,
% get rid of that trial.
if ~isfield(trial_data{end},'us')
    trial_data = trial_data(1:end-1);
end

% Set up variables
lgn = zeros(size(trial_data));
result = lgn;
delay = lgn;
delayVector = [];
ch = lgn;

% Loop through struct
for ii = 1:length(trial_data)
    if trial_data{ii}.us.priorSonications{ii} == 'L'
        lgn(ii) = -1;
    elseif trial_data{ii}.us.priorSonications{ii} == 'R'
        lgn(ii) = 1;
    elseif trial_data{ii}.us.priorSonications{ii} == 'C'
        lgn(ii) = 0;
    end
    
    switch trial_data{ii}.result{1}
        case 'NOFIX'
            result(ii) = 3;
        case 'CORRECT'
            result(ii) = 1;
        case 'FIXBREAK'
            result(ii) = 4;
        case 'WRONG'
            result(ii) = 0;
        case 'CONTRA_HEMIFIELD'
            result(ii) = 2;
        case 'NOCHOICE'
            result(ii) = 5;
    end
    
    if isfield(trial_data{ii},'choice')
        if ~iscell(trial_data{ii}.choice)
            ch(ii) = nan;
        elseif strcmp(trial_data{ii}.choice{1},'left')
            ch(ii) = 1;
        else
            ch(ii) = 0;
        end
    else
        ch(ii) = nan;
    end
    
    delay(ii) = trial_data{ii}.timingOffset;
    
    if ~ismember(delay(ii),delayVector) && ~isnan(delay(ii))
        delayVector(end+1) = delay(ii); %#ok<AGROW>
    end
end

tData = struct('ch',ch,'delay',delay,'delayVector',delayVector,'lgn',lgn,'result',result);

%% Plot Results
if plotResults
    rightDelay = delay(lgn==1);
    leftDelay = delay(lgn==-1);
    cDelay = delay(lgn==0);
    
    leftCh = ch(lgn==-1);
    rightCh = ch(lgn==1);
    cCh = ch(lgn==0);
    
    rightDelay = rightDelay(~isnan(rightCh));
    rightCh = rightCh(~isnan(rightCh));
    
    leftDelay = leftDelay(~isnan(leftCh));
    leftCh = leftCh(~isnan(leftCh));
    
    cDelay = cDelay(~isnan(cCh));
    cCh = cCh(~isnan(cCh));
    
    h = figure;
    ax1 = axes();
    ax1.Position = [0.07,0.24,0.33,0.72];
    barH = [mean(leftCh),mean(rightCh),mean(cCh)];
    barStd = [std(leftCh)/sqrt(length(leftCh)),std(rightCh)/sqrt(length(rightCh)),std(cCh)/sqrt(length(cCh))];
    bar(2:4,barH);
    hold on
    erBar = errorbar(2:4,barH,barStd);
    erBar.Color = [0,0,0];
    erBar.LineStyle = 'none';
    
    ax1.XTick = 2:4;
    ax1.XTickLabel = {'Left','Right','None'};
    ylabel('Leftward Choices (%)')
    makeFigureBig(h);
    
    ax2 = axes();
    ax2.Position = [0.47,0.24,0.43,0.72];
    sigmoid_plot2(leftDelay',leftCh',1:length(leftCh),ax2.ColorOrder(1,:),4);
    sigmoid_plot2(rightDelay',rightCh',1:length(rightCh),ax2.ColorOrder(2,:),4);
    sigmoid_plot2(cDelay',cCh',1:length(cCh),ax2.ColorOrder(3,:),4);
    ax2.ColorOrderIndex = 1;
    plt = plot(-1,-1,'-',-1,-1,'-',-1,-1,'-','linewidth',2);
    legend(plt,'Left','Right','None','location','northwest')
    xlabel('delay (ms)')
    ylabel('Leftward Choice (%)')
    makeFigureBig(h)
    
    axes(ax1);
    disp('*****Significance*****')
    [h1,p] = ttest2(leftCh,rightCh);
    disp(['Left/Right: p=',num2str(p,2)])
    if h1
        text(2.5,max(barH),'*','FontSize',28)
    end
    
    [h1,p] = ttest2(leftCh,cCh);
    disp(['Left/Ctl: p=',num2str(p,2)])
    if h1
        text(2.5,max(barH),'*','FontSize',28)
    end
    
    [h1,p] = ttest2(cCh,rightCh);
    if h1
        text(2.5,max(barH),'*','FontSize',28)
    end
    disp(['Right/Ctl: p=',num2str(p,2)])
    
    set(h,'position',[0.4880    0.1834    1.3034    0.45]*1e3);

    ax3 = axes();
    ax3.Position = [0.47,0,00.43,0.2];
    hold on
    text(ax2.XLim(1),0,'N Trials','Rotation',90)
    for ii = 1:length(delayVector)
        text(delayVector(ii),0.75,num2str(length(ch(delay == delayVector(ii) & lgn==-1 & result < 3))),'Color',ax3.ColorOrder(1,:))
        text(delayVector(ii),0.45,num2str(length(ch(delay == delayVector(ii) & lgn==1 & result < 3))),'Color',ax3.ColorOrder(2,:))
        text(delayVector(ii),0.15,num2str(length(ch(delay == delayVector(ii) & lgn==0 & result < 3))),'Color',ax3.ColorOrder(3,:))
    end
    axis([ax2.XLim,0,1])
    ax3.Visible  = 'off';
    makeFigureBig(h)
end