% Plots contralateral choices across sessions
% 
% @INPUTS
%   ds: Days (you can get this from safety.m)
%   y: Matrix of choices referenced to the time slot immediately preceeding
%     US
%   idx: Time index at which to measure contralateral choices
% 
% @OUTPUTS
%   cc: Contralateral choices (percent) at each session

function cc = plotDurableContraChoicesAcrossSessions(ds,y,idx)
if length(ds)~=size(y,1)
    error('Number of days and sessions not matching')
end

y2 = nan(size(ds));
for ii = 1:length(ds)
    y2(ii) = mean(y(ii,idx),'omitnan');
    if isnan(y2(ii))
        keyboard
    end
end

h = figure;
ax = gca;
bar(ds,(y2)*100,'BaseValue',50)
xlabel('Day')
ylabel('Contralateral Choices (%)')
ax.XTick = 0:50:ds(end);
makeFigureBig(h);

cc = y2;