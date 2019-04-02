function [vpp,vIn,v1,t] = readEfficiencyData(folder, fileBase,plotWvs,cal)

if nargin < 3
    plotWvs = 0;
elseif nargin < 4
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
    [t,v] = readWaveform([folder,wvForms(ii).name]);
    vIn(ii) = findNextNumber(wvForms(ii).name,1);
    vpp(ii) = -min(v);
%     dt = t(2)-t(1);
%     v2 = v(t>100& t < 200);
%     f = linspace(-1/(2*dt),1/(2*dt),length(v2));
%     vpp(ii) = 2*max(abs(fft(v2)))/(length(f));

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