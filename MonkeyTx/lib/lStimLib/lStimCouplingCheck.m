rescan = 1;
scIdx = 1;
hobbesGs = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20220202\UltrasoundData\hobbesGS.mat';
calvinGs = 'C:\Users\Verasonics\Desktop\Taylor\Data\MRExperiments\20220203\UltrasoundData\calvinGS.mat';
logPath = 'C:\Users\Verasonics\Desktop\Taylor\LStim\hobbes20230221\';
couplingFileName = [logPath,'hobbes_coupling_0.mat'];
while rescan
    save('tmp.mat');
    testArrayPlacement_firstTargetTask(hobbesGs,couplingFileName,[],0);
    load('tmp.mat');
    delete('tmp.mat');
    waitfor(verifyPreTask(hobbesGs,couplingFileName));
       


    rs = load('guiOutput.mat');
    rescan = rs.rescan;
    if rescan
        scIdx = scIdx+1;
        sys.couplingFile = [sys.couplingFile(1:end-4),'_',num2str(scIdx),'.mat'];
        
    end
end