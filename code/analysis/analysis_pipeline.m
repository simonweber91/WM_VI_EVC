
% Hi there!
%
% This is the complete pipeline to recreate the analysis and plots in
% "Working memory and imagery in early visual cortex" by Weber,
% Christophel, Görgen, Soch and Haynes. To create the figures from the
% paper, just complete a few file paths below (look for '...') and then hit
% run (ignore the warning messages). If you have the original data (which
% can be made available upon reasonable request), you can also recreate the
% entire analysis. This might take very (very!) long, so computing clusters
% and parallelisation are key (look for the out-commented 'parfor' and
% 'parallel_pool' lines in the various functions).
%
% In this file, a bunch of analysis parameters are specified and stored in
% a structure 'p' (for 'parameters'), which is passed to all other
% functions along the way. The parameters used for the published analysis
% are the ones you see below. All subsequent functions are commented
% fairly thoroughly, so I hope everything becomes clear with minimal (or at
% least medium) effort. In case it doesn't, or you have questions, feel
% free to email me at sweber@bccn-berlin.de.
%
% There are a few external tools and toolboxes that are required to run the
% analysis. These are listed below, including their respective download
% links. Make sure that you all resources are available on your system and
% added to the Matlab search path.
%
% Cheers!
%
% Simon Weber, sweber@bccn-berlin.de, 2023


%%% Add analysis scripts and required toolboxes to the search path %%%

% Analysis scripts
addpath(genpath('/.../WM_VI_EVC/code/analysis/'));

% Toolboxes
% 1. SPM12
% https://www.fil.ion.ucl.ac.uk/spm/software/download/
addpath('/.../spm12/');
% 2. The Decoding Toolbox (TDT), version 3.999E or higher
% https://sites.google.com/site/tdtdecodingtoolbox/
addpath('/.../tdt_3.999F');
% 3. RDK_vMMM toolbox for estimation of von Mises mixture models
% https://github.com/JoramSoch/RDK_vMMM
addpath('/.../RDK_vMMM');


%%% Shuffle randomization seed for permutation analysis %%%

rng('shuffle')

%%% Create structure with key analysis parameters %%%


% Basic paramters
p.OVERWRITE             = 0;                                                % Do you want to overwrite already existing result files? Really???
p.dirs.base              = '.../WM_VI_EVC';                                         % Base directory of the project, where all the stuff is stored.
p.dirs.data              = fullfile(p.dirs.base, 'data');
p.dirs.source            = '';

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
p.img.dim               = [104 104 72];                                     % fMRI image dimensions
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


%%% Create folder strcutures, prepare data
setup_analysis(p);

%%% Analyse data of the VVIQ questionnaire used for recruiting %%%
analyse_questionnaire(p);

%%% Analyse behavioral data of the MRI experiment %%%
analyse_behavior(p);

%%% Process MRI data and run the pSVR analysis to reconstruct orientation
%%% labels from voxel data %%%
analyse_mri(p);



