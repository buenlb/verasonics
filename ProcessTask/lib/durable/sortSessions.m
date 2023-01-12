% Sorts the sessions in tData by the ultrasound parameters applied and the
% monkeys they were applied in.
% 
% @INPUTS
%   tData: struct created by loadMonk
%   monk: array with the first initial of the monkey in which each session
%       in tData was acquired
%   precision: decimal precision to apply when comparing voltages. The
%       voltage is rounded to have the specified number of digits after the
%       decimal point before comparison.
% 
% @OUTPUTS
%   sessions: Struct containing the following fields:
%       PRF: pulse repetition frequency (Hz)
%       dc: duty cycle (%)
%       duration: sonication duration (s)
%       freq: center frequency (MHz)
%       voltage: voltage applied in verasonics (V)
%       monk: first initial of the animal in which the session was
%         collected
%       sessions: Indices of sessions that share the above characteristics
% 
% Taylor Webb
% University of Utah
% December 2022

function sessions = sortSessions(tData, monk, precision)

prf = [];
dc = [];
duration = [];
freq = [];
voltage = [];
monkS = [];
foci = [];
focalLocation = [];

setIdx = 1;

for ii = 1:length(tData)
    curPrf = tData(ii).sonication.prf;
    curDc = round(tData(ii).sonication.dc,1);
    curDuration = tData(ii).sonication.dur;
    curFreq = tData(ii).sonication.freq;
    curVoltage = round(tData(ii).sonication.voltage,precision);
    curMonk = monk(ii);
    curFocalLocation = tData(ii).sonication.focalLocation;
    tData(ii).sonication.nFoci(tData(ii).sonication.nFoci==1) = 0;
    curFoci = sum(tData(ii).sonication.nFoci);
    if curFoci>0
        curPrf = curPrf/curFoci;
        curDc = curDc/curFoci;
    end
    
    [existingParams,existingIdx] = multipleIsMember(curPrf,curDc,curDuration,...
        curFreq,curVoltage,curMonk,curFoci,...
        prf,dc,duration,freq,voltage,monkS,foci);

    if sum(existingParams) < length(existingParams) || isempty(existingIdx) % Create a new set
        prf(setIdx) = curPrf; %#ok<*AGROW> 
        dc(setIdx) = curDc;
        duration(setIdx) = curDuration;
        freq(setIdx) = curFreq;
        voltage(setIdx) = curVoltage;
        monkS(setIdx) = curMonk;
        foci(setIdx) = curFoci;
        focalLocation(setIdx,:) = curFocalLocation;
        
        sessions(setIdx) = struct('PRF',curPrf,'dc',curDc,'duration',curDuration,...
            'pulseDuration',1/curPrf*curDc/100,'voltage',curVoltage,'freq',curFreq,...
            'monk',curMonk,'sessionsLeft',[],'sessionsRight',[],'sessionsCtl',[], ...
            'nFoci',curFoci,'focalLocation',curFocalLocation);
        if tData(ii).sonication.focalLocation(1)<0
            sessions(setIdx).sessionsLeft = ii;
        elseif tData(ii).sonication.focalLocation(1)>0
            sessions(setIdx).sessionsRight = ii;
        elseif isnan(tData(ii).sonication.focalLocation(1))
            sessions(setIdx).sessionsCtl = ii;
        else
            error('Invalid LGN Value!')
        end
        setIdx = setIdx+1;
    else % This set already exists
        if tData(ii).sonication.focalLocation(1)<0
            sessions(existingIdx).sessionsLeft(end+1) = ii;
        elseif tData(ii).sonication.focalLocation(1)>0
            sessions(existingIdx).sessionsRight(end+1) = ii;
        elseif isnan(tData(ii).sonication.focalLocation(1))
            sessions(existingIdx).sessionsCtl(end+1) = ii;
        else
            error('Invalid LGN Value!')
        end
    end

end