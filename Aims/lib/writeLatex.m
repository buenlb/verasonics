function writeLatex(Grid,Tx,FgParams,fileLoc)
fid = fopen([fileLoc,'report.tex'],'w');

%% Header (include packages etc)
fprintf(fid,'%s\n','\documentclass[11pt]{article}');
fprintf(fid,'%s\n','\usepackage[paperheight=11in,paperwidth=8.5in]{geometry} ');
fprintf(fid,'%s\n','\usepackage{graphicx}');
fprintf(fid,'%s\n','\usepackage{geometry}');
fprintf(fid,'%s\n','\usepackage{subfigure}');
fprintf(fid,'%s\n','\usepackage[font=footnotesize,labelfont=bf,font=it]{caption}');
fprintf(fid,'%s\n','\geometry {');
fprintf(fid,'%s\n','lmargin=0.5in,');
fprintf(fid,'%s\n','rmargin=0.5in,');
fprintf(fid,'%s\n','tmargin=0.5in,');
fprintf(fid,'%s\n','bmargin=0.5in');
fprintf(fid,'%s\n','}');
fprintf(fid,'%s\n','\pagenumbering{gobble}');
fprintf(fid,'%s\n','\begin{document}');

%% Document
fprintf(fid,'%s%s%s\n','\section*{',num2str(Tx.frequency,2),' MHz Transducer}');
fprintf(fid,'%s%s%s%s%s%s\n','Beams are acquired with a ',num2str(FgParams.nCycles), ' cycle(s) pulse and ',...
    num2str(FgParams.gridVoltage), ' mVpp input from the function generator.');
fprintf(fid,'\n\n%s','\textbf{Transducer Info: }');
fprintf(fid,'%s%s','Model: ', Tx.model);
fprintf(fid,'%s%s%s',', Center Frequency: ', num2str(Tx.frequency,2), 'MHz');
fprintf(fid,'%s%s',', Serial Number: ', Tx.serial);
fprintf(fid,'%s%s%s\n',', Diameter: ', num2str(Tx.diameter), 'mm');

fprintf(fid,'%s\n','\begin{figure}[h!]');
fprintf(fid,'%s\n','\centering');
fprintf(fid,'%s\n','\subfigure[XY Plane]{');
fprintf(fid,'%s\n','	\label{fig:xy}');
fprintf(fid,'%s\n','	\includegraphics[width=0.3\textwidth]{xy.png}');
fprintf(fid,'%s\n','}');
fprintf(fid,'%s\n','\hspace{0.1cm}');
fprintf(fid,'%s\n','\subfigure[XZ Plane]{');
fprintf(fid,'%s\n','	\label{fig:xz}');
fprintf(fid,'%s\n','	\includegraphics[width=0.3\textwidth]{xz.png}');
fprintf(fid,'%s\n','}');
fprintf(fid,'%s\n','\vspace{0.1cm}');
fprintf(fid,'%s\n','\subfigure[YZ Plane]{');
fprintf(fid,'%s\n','	\label{fig:yz}');
fprintf(fid,'%s\n','	\includegraphics[width=0.3\textwidth]{yz.png}');
fprintf(fid,'%s\n','}');
fprintf(fid,'%s\n','\caption{\label{fig:beamPattern}Beam patterns in three planes.}');
fprintf(fid,'%s\n','\end{figure}');

fprintf(fid,'%s\n','\begin{figure}[h!]');
fprintf(fid,'%s\n','\centering');
fprintf(fid,'%s\n','\subfigure[Waveform at min voltage]{');
fprintf(fid,'%s\n','	\label{fig:xy}');
fprintf(fid,'%s\n','	\includegraphics[width=0.45\textwidth]{wv.png}');
fprintf(fid,'%s\n','}');
fprintf(fid,'%s\n','\hspace{0.1cm}');
fprintf(fid,'%s\n','\subfigure[Efficiency]{');
fprintf(fid,'%s\n','	\label{fig:xz}');
fprintf(fid,'%s\n','	\includegraphics[width=0.45\textwidth]{eff.png}');
fprintf(fid,'%s\n','}');
fprintf(fid,'%s\n','\caption{\label{fig:efficiency}Transducer efficiency and waveform.}');
fprintf(fid,'%s\n','\end{figure}');

%% Footer
fprintf(fid,'%s\n','\end{document}');

fclose(fid);