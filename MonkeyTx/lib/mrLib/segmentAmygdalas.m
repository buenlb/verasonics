function sys = segmentAmygdalas(sys)

if ~isfield(sys,'colorImg')
    sys.colorImg = drawTransducerColor(sys.aImg,sys.txImg);
end

waitfor(segmentLgnGui(sys));

results = load('guiFileOutput.mat');
sys.rightAmygRoi = results.rightLgnRoi;
sys.leftAmygRoi = results.leftLgnRoi;