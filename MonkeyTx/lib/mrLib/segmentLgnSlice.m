function roi = segmentLgnSlice(h)

figure(h)
msgbox('Press enter when you are happy with the zoom and want to start drawing the ROI')

currkey=0;
% do not move on until enter key is pressed
while currkey~=1
    pause; % wait for a keypress
    currkey=get(gcf,'CurrentKey'); 
    if strcmp(currkey, 'return') % You also want to use strcmp here.
        currkey=1;
    else
        currkey=0;
    end
end

[roi] = roipoly();
roi = roi.';
close(h);