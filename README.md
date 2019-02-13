# Verasonics

The verasonics system is run by setting a variety of values in structs and then calling VSX on a mat file containing the relevent structs. Based on this functionality, the code is organized in the following way:

-lib: Helper functions shared by all trandsucers
-Transducer: Top level folders reference the transducer for which the code is written
	-scripts: These are the scripts that generate the structs required by VSX and write out a mat file that can be passed to VSX. MAT files are automatically stored in the folder MATFILES which is ignored by git
	-lib: Helper functions called by the scripts or passed to VSX to plot output
	-MATFILES: Storage of matfiles created by scripts. This folder is always ignored by git and matfiles must be recreated on any new machine. This is easily done by running the relevent script
	
For more documentation on how to use VSX or the event viewer see Verasonics documentation. You can always find this in the documentation folder created when Verasonics is installed on your machine.