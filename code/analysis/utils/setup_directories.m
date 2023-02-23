function setup_directories(p)

% Create all directories that are necessary for the following analyses.
% This is where data/results are stored.

base_dir = p.dirs.base;
if ~exist(base_dir,'dir')
    mkdir(base_dir)
end

data_dir = fullfile(p.dirs.base, 'data');
if ~exist(data_dir,'dir')
    mkdir(data_dir)
end
analysis_all_res = fullfile(data_dir, 'analysis', 'all', 'results');
if ~exist(analysis_all_res,'dir')
    mkdir(analysis_all_res)
end


dicom_dir = fullfile(data_dir, 'Dicom');
if ~exist(dicom_dir,'dir')
    mkdir(dicom_dir)
end

eye_dir = fullfile(data_dir, 'eye');
if ~exist(eye_dir,'dir')
    mkdir(eye_dir)
end

log_dir = fullfile(data_dir, 'logs');
if ~exist(log_dir,'dir')
    mkdir(log_dir)
end

nifti_dir = fullfile(data_dir, 'Nifti');
if ~exist(nifti_dir,'dir')
    mkdir(nifti_dir)
end
nifti_roi = fullfile(data_dir, 'Nifti', 'all', 'rois');
if ~exist(nifti_roi,'dir')
    mkdir(nifti_roi)
end

vviq_dir = fullfile(data_dir, 'vviq');
if ~exist(vviq_dir,'dir')
    mkdir(vviq_dir)
end


