function tm = waitForFg(fg)
tic
fprintf(fg,'*OPC?');
doneStr = fscanf(fg);
done = str2double(doneStr(1));

while ~done
    fprintf(fg,'*OPC?');
    doneStr = fscanf(fg);
    done = str2double(doneStr(1));
end
tm = toc;