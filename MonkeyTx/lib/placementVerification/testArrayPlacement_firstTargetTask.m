% Tests the placement of the array on the skull. Checks both the position
% and the returned power against the results in the file, goldStd. Saves
% the raw and processed data as a .mat file in svName.
% 
% @INPUTS
%   goldStd: mat file containing data for the "gold standard experiment."
%       This refers to the data acquired on the day of the MR scan.
%   svName: Full path and name in which to save the results of the current
%       test. The code will force a confirmation before overwriting an
%       existent file. This field is not required if fName is provided and
%       the function will not save any resuls if fName is provided. It is,
%       however, required if the hardware is used to acquire the data.
%   fName: Optional. Specifies the location of a file with the single and
%      gridded element data. If no file is provided then the function
%      imageSkull is run in order to obtain the data.
%   overwrite: Optional, specifies whether or not to automatically
%       overwrite if a file with the given svName already exists. Defaults
%       to zero.
% 
% @OUTPUTS
%   gs: variables contained in goldStd file 
%   gsRaw: original gold standard data
%   crData: Single element and gridded element data acquired by imageSkull
%       or stored in fName
% 
% Taylor Webb
% Targeted Treatments Laboratory
% University of Utah
% March 2020

function [gs,gsRaw,crData] = testArrayPlacement_firstTargetTask(goldStd,svName,fName,overwrite)
if ~exist('overwrite','var')
    overwrite = 0;
end

% Load Gold Standard Data
gs = load(goldStd);
if ~isfield(gs,'fName')
    error('Invalid gold standard file')
end
if ~isfield(gs,'txSn')
	warning('Serial number not found in gold standard image, assuming JAB800');
	txSn = 'JAB800';
else
    txSn = gs.txSn;
end
disp(['Using TxSn: ', txSn])
gsRaw = load(gs.fName);

if exist('fName','var') && ~isempty(fName)
    crData = load(fName);
else
    if (exist(svName, 'file') || exist([svName,'.mat'],'file')) && ~overwrite
        ovw = input('A file already exists in the specified location, overwrite (this action is irreversible)? (0/1)>> ');
        if ~ovw
            error(['File: ', num2str(svName), ' already exists'])
        end
    end
    
    [singleElRaw,griddedElRaw] = imageSkull(txSn);
    save(svName,'singleElRaw','griddedElRaw','txSn')
    crData.griddedElRaw = griddedElRaw;
    crData.singleElRaw = singleElRaw;
end