%% plot_ispta
% This code takes the data in vAll and dcAll to make a plot of where on the
% DC/Intensity axis data has been acquired
% 
% @INPUTS
%   vAll: voltage in Volts peak for each session
%   dcAll: duty cycle (percent) for each session
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

function [I, Ispta, v, dc, prf, monkS, idx, sideSonicated, I_all, Ispta_all, vAll, dcAll] = plot_ispta(tData,monk,minS)

% Get sonication parameters
sonication = [tData.sonication];
vAll = [sonication.voltage];
dcAll = [sonication.dc]/100;
dcAll = round(dcAll,4);
prfAll = [sonication.prf];
nFoci = zeros(size(tData));
for ii = 1:length(tData)
    nFoci(ii) = sum(sonication(ii).nFoci);
end
dcAll(nFoci>0) = dcAll(nFoci>0)./nFoci(nFoci>0);
prfAll(nFoci>0) = prfAll(nFoci>0)./nFoci(nFoci>0);

if ~exist('minS','var')
    minS = 0;
end

freqs = [480,650,850];
% bConversion = [64.4,105,53.1];
% eConversion = [46,75,37.9];
bConversion = [55.2 nan nan];
eConversion = [55.2 nan nan];
conversion = nan(size(vAll));
sonFreqs = 480*ones(size(vAll));
for ii = 1:length(freqs)
    conversion(sonFreqs==freqs(ii) & monk=='b') = bConversion(ii);
    conversion(sonFreqs==freqs(ii) & monk=='e') = eConversion(ii);
    conversion(sonFreqs==freqs(ii) & monk=='c') = eConversion(ii);
    conversion(sonFreqs==freqs(ii) & monk=='h') = eConversion(ii);
end

p = vAll.*conversion*1e-3;
I_all = nan(size(p));
for ii = 1:length(p)
    I_all(ii) = p2I_brain(p(ii)*1e6)/1e4;
end
% I_all = round(I_all/10)*10;
Ispta_all = I_all.*dcAll;

idxE = monk == 'e';
idxB = monk == 'b';
idxC = monk == 'c';
idxH = monk == 'h';

sesCounter = 1;
ss = nan(size(vAll));
Ispta = [];
I = [];
for ii = 1:length(vAll)
    if isnan(tData(ii).sonication.focalLocation(1))
        ss(ii) = 0;
    elseif tData(ii).sonication.focalLocation(1)<0
        ss(ii) = -1;
    elseif tData(ii).sonication.focalLocation(1)>0
        ss(ii) = 1;        
    end
    if sum(Ispta_all == Ispta_all(ii) & monk == 'b' & I_all == I_all(ii) & dcAll==dcAll(ii))<minS
        idxB(ii) = 0;
    else
        if (~ismember(Ispta_all(ii), Ispta) || ~ismember(I_all(ii),I)) && monk(ii) == 'b'
            I(sesCounter) = I_all(ii);
            Ispta(sesCounter) = Ispta_all(ii);
            dc(sesCounter) = dcAll(ii);
            v(sesCounter) = vAll(ii);
            prf(sesCounter) = prfAll(ii);
            idx{sesCounter} = find(Ispta_all == Ispta_all(ii) & monk == 'b' & I_all == I_all(ii) & dcAll==dcAll(ii));
            monkS(sesCounter) = 'b';
            sesCounter = sesCounter+1;
        end
    end
    if sum(Ispta_all == Ispta_all(ii) & monk == 'e' & I_all == I_all(ii) & dcAll==dcAll(ii))<minS
        idxE(ii) = 0;
    else
        if (~ismember(Ispta_all(ii), Ispta) || ~ismember(I_all(ii),I)) && monk(ii) == 'e'
            I(sesCounter) = I_all(ii);
            Ispta(sesCounter) = Ispta_all(ii);
            dc(sesCounter) = dcAll(ii);
            v(sesCounter) = vAll(ii);
            prf(sesCounter) = prfAll(ii);
            idx{sesCounter} = find(Ispta_all == Ispta_all(ii) & monk == 'e' & I_all == I_all(ii) & dcAll==dcAll(ii));
            monkS(sesCounter) = 'e';
            sesCounter = sesCounter+1;
        end
    end

    if sum(Ispta_all == Ispta_all(ii) & monk == 'c' & I_all == I_all(ii) & dcAll==dcAll(ii))<minS
        idxC(ii) = 0;
    else
        if (~ismember(Ispta_all(ii), Ispta) || ~ismember(I_all(ii),I)) && monk(ii) == 'c'
            I(sesCounter) = I_all(ii);
            Ispta(sesCounter) = Ispta_all(ii);
            dc(sesCounter) = dcAll(ii);
            v(sesCounter) = vAll(ii);
            prf(sesCounter) = prfAll(ii);
            idx{sesCounter} = find(Ispta_all == Ispta_all(ii) & monk == 'c' & I_all == I_all(ii) & dcAll==dcAll(ii));
            monkS(sesCounter) = 'c';
            sesCounter = sesCounter+1;
        end
    end
    if sum(Ispta_all == Ispta_all(ii) & monk == 'h' & I_all == I_all(ii) & dcAll==dcAll(ii))<minS
        idxH(ii) = 0;
    else
        if (~ismember(Ispta_all(ii), Ispta) || ~ismember(I_all(ii),I)) && monk(ii) == 'h'
            I(sesCounter) = I_all(ii);
            Ispta(sesCounter) = Ispta_all(ii);
            dc(sesCounter) = dcAll(ii);
            v(sesCounter) = vAll(ii);
            prf(sesCounter) = prfAll(ii);
            idx{sesCounter} = find(Ispta_all == Ispta_all(ii) & monk == 'h' & I_all == I_all(ii) & dcAll==dcAll(ii));
            monkS(sesCounter) = 'h';
            sesCounter = sesCounter+1;
        elseif ~sum(monkS(Ispta_all(ii) == Ispta)=='h')
            I(sesCounter) = I_all(ii);
            Ispta(sesCounter) = Ispta_all(ii);
            dc(sesCounter) = dcAll(ii);
            v(sesCounter) = vAll(ii);
            prf(sesCounter) = prfAll(ii);
            idx{sesCounter} = find(Ispta_all == Ispta_all(ii) & monk == 'h' & I_all == I_all(ii) & dcAll==dcAll(ii));
            monkS(sesCounter) = 'h';
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
p1 = plot(I_all(idxE),100*dcAll(idxE),'o','LineWidth',2,'MarkerSize',8);
p2 = plot(I_all(idxB),100*dcAll(idxB),'^','LineWidth',2,'MarkerSize',8);
p3 = plot(I_all(idxE),100*dcAll(idxE),'o','LineWidth',2,'MarkerSize',8);
p4 = plot(I_all(idxB),100*dcAll(idxB),'^','LineWidth',2,'MarkerSize',8);
ax.ColorOrderIndex = 3;
% plt2 = plot(x,y1,'--',x,y2,'--',x,y3,'--','linewidth',2);
plt2 = plot(x,y1,'--',x,y2,'--','linewidth',2);
% legend([plt;plt2],'Euler','Boltzmann','510(k)','2*510(k)')
% legend([plt;plt2],'Euler','510(k)','2*510(k)')
xlabel('I_{SPPA} (W/cm^2)')
ylabel('DC (%)')
axis([0,maxI,0,20])
makeFigureBig(h);