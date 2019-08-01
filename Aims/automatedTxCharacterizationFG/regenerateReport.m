% Regenerates a report. !! The old report will be overwritten !! No data
% will be overwritten.
% 
% @INPUTS
%   Grid: Grid Struct as defined in characterizeTx
%   Tx: Tx Struct as defined in characterizeTx
%   FgParams: FgParams Struct as defined in characterizeTx
%   Hydrophone: Hydrophone struct as defined in characterizeTx
%   xyPlaneLoc: Z location of the xy plane. This can be read from the
%       report. It is the location of the xy plane or, if a cone is used,
%       it is the location of the xy plane + the estimated edge of the
%       cone.
%   saveDirectory: original saveDirectory. The function will read the data
%       grids from this directory and then re-write a report into the same
%       directory.

function regenerateReport(Grid,Tx,FgParams,Hydrophone,xyPlaneLoc,saveDirectory)
warning('Old report will be overwritten! No data will be overwritten')
cont = input('Continue? (0/1) >>');
if ~cont
   error('Terminated by user. Didn''t want to overwrite the report')
end

fname = [saveDirectory,'xy.snq'];
[rawData,x,y,xLabel,yLabel] = readAIMS(fname);
grid_xy = struct('data',rawData,'x',x,'y',y,'xLabel',xLabel,'yLabel',yLabel);
Grid.XYPlaneLoc = xyPlaneLoc;

fname = [saveDirectory,'yz.snq'];
[rawData,x,y,xLabel,yLabel] = readAIMS(fname);
grid_yz = struct('data',rawData,'x',x,'y',y,'xLabel',xLabel,'yLabel',yLabel);

fname = [saveDirectory,'xz.snq'];
[rawData,x,y,xLabel,yLabel] = readAIMS(fname);
grid_xz = struct('data',rawData,'x',x,'y',y,'xLabel',xLabel,'yLabel',yLabel);

generateReport(Grid,Tx,FgParams,Hydrophone,grid_xy,grid_xz,grid_yz,[saveDirectory,'report\'])