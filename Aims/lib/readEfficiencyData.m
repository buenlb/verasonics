function [vpp,vIn,v1,t,position] = readEfficiencyData(folder, fileBase,FgParams,plotWvs,cal)

if nargin < 4
    plotWvs = 0;
elseif nargin < 5
    cal = 1;
    yLab = 'voltage (V)';
else
    yLab = 'pressure (MPa)';
end

if plotWvs
    h = figure(99);
end

wvForms = dir([folder,fileBase,'*']);

vIn = zeros(size(wvForms));
vpp = vIn;
for ii = 1:length(wvForms)
    [t,v,position] = readWaveform([folder,wvForms(ii).name]);
    vIn(ii) = findNextNumber(wvForms(ii).name,1);
    vpp(ii) = findPeakNegativeVoltage(v,FgParams.nCycles);
    if plotWvs
        rows = ceil(sqrt(length(wvForms)));
        cols = floor(sqrt(length(wvForms)));
        if rows*cols < length(wvForms)
            cols = cols+1;
        end
        figure(h)
        subplot(rows,cols,ii)
        plot(t,v/cal*1e-6)
        xlabel('time (\mus)')
        ylabel(yLab)
        title(['FV Voltage: ', num2str(vIn(ii))])
    end
        
    
    if ii == 1
        v1 = v;
    end
end