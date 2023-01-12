function receiveBeamform(RData)
return
Resource = evalin('base','Resource');
fileIdx = Resource.Parameters.fileIdx;
vIdx = Resource.Parameters.vIdx;
curTargetNum = 1;
if vIdx == 1 && fileIdx == 1
    Resource.Parameters.timeStarted = tic;
    Receive = evalin('base','Receive');
    Resource.Parameters.lastSample = Receive(end).endSample;
    Resource.Parameters.nSamples = Receive(1).endSample;
    Resource.Parameters.dt = 1/(Receive(1).ADCRate*1e6);
    Resource.Parameters.centerElement = zeros(Resource.Parameters.lastSample,...
        Resource.Parameters.imagingTime/Resource.Parameters.timePerSave);
    Resource.Parameters.receiveBeam = zeros(Resource.Parameters.lastSample,...
        Resource.Parameters.imagingTime/Resource.Parameters.timePerSave);
end
ls = Resource.Parameters.lastSample;
ns = Resource.Parameters.nSamples;
dt = Resource.Parameters.dt;
delays = Resource.Parameters.delays;
Resource.Parameters.centerElement(:,vIdx) = RData(1:ls,132);
Resource.Parameters.receiveBeam(:,vIdx) = receiveBeamformer(RData(1:ls,:),ns,...
    delays,dt,curTargetNum,Resource.Parameters.frequency);

if vIdx == Resource.Parameters.beamsPerImagingTime    
    tmSaved = toc(Resource.Parameters.timeStarted);
    fName = [Resource.Parameters.savePth,Resource.Parameters.saveName,num2str(fileIdx)];
    
    centerElement = Resource.Parameters.centerElement;
    receiveBeam = Resource.Parameters.receiveBeam;
    disp('Saving...')
    if fileIdx == 1        
        Receive = evalin('base','Receive');
        save(fName,'Receive','centerElement','receiveBeam','Resource','tmSaved');
    else
        save(fName,'centerElement','receiveBeam','tmSaved');
    end
    Resource.Parameters.vIdx = 0;
    
    if fileIdx == Resource.Parameters.nLoops
        closeVSX();
    end
    
    Resource.Parameters.fileIdx = Resource.Parameters.fileIdx+1;
end

Resource.Parameters.vIdx = Resource.Parameters.vIdx+1;

assignin('base','Resource', Resource);