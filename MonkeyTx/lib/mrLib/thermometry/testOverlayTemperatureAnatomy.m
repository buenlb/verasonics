clear all; close all; clc;
%% [11,-10,60]
% sys.anatomyPath = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\phantom_20200623\s000017 t1_mpr_tra_iso\';
% sys.thermPath = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\phantom_20200623\s000049 seg_EPI3D_HIFU2_ETL5_TR25_TE13_10s_15V_10foot_11right_60pos';
% sys.thermMagPath = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\phantom_20200623\s000048 seg_EPI3D_HIFU2_ETL5_TR25_TE13_10s_15V_10foot_11right_60pos';
% sys.nSlices = 8;
% sys.focus = [10.25,119.5,-7];

%% [11,-10,60]
sys.anatomyPath = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\phantom_20200623\s000017 t1_mpr_tra_iso\';
sys.thermPath = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\phantom_20200623\s000029 seg_EPI3D_HIFU2_ETL5_TR25_TE13_10s_15V_15mmFoot_60P';
sys.thermMagPath = 'C:\Users\Taylor\Documents\Data\MR\Thermometry\phantom_20200623\s000028 seg_EPI3D_HIFU2_ETL5_TR25_TE13_10s_15V_15mmFoot_60P';
sys.nSlices = 8;
sys.focus = [10.25,119.5,-7];
sys.focalRadius = 5;
%% Overlay Results
sys = overlayTemperatureAnatomy(sys);