function writeBatchFile(fileLoc)
fid = fopen([fileLoc,'pdflatexScript.bat'],'w');

%% Header (include packages etc)
fprintf(fid,'%s\n','@echo off');
fprintf(fid,'%s%s%s\n','cd "', fileLoc, '"');
fprintf(fid,'%s\n','pdflatex report');
fprintf(fid,'%s\n','pdflatex report');
fprintf(fid,'%s\n','pdflatex report');
fprintf(fid,'%s\n','report.pdf');
fprintf(fid,'%s\n','exit');

fclose(fid)