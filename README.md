# Verasonics

The verasonics system is run by setting a variety of values in structs and then calling VSX on a mat file containing the relevent structs. Based on this functionality, the code is organized in the following way:

-lib: Helper functions shared by all trandsucers
-Transducer: Top level folders reference the transducer for which the code is written
	-scripts: These are the scripts that generate the structs required by VSX and write out a mat file that can be passed to VSX. MAT files are automatically stored in the folder MATFILES which is ignored by git
	-lib: Helper functions called by the scripts or passed to VSX to plot output
	-MATFILES: Storage of matfiles created by scripts. This folder is always ignored by git and matfiles must be recreated on any new machine. This is easily done by running the relevent script
	
For more documentation on how to use VSX or the event viewer see Verasonics documentation. You can always find this in the documentation folder created when Verasonics is installed on your machine.

# Helper Functions

-setPaths: This is a really useful helper function but it is a bit different than the others. Instead of living in Verasonics -> lib it lives in the setupScripts folder of each transducer. This enables it to set up the MATLAB path to have all the relevent lib directories once the location of the setupScript has been added to the path. It also outputs the directory you are in for use later on in the script. You should probably call this function at the beginning of every setupScript.

-makeFigureBig: Just a figure helper that makes text sizes and figure formatting more appealing.

-generateImpulse: Makes the pulse code to generate an impulse via the arbitrary waveform generator. Use this to set TW.PulseCode if you want an impulse

-matFileName: This function generates the full path and name of the mat file to be output by a setupScript assuming that the mat-file name should be the same as the m-file name. It also does some really useful error checking, ensuring that you haven't inadvertantly given the same name to a different mat file that supercedes the new one on the MATLAB path.