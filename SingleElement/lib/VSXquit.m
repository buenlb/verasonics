function VSXquit(  )
    % VSXquit emulates closing the VSX control window to quit VSX
    %
    %   VSXquit uses Matlab's 'findobj' to find the handle for the VSX control GUI window
    %   and then closes that figure programmatically.
    %
    %  USAGE:  Simply invoke quitVSX in an external function when it is not practical to manually close the control panel.
    
    hfig = findobj('Name','VSX Control');
    close (hfig)

    % NOTE: the following works to quit VSX, but leaves the GUI window open.
    % evalin ('base', 'exit=1;')
    
end

