function [sys,temporal,spatial] = processAndDisplayThermalStd(sys,maxT,sonicationNo)
if nargin < 2
    maxT = 2;
end
sys.baseline = 1:5;
%% Get the MR Data and describe it
if nargin < 3
    sonication.duration = 0;
    sonication.voltage = 0;
    sonication.time = now;
    sonication.focalSpot = sys.focalSpot;
    sonication.focalSpotIdx = sys.focalSpotIdx;
    sonication.focalSpotMr = sys.focalSpotMr;
    sonication.description = input('Describe this thermal iamge: ', 's');
    sonication.firstDynamic = input('What dynamic is the first dynamic?');
    userInput = input('Press enter when files are ready (input s to skip).','s');
    if ~strcmp(userInput, 's')
        try
            [img,header,seriesNo] = sortDicoms(sys.incomingDcms, sys.mrPath);
            sonication.phaseSeriesNo = seriesNo(2);
            sonication.magSeriesNo = seriesNo(1);
        catch
            % Just in case this errors - save the sonication
            sonication.phaseSeriesNo = 0;
            sonication.magSeriesNo = 0;
            if ~isfield(sys,'sonication')
                sys.sonication = sonication;
            else
                sys.sonication(end+1) = sonication;
            end
            warning('Failure to load dicoms!')
            return
        end
    else
        sonication.phaseSeriesNo = 0;
        sonication.magSeriesNo = 0;
        if isfield(sys,'sonication')
            sys.sonication(end+1) = sonication;
        else
            sys.sonication = sonication;
        end
        return
    end
    if isfield(sys,'sonication')
        sys.sonication(end+1) = sonication;
    else
        sys.sonication = sonication;
    end
    sonicationNo = length(sys.sonication);
end

sys = adjustFocus(sys,sys.sonication(sonicationNo).focalSpot,'US');

%% Interpolate standard deviation onto anatomy image
[temporal,spatial] = standardDevTherm(sys,sonicationNo);

sys.tInterp = temporal;

%% Convert to true color image
sys = draw3dTempOverlay(sys,[0.5,maxT],1);

%% Display result in GUI
sys.dynamic = 0;
orthogonalTemperatureViewsGui(sys);