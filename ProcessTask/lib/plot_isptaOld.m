%% plot_ispta
% This code takes the data in v and dc to make a plot of where on the
% DC/Intensity axis data has been acquired
% 
% @INPUTS
%   v: voltage in Volts peak for each session
%   dc: duty cycle (percent) for each session
%   monk: character array identifying which monkey each session comes from
%   minS: Minimum number of sessions available for a point to be included.
%     This includes all sessions from either LGN or from control.
%   tData: data struct returned by processTaskDataDurable
% 
% @OUTPUTS (Need to be updated - the first three haven't been coded yet)
%   I: spatial peak temporal peak intensity of each group of sessions
%   Ispta: spatial peak temporal average intensity of each group of
%     sessions
%   monkS: Monkey that each group of sessions corresponds to
%   idx: Cell array with indices representing the session that compose each
%     point on the graph
%   sideSonicated: Cell array the same size as idx identifying which side
%     was sonicated during each specified session.
%   I_all: spatial peak temporal peak intensity of each session
%   Ispta_all: spatial peak temporal average intensity of each session
% 
% Taylor Webb
% taylorwebb85@gmail.com

function [I, Ispta, monkS, idx, sideSonicated, I_all, Ispta_all] = plot_ispta(v,dc,monk,tData,minS)

if ~exist('minS','var')
    minS = 0;
end

freqs = [480,650,850];
% bConversion = [64.4,105,53.1];
% eConversion = [46,75,37.9];
bConversion = [55.2 nan nan];
eConversion = [55.2 nan nan];
conversion = nan(size(v));
sonFreqs = 480*ones(size(v));
for ii = 1:length(freqs)
    conversion(sonFreqs==freqs(ii) & monk=='b') = bConversion(ii);
    conversion(sonFreqs==freqs(ii) & monk=='e') = eConversion(ii);
end

p = v.*conversion*1e-3;
I_all = nan(size(p));
for ii = 1:length(p)
    I_all(ii) = p2I_brain(p(ii)*1e6)/1e4;
end
% I_all = round(I_all/10)*10;
Ispta_all = I_all.*dc;

idxE = monk == 'e';
idxB = monk == 'b';

sesCounter = 1;
ss = nan(size(v));
Ispta = [];
I = [];
for ii = 1:length(v)
    if sum(isnan(tData(ii).sonicationProperties.FocalLocation)) % CTL
        ss(ii) = 0;
    elseif sum(tData(ii).lgn)<0
        ss(ii) = -1;
    elseif sum(tData(ii).lgn)>0
        ss(ii) = 1;        
    end
    if sum(Ispta_all == Ispta_all(ii) & monk == 'b' & I_all == I_all(ii) & dc==dc(ii))<minS
        idxB(ii) = 0;
    else
        if (~ismember(Ispta_all(ii), Ispta) || ~ismember(I_all(ii),I)) && monk(ii) == 'b'
            I(sesCounter) = I_all(ii);
            Ispta(sesCounter) = Ispta_all(ii);
            idx{sesCounter} = find(Ispta_all == Ispta_all(ii) & monk == 'b' & I_all == I_all(ii) & dc==dc(ii));
            monkS(sesCounter) = 'b';
            sesCounter = sesCounter+1;
        end
    end
    if sum(Ispta_all == Ispta_all(ii) & monk == 'e' & I_all == I_all(ii) & dc==dc(ii))<minS
        idxE(ii) = 0;
    else
        if (~ismember(Ispta_all(ii), Ispta) || ~ismember(I_all(ii),I)) && monk(ii) == 'e'
            I(sesCounter) = I_all(ii);
            Ispta(sesCounter) = Ispta_all(ii);
            idx{sesCounter} = find(Ispta_all == Ispta_all(ii) & monk == 'e' & I_all == I_all(ii) & dc==dc(ii));
            monkS(sesCounter) = 'e';
            sesCounter = sesCounter+1;
        end
    end
end
sideSonicated = cell(size(idx));
for ii = 1:length(idx)
    sideSonicated{ii} = ss(idx{ii});
end

maxI = max([max(I_all(idxE)), max(I_all(idxB)), 80]);
x = linspace(0,maxI,1e3);
y1 = 100*0.72./x;
y2 = 100*2*0.72./x;
y3 = 100*0.5*0.72./x;
% y3 = 100*4*0.72./x;
% y4 = 100*8*0.72./x;
h = figure;
ax = gca;
hold on
plt(1,1) = plot(I_all(idxE),100*dc(idxE),'o','LineWidth',2,'MarkerSize',8);
plt(2,1) = plot(I_all(idxB),100*dc(idxB),'^','LineWidth',2,'MarkerSize',8);
ax.ColorOrderIndex = 3;
% plt2 = plot(x,y1,'--',x,y2,'--',x,y3,'--','linewidth',2);
plt2 = plot(x,y1,'--',x,y2,'--','linewidth',2);
legend([plt;plt2],'Euler','Boltzmann','510(k)','2*510(k)')
% legend([plt;plt2],'Euler','510(k)','2*510(k)')
xlabel('I_{SPPA} (W/cm^2)')
ylabel('DC (%)')
axis([0,maxI,0,20])
makeFigureBig(h);