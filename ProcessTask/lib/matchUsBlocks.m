function tData = matchUsBlocks(tData,desiredUsBlock)

actualUsBlock = tData.usBlock;

for ii = 1:length(tData.Block)
    tData.Block(ii) = tData.Block(ii)-(actualUsBlock-desiredUsBlock);
end