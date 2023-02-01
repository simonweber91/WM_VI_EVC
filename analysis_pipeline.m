
% Hi there!
%
% This is the complete pipeline to recreate the analysis and plots in ADD
% PAPER TITLE AND AUTHORS. In theory (provided you have the data), you can
% just hit run and everything will be done for you. In practice, this will
% probably take a year or so. So computing clusters and parallelisation are
% key (look for the out-commented 'parfor' and 'parallel_pool' lines).
%
% In this file, a bunch of analysis parameters are specified and stored in
% a structure 'p' (for 'parameters'), which is passed to all other
% functions along the way. The parameters used for the published analysis
% are the ones you see below. All subsequent functions are commented
% fairly thoroughly, so I hope everything becomes clear with minimal (or at
% least medium) effort. In case it doesn't, or you have questions, feel
% free to email me at sweber@bccn-berlin.de.
%
% Cheers!
%
% Simon Weber, sweber@bccn-berlin.de, 2021

%%% Add analysis scripts and required toolboxes to the search path %%%

% Analysis scripts
addpath(genpath('/analysis/sweber/projects/visimg/Code/VisualImagery_paper/'));
%addpath(genpath('/.../VisualImagery_paper/'));

% Toolboxes
% 1. SPM12
addpath('/analysis/sweber/toolboxes/spm12/');
% addpath('/.../spm12/');
% 2. The Decoding Toolbox (TDT), version 3.999E or higher
% https://sites.google.com/site/tdtdecodingtoolbox/
addpath(genpath('/analysis/sweber/toolboxes/tdt_3.999F/'))
% addpath('/.../tdt_3.999F');


%%% Shuffle randomization seed for permutation analysis %%%

rng('shuffle')

%%% Create structure with key analysis parameters %%%


% Basic paramters
p.OVERWRITE             = 0;                                                % Do you want to overwrite already existing result files? Really???
% p.base_dir              = '/...';                                         % Base directory of the project, where all the stuff is stored. Should have a 'Dicom' folder in it. 
p.base_dir              = '/analysis/sweber/projects/visimg_git_test';    

% Number of sessions/runs-per-session/trials-per-run of the experiment
p.n_session             = 2;                                                % Number of fMRI scanning sessions
p.n_run                 = 4;                                                % Number of runs in one session
p.n_trials              = 40;                                               % Number of trials in one run

% Subject IDs
p.subjects = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, ...
              19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 33, 34, ...
              35, 36, 37, 38, 39, 40, 41, 42];                              % Subject IDs (i.e. number for the subject-specific BIDS directory)

% fMRI image aquisition details
p.img.n_slice           = 72;                                               % Number of slices in one fMRI image
p.img.tr                = 0.8;                                              % Length of TR in seconds
p.img.dim               = [104 104 72];                                     % Image dimensions
% String-sample that defines the relevant fMRI images
p.img.filter            = 'task-vwm';                                       % String of a defining peice of the fMRI image filenames, so that they can be identified be loading scripts etc.

% First-level analysis parameters
p.lvl1.title            = 'trial_events';                                   % What the first-level analysis should be called
p.lvl1.conditions       = {'target'; 'distractor'; 'cue'; 'delay'; 'probe'; 'report'};  % Which events to model
p.lvl1.contrasts        = {'target'};                                       % Which events to contrast
p.lvl1.constrast_weights = { [repmat([1 0 0 0 0 0 zeros(1,6)],1,p.n_session*p.n_run)] };    % Contrast weights (including 6 zeros for head motion parameters, if needed)

% Reconstruction parameters
p.psvr.event            = 'delay';                                          % Event from which to decode
p.psvr.n_tr             = 30;                                               % Number of TRs to reconstruct from following the event onset
p.psvr.all_labels       = {'target', 'report', 'distractor', 'probe'};      % All labels which should bepsvr.voxel decoded
p.psvr.label            = '';                                               % Placeholder for current decoding label
p.psvr.fwhm             = [0:20:180];                                       % FWHM of feature space smoothing kernel, can be an array of multiple values for grid-search
p.psvr.roi              = 'wV1-3';                                          % Name of the ROI on which the analysis should be focused (each subjects should have a mask file with the respective filename)                             
p.psvr.voxel            = [250:250:2500];                                   % Number of voxels that should be included in the analysis, can be an array of multiple values for grid-search
p.psvr.delay            = 6:15;                                             % Delay-period TRs, or time-window of interest
p.psvr.n_perm           = 1000;                                             % Number of permutations for the permutation analysis

% p.par.n_workers         = 30;                                             % Number of parallel workers 


%%% Analyse data of the VVIQ questionnaire used for recruiting %%%
analyse_questionnaire(p);

%%% Analyse behavioral data of the MRI experiment %%%
analyse_behavior(p);

%%% Process MRI data and run the pSVR analysis to reconstruct orientation
%%% labels from voxel data %%%
analyse_mri(p);



