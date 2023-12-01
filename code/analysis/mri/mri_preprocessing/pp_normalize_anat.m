function model = pp_normalize_anat(sub_id, p)

% function model = pp_normalize_anat(sub_id, p)
%
% Runs SPM normalization on a high-res anatomical image that has been
% coregistered and bias-field corrected (prefix 'mr'). Uses the image and
% deformation fields that were calculated with pp_segment.m.
%
% Input:
%   - i_sub: ID of the current subject.
%   - p: Structure with analysis parameters.
%
% Output:
%   - model: Structure with all SPM settings used for this preprocessing
%       step (would be 'matlabbatch' in SPM).
%
% Simon Weber, sweber@bccn-berlin.de, 2020

% Exptract relevant variables from p
data_dir                = p.dirs.data;
n_ses                   = p.n_session;

% Get subject ID as string
sub_str                 = num2str(sub_id,'%02i');

% initialize output variable
model = {};

% Get input images (coregistered, bias-field corrected T1 and deformation field)
files = {};
if n_ses > 1
    % Check if output images already exist
    check_file = dir(fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'anat', ['wmrsub*']));
    deform_field = cellstr(spm_select('FPList', fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'anat'), '^y_rsub.*.nii'));
    list = spm_select('ExtFPList', fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'anat'), '^mrsub.*T1w.nii');
    if ~isempty(list)
        files{end+1} = cellstr(list);
    end
elseif n_ses == 1
    % Check if output images already exist
    check_file = dir(fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'anat', ['wmrsub*']));
    deform_field = cellstr(spm_select('FPList', fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'anat'), '^y_rsub.*.nii'));
    list = spm_select('ExtFPList', fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'anat'), '^mrsub.*T1w.nii');
    if ~isempty(list)
        files{end+1} = cellstr(list);
    end
end

% Check if input files are present
if isempty(files)
    warning('Subject %d - normalization anatomical: no input files found.', sub_id);
    return;
end

% Overwrite if requested
if ~isempty(check_file) && p.OVERWRITE == 1
    warning('FILES WILL BE OVERWRITTEN!!! If this was a mistake, abort now!');
    pause(5);
    
    delete(fullfile(check_file(1).folder, ['wmrsub*']));
    check_file = [];
end

% Run
if isempty(check_file)

    % structural image (bias field corrected)
    model{1}.spm.spatial.normalise.write.subj.def = deform_field;                 % deformation field
    model{1}.spm.spatial.normalise.write.subj.resample = files;                % bias field corrected structural image (prefix: m)

    % writing options
    model{1}.spm.spatial.normalise.write.woptions.bb = [-78, -112, -70; 78, 76, 85];  % bounding box
    model{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];    % voxel size
    model{1}.spm.spatial.normalise.write.woptions.interp = 4;            % b-spline degree of interpolation
    model{1}.spm.spatial.normalise.write.woptions.prefix = 'w';          % filename prefix 
    
    fprintf('\nSubject %d - perform normalization of anatomical image.', sub_id)

    spm('defaults', 'FMRI'); 
    spm_jobman('run', model);
else
    warning('Subject %d - normalized anatomical image already exists, skip normalization.', sub_id)
end
