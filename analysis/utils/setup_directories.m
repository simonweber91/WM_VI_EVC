function setup_directories(p)

% Create all directories that are necessary for the following analyses.
% This is where data/results are stored.

dicom_dir = fullfile(p.base_dir, 'Dicom');
if ~exist(dicom_dir,'dir')
    mkdir(dicom_dir)
end

nifti_dir = fullfile(p.base_dir, 'Nifti');
if ~exist(nifti_dir,'dir')
    mkdir(nifti_dir)
end

results_dir = fullfile(p.base_dir, 'Results');
if ~exist(results_dir,'dir')
    mkdir(results_dir)
end

rois_dir = fullfile(p.base_dir, 'rois');
if ~exist(rois_dir,'dir')
    mkdir(rois_dir)
end

vviq_dir = fullfile(p.base_dir, 'Vviq');
if ~exist(vviq_dir,'dir')
    mkdir(vviq_dir)
end
