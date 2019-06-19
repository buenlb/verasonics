function writeLatex(Grid,Tx,FgParams,Hydrophone,fileLoc)
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
% Latex needs underscores to be escaped - this does that for cone names
coneName = Tx.cone;
found = 0;
for ii = 1:length(coneName)
    if found
        found = 0;
        continue
    end
    if coneName(ii) == '_'
        coneName = [coneName(1:ii-1),'\',coneName(ii:end)];
        found = 1;
    end
end

fprintf(fid,'%s%s%s%s%s\n','\section*{',num2str(Tx.frequency,2),' MHz Transducer, Cone: ', coneName, '.}');

%% Tx
fprintf(fid,'\n\n%s','\noindent\textbf{Transducer: }');
fprintf(fid,'%s%s','Model: ', Tx.model);
fprintf(fid,'%s%s%s',', Center Frequency: ', num2str(Tx.frequency,2), 'MHz');
fprintf(fid,'%s%s',', Serial Number: ', Tx.serial);
fprintf(fid,'%s%s%s\n',', Diameter: ', num2str(Tx.diameter), 'mm');

%% Function Generator
fprintf(fid,'\n\n%s','\noindent\textbf{Function Generator: }');
fprintf(fid,'%s%s','Number of cycles: ', num2str(FgParams.nCycles));
fprintf(fid,'%s%s%s',', Input voltage for beam patterns: ', num2str(FgParams.gridVoltage), 'mVpp');
fprintf(fid,'%s%s%s',', Burst period: ', num2str(FgParams.burstPeriod),'ms');


%% Amplifier
fprintf(fid,'\n\n%s','\noindent\textbf{Amplifier: }');
fprintf(fid,'%s%s','Model: ', FgParams.amplifierModel);
fprintf(fid,'%s%s',', Serial Number: ', FgParams.amplifierSerial);
%% Hydrophone
fprintf(fid,'\n\n%s','\noindent\textbf{Hydrophone: }');
fprintf(fid,'%s%s','Model: ', Hydrophone.model);
fprintf(fid,'%s%s',', Serial Number: ', Hydrophone.serial);
fprintf(fid,'%s%s\n',', Calibration Date: ', Hydrophone.calDate);

%% Figures
fprintf(fid,'%s\n','\begin{figure}[h!]');
fprintf(fid,'%s\n','\centering');
fprintf(fid,'%s\n',['\subfigure[XY Plane (Z=',num2str(Grid.XYPlaneLoc-Tx.coneEdge,4),')]{']);
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
if strcmp('none',coneName)
    fprintf(fid,'%s\n','\caption{\label{fig:beamPattern}Beam patterns in three planes. The z-axis is referenced to the transducer face.}');
else
    fprintf(fid,'%s\n',['\caption{\label{fig:beamPattern}Beam patterns in three planes. The z-axis is referenced to the edge of the cone which was estimated to be ',...
        num2str(Tx.coneEdge), 'mm from the Tx face.}']);
end
fprintf(fid,'%s\n','\end{figure}');

fprintf(fid,'%s\n','\begin{figure}[h!]');
fprintf(fid,'%s\n','\centering');

fprintf(fid,'%s\n',['\subfigure[Waveform at ', num2str(FgParams.gridVoltage), 'mVpp. Positioner Locations relative to Tx: ('...
    , num2str(Grid.wvPosition(1),4),',',num2str(Grid.wvPosition(2),2),',',num2str(Grid.wvPosition(3),2),')]{']);
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