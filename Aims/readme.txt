# Readme - Verasonics and Soniq

# Background
Soniq provides a DLL that can be loaded by MATLAB and used to control soniq externally. The files in this folder leverage this capacity in order to synchronize the Soniq measurement system (formally know as acoustic intensity measurement system or AIMS) and the Verasonics system.

# File structure
The file structure is the same as other code in the verasonics repository. Setup scripts, matfiles, and helper functions each have their own file location

# Aims1dScan
Aims1dScan is a setup script that sets the verasonics system up for a 1d scan. It also calls VSX (this can be done by setting the variable filename to the name of the MATLAB file that you want VSX to use). The script records each scan location as an indivudual frame and by setting the variable NA the user can determine how many averages compose each frame. The script uses several helper functions (described below) to interact with the Soniq system.

Changes to the Soniq system are made by external processing function calls. These calls rely on parameters set in Resource.Parameters to determine which axis the scan is being performed on and how much to move the positioner. 

	- A few key parameters that the user can change
		-NA: number of averages to acquire at each positioner location
		-positionerDelay: delay in ms between positioner movement and data acquisition
		-prf: pulse repitition frequency in Hz for the NA Transmit/receive pulses acquired at each positioner location
		-centerFrequency: Center transmit/receive frequency
		-numHalfCycles: number of half cycles to use in transmit pulse
		
# Soniq Helper Functions (all housed in lib)
	- loadSoniqLibrary: This must be called before any other soniq helper functions are called. It loads the DLL and assigns it an alias which is returned as the output variable of the function. Currently the alias is set to be 'soniq'. This alias must then be passed to the other helper functions. It is stored in Resource.Parameters so that it can be used by VSX
	- openSoniq: This must be called right after loadSoniqLibrary. It establishes a connection to the Soniq software. Once a connection is opened the Soniq GUI and the positioner switches are disabled so that the tank can only be controlled externally. To re-enable the GUI/positioner box call closeSoniq.
	- movePositioner and movePositionerAbs move the positioner. They do error checking to ensure that the requested motion is within software limits
	- withinLimits is a helper function that checks the Soniq software positioner limits. Remember that Soniq considers a move out of bounds if the motion would result in a position greater than or equal to the limit.
	- continueScan and show2dScan are external processing functions called by VSX to control the positioner and display results.
	- closeSoniq terminates the software connection. Once a connection is terminated the Soniq GUI becomes active again