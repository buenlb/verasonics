function gamma = plotEEG(eeg,spectra,tData,idx,pin,t,sWindow,leftRight)
VERBOSE = 1;
threshold = 500;

gamma = nan(length(idx),length(t));
for ii = 1:length(idx)
    if isempty(eeg(idx(ii)).features)
        continue
    end
    spectraIdx = find(eeg(idx(ii)).frequencies >= spectra(1) & eeg(idx(ii)).frequencies < spectra(2));
    switch pin
        case 'both'
            % Throw out data during injection
            baseline = tData(idx(ii)).timing(tData(idx(ii)).sonicatedTrials-1).startTime-...
                tData(idx(ii)).timing(tData(idx(ii)).sonicatedTrials).startTime;
            curIdx = find(eeg(idx(ii)).tFeatures>=baseline-sWindow & eeg(idx(ii)).tFeatures<baseline);
            if VERBOSE
                disp(['Baseline Time: ', num2str(eeg(idx(ii)).tFeatures(curIdx(1))),'-',num2str(eeg(idx(ii)).tFeatures(curIdx(end)))])
            end
            leftPin = eeg(idx(ii)).featuresByPins(leftRight(1),curIdx,spectraIdx);
            rightPin = eeg(idx(ii)).featuresByPins(leftRight(2),curIdx,spectraIdx);
            combined = mean([leftPin;rightPin],2);
            baseline = mean(combined(:));
             for jj = 1:length(t)
                curIdx = find(eeg(idx(ii)).tFeatures>=t(jj)-sWindow & eeg(idx(ii)).tFeatures<t(jj));
                if VERBOSE
                    disp(['  Current Time: ', num2str(eeg(idx(ii)).tFeatures(curIdx(1))),'-',num2str(eeg(idx(ii)).tFeatures(curIdx(end)))])
                end
                if ~isempty(curIdx)
                    leftPin = eeg(idx(ii)).featuresByPins(leftRight(1),curIdx,spectraIdx);
                    rightPin = eeg(idx(ii)).featuresByPins(leftRight(2),curIdx,spectraIdx);
                    combined = mean([leftPin;rightPin],2,'omitnan');
                    gamma(ii,jj) = (mean(combined(:),'omitnan')-baseline)/baseline;
                end
            end
        case 'left'
        case 'right'
        case 'bothPre'
        otherwise
            error('Unrecognized value for pin. Must be both, left, right, or bothPre')
    end
end

%  bsln(ii,:) = mean(curEeg,2,'omitnan');
%     for jj = 1:length(tSmoothed)
%         curIdx = find(eegOutT(ii).tFeatures>=tSmoothed(jj)-sWindow & eegOutT(ii).tFeatures<tSmoothed(jj));
%         curEeg = squeeze(eegOutT(ii).featuresByPins(1,curIdx,:))';
%         featuresRightPin(ii,jj,:) = mean(curEeg,2,'omitnan');
%         curEeg = squeeze(eegOutT(ii).featuresByPins(2,curIdx,:))';
%         featuresLeftPin(ii,jj,:) = mean(curEeg,2,'omitnan');
%         curEeg = eegOutT(ii).features(:,curIdx);
%         features(ii,jj,:) = mean(curEeg,2,'omitnan');
%     end