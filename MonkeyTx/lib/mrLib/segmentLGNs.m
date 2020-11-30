function sys = segmentLGNs(sys)

if ~isfield(sys,'colorImg')
    sys.colorImg = drawTransducerColor(sys.aImg,sys.txImg);
end

waitfor(segmentLgnGui(sys));

results = load('guiFileOutput.mat');
sys.rightLgnRoi = results.rightLgnRoi;
sys.leftLgnRoi = results.leftLgnRoi;