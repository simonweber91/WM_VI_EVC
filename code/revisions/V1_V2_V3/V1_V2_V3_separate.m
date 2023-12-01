


%%% Add analysis scripts and required toolboxes to the search path %%%

% Analysis scripts
addpath(genpath('/.../WM_VI_EVC/code/analysis/'));
addpath(genpath('/.../WM_VI_EVC/code/revisions/'));

% Toolboxes
% 1. SPM12
% https://www.fil.ion.ucl.ac.uk/spm/software/download/
addpath('/.../spm12/');
% 2. The Decoding Toolbox (TDT), version 3.999E or higher
% https://sites.google.com/site/tdtdecodingtoolbox/
addpath(genpath('/.../tdt_3.999F'));
% 3. RDK_vMMM toolbox for estimation of von Mises mixture models
% https://github.com/JoramSoch/RDK_vMMM
addpath(genpath('/.../RDK_vMMM/tools/vMMM'));


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
p.img.filter            = 'task-vwm';                                       % String of a defining peice of the fMRI image filenames, so that they can be identified by loading scripts etc.

% Reconstruction parameters
p.psvr.event            = 'delay';                                          % Event from which to decode
p.psvr.n_tr             = 15;                                               % Number of TRs to reconstruct following the event onset
p.psvr.all_labels       = {'target'};                                       % All labels which should bepsvr.voxel decoded
p.psvr.label            = 'target';                                         % Placeholder for current decoding label
p.psvr.fwhm             = [0:20:180];                                       % FWHM of feature space smoothing kernel, can be an array of multiple values for grid-search
p.psvr.roi              = {'wV1', 'wV2', 'wV3'};                            % Name of the ROI on which the analysis should be focused (each subjects should have a mask file with the respective filename)                             
p.psvr.voxel            = {'all'};                                          % Number of voxels that should be included in the analysis, can be an array of multiple values for grid-search
p.psvr.delay            = 6:15;                                             % Delay-period TRs, or time-window of interest
p.psvr.n_perm           = 0;

% p.par.n_workers         = 30;                                             % Number of parallel workers 

%% Create ROIs from Atlas

for i_roi = 1:numel(p.psvr.roi)

    roi = strrep(p.psvr.roi{i_roi},'w','');

    % Create binary Region of Interest (ROI) masks from probability maps in MNI
    % space
    create_rois_from_prob_maps(p, roi);
    % Warp ROIs into subject space using the warping parameters estimated
    % during preprocessing
    warp_rois_to_subject_space(p, roi);

end

%% Run reconstruction for each ROI

p_roi = p;
for i_roi = 1:numel(p_roi.psvr.roi)

    p.psvr.roi = p_roi.psvr.roi{i_roi};
    
    % Run pSVR analysis as grid search for various voxel-counts and
    % feature-space smoothing FWHM values
    mri_reconstruction_grid(p);
    
    % Calculate statistics using the results of the permutation analysis
    mri_tmass_stats(p);
    
    pSVR_plot_delay_accuracy(p);
    pSVR_plot_bfca_vviq_correlation(p);

end