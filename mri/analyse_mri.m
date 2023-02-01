function analyse_mri(p)

% Run the preprocessing, modeling and reconstruction of the fMRI data, and
% plot the results.

% Set up the BIDS file structure for each subject
bids_setup(p);
% Convert Dicom to Nifti images
dicom2nifti_bids(p);

% Run preprocessing of fMRI data
mri_preprocessing(p);

% Create binary Region of Interest (ROI) masks from probability maps in MNI
% space
create_rois_from_prob_maps(p, 'V1-3');
% Warp ROIs into subject space using the warping parameters estimated
% during preprocessing
warp_rois_to_subject_space(p, 'V1-3');

% Run a GML on each subject to estimate brain activation in response to
% each trial-event, calculate a contrast for target-vs.-baseline activity
mri_level1(p);

% For all orientation labels of interest...
for l = 1:numel(p.psvr.all_labels)

    p.psvr.label = p.psvr.all_labels{l};

    % Run pSVR analysis as grid search for various voxel-counts and
    % feature-space smoothing FWHM values
    mri_reconstruction_grid(p);
    % Using the optimal values for each subject, run the analysis
    % repeatedly with permuted labels
    mri_reconstruction_permute(p);
    % Calculate statistics using the results of the permutation analysis
    mri_tmass_stats(p);
end

% Create various plots
pSVR_plot_bfca_across_trial(p);
pSVR_plot_delay_accuracy(p);
pSVR_plot_bfca_vviq_correlation(p);
pSVR_plot_bfca_behavior_correlation(p);