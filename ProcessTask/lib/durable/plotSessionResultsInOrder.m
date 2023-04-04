% plotSessionResultsInOrder creates a matrix of values representing the
% leftward choices at the equal probability point at the times given by
% tmIdx. The matrix is M x 2 x N where M is the number or session
% parameters specified (length(sIdx)), 2 is for the left/right LGN, and M
% is the maximum number of sessions in a given parameter set.
% 
% @INPUTS:
%   Sessions: Array of structs representing available parameters
%   sIdx: Index into the array of structs. Only these will be used in the
%     analysis
%   processedFiles: Names of files from which to acquire the date
%   y: Leftward choices at the equal probabilty point
%   tmIdx: Index into the columns of y telling the code which time points
%     to average for the result
% 
% @OUTPUTS:
%   result: Average leftward choices at the relevant time points for each
%     session in sessions (sIdx)
%   dayOfSession: The day that the session was acquired. Corresponds
%     exactly to result
% 
% Taylor Webb

function [result,dayOfSession,idx] = plotSessionResultsInOrder(sessions,sIdx,processedFiles,y,tmIdx)
day = getSessionDate(processedFiles);

sessionsRemain = 1;
curSessionIdx = 1;
result = nan(length(sIdx),2,10);
idx = result;
dayOfSession = result;
while sessionsRemain
    sessionsRemain = 0;
    for ii = 1:length(sIdx)
        [idxLeft,idxRight] = getLeftRightIdx(sessions,sIdx(ii));

        % Sort sessions by the day they occured
        [~,tmpIdxLeft] = sort(day(idxLeft));
        idxLeft = idxLeft(tmpIdxLeft);
        [~,tmpIdxRight] = sort(day(idxRight));
        idxRight = idxRight(tmpIdxRight);

        % Add sessions in order to result
        if curSessionIdx <= length(idxLeft)
            result(ii,1,curSessionIdx) = mean(y(idxLeft(curSessionIdx),tmIdx),2,'omitnan');
            dayOfSession(ii,1,curSessionIdx) = day(idxLeft(curSessionIdx));
            idx(ii,1,curSessionIdx) = idxLeft(curSessionIdx);
            sessionsRemain = 1;
        end
        if curSessionIdx <= length(idxRight)
            result(ii,2,curSessionIdx) = mean(y(idxRight(curSessionIdx),tmIdx),2,'omitnan');
            dayOfSession(ii,2,curSessionIdx) = day(idxRight(curSessionIdx));
            idx(ii,2,curSessionIdx) = idxRight(curSessionIdx);
            sessionsRemain = 1;
        end
    end
    curSessionIdx = curSessionIdx+1;
end