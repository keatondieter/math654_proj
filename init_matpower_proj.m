%% File: init_matpower_proj.m
% Author: Keaton Dieter
% Email: dieterk@oregonstate.edu
% Date: July 2017
%
% Purpose: This script does the neccessary things to initialize matpower for work
% outside of the main matlab directory, and also adds any folders needed
% to otherwise run the VCA code

addpath(path, 'matpower6.0/')
addpath(path, 'matpower6.0/t')
addpath(path, 'sparse_grid_hermite')