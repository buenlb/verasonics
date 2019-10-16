% This script cleares the workspace and launches the GUI that is used to
% test the transducer in both the water tank and the MR scanner. 

%%
try
    close(gui)
catch
end
clear all; close all; clc;

%%
gui = prescribe_cmp;