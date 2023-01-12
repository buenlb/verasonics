% processNonConformingSessions loops through the sessions found in the file
% fName and adjusts them to make them processable by the same software used
% to process other files.
% 
% Currently, this means adjusting the time at which the ultrasound occurs
% to comform with the time at which the experimenter noticed that the
% sonication occured. If the block marked for the sonication spans more
% than a minute the session is marked for removal in keepIdx. The threshold
% that causes removal can be changed with the variable
% 'uncertaintyThreshold'
% 
% fName also contains sessions marked for exclusion. Detailed reasons for
% the exlusion are given in that file.
% 
% @INPUTS
%   fName: File containing information about nonconforming sessions
%   tData: struct generated using processTaskDataDurable.,
%   sessions: List of files corresponding to the data in tData. Each
%       session must correspond to the data in tData (i.e. tData(ii) is the
%       data found in the file sessions{ii}).
% 
% @OUTPUTS
%   tData: tData struct adjusted to meet the requirements in fName
%   keepIdx: a vector of booleans marking whether or not the uncertainty in
%       sonicationtime exceeds a threshold. These sessions can then be
%       removed if desired.
% 
% Taylor Webb
% 11 October 2022

function [tData,keepIdx] = processNonConformingSessions(fName,tData,sessions)
eval(fName);

uncertaintyThreshold = 150;
keepIdx = true(size(tData));
for ii = 1:length(ncs) %#ok<USENS> 
    for jj = 1:length(sessions)
        if strcmp(sessions{jj},ncs{ii})
            newIdx = find(tData(jj).block == sonicatedBlock(ii));
            timeUncertainty = tData(jj).timing(newIdx(end)).startTime - tData(jj).timing(newIdx(1)).startTime;
            if timeUncertainty <= uncertaintyThreshold
                disp(['WARNING! ', sessions{jj},...
                    ' resulted in a sonication at an incorrect time.'])
                disp('The precise time of the sonication is not known.')
                disp('I am estimating the sonication based on block number.')
                disp(['In this session that creates an uncertainty of ',...
                    num2str(timeUncertainty,3), ' s.'])
            else
                keepIdx(jj) = false;
                disp('WARNING! ')
                disp(['  ', sessions{jj} ' was marked for removal.'])
                disp(['  Time uncertainty (', num2str(timeUncertainty,3), ' seconds)']);
                disp('  was too high after accounting for erroneous sonication.')
            end
            newIdx = newIdx(1);
            tData(jj).sonicatedTrials = newIdx;
        end
    end
end

for ii = 1:length(exc) %#ok<USENS> 
    for jj = 1:length(sessions)
        if strcmp(sessions{jj},exc{ii})
            keepIdx(jj) = false;
            disp('WARNING!')
            disp(['  ', sessions{jj}, ' marked for removal by noncomforming sessions file'])
        end
    end
end