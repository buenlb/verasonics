function writeLogFile_exVivoScan(header, fName)
fid = fopen(fName,'w');

now = clock;
fprintf(fid,'%s\n\n',['Created ', num2str(now(3)),'/',num2str(now(2)),'/',num2str(now(1)),...
    ' at ', num2str(now(4)),':',num2str(now(5))]);

fprintf(fid,'%s\n',['Frequency: ', num2str(header.frequency), 'MHz']);
fprintf(fid,'%s\n',['Sampling Rate: ', num2str(header.samplingRate), 'MHz']);
fprintf(fid,'%s\n',['Number of Averages: ', num2str(header.averages)]);
if numel(header.angles) > 1
fprintf(fid,'%s\n',['Angles (<min,dTheta,max>): <', num2str(header.angles(1)),...
    ',',num2str(header.angles(2)-header.angles(1)),',',num2str(header.angles(end)),'>']);
else
fprintf(fid,'%s\n',['Angles (<min,dTheta,max>): <', num2str(header.angles(1)),...
    ',',0,',',num2str(header.angles(end)),'>']);
end
fprintf(fid,'%s\n','Transmits:');
for ii = 1:header.nTransmits
    if header.excitations(ii)
        fprintf(fid,'%s\n',['  Transmit ', num2str(ii), ': Sinusoid with '...
            num2str(header.excitations(ii)), ' half cycle(s).']);
    else
        fprintf(fid,'%s\n',['  Transmit ', num2str(ii), ': Impulse ']);
    end
end

fclose(fid);