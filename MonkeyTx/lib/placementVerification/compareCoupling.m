function compareCoupling(goldStandard,fName)
cr = load(fName);
gsParams = load(goldStandard);
gs = load(gsParams.fName);
% cr = cr.griddedElRaw;
% gs = gs.griddedElRaw;

imgs = struct('gs',gs,'cr',cr,'gsParams',gsParams,...
            'goldStd',goldStandard,'expPath',[],'fName',fName);

verifyPreTask(imgs);