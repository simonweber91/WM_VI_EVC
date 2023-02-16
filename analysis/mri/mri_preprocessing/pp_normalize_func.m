function model = pp_normalize_func(sub_id, p)

% function model = pp_normalize_func(sub_id, p)
%
% Runs SPM normalization on fMRI images that has been realigned and
% slice-time corrected (prefix 'ar'). Uses the deformation fields that were
% calculated with pp_segment.m.
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
base_dir                = p.base_dir;
n_ses                   = p.n_session;

% Get subject ID as string
sub_str                 = num2str(sub_id,'%02i');

% initialize output variable
model = {};

% Get input images (realigned, slice-time corrected fMRI images and
% deformation field)
files = {};
if n_ses > 1
    % Check if output images already exist
    check_file = dir(fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'func', ['warsub*' filter '*']));
    deform_field = cellstr(spm_select('FPList', fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'anat'), '^y_rsub.*.nii'));
    for i_ses = 1:n_ses
         ses_str = num2str(i_ses,'%02i');
         list = spm_select('ExtFPList', fullfile(base_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str], 'func'),['^arsub.*' filter]);
         if ~isempty(list)
            files{end+1} = cellstr(list);
         end
    end
elseif n_ses == 1
    % Check if output images already exist
    check_file = dir(fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'func', ['warsub*' filter '*']));
    deform_field = cellstr(spm_select('FPList', fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'anat'), '^y_rsub.*.nii'));
    list = spm_select('ExtFPList', fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'func'),['^arsub.*' filter]);
    files{end+1} = cellstr(list);
end

% Check if input files are present
if isempty(files)
    warning('Subject %d - normalization functional: no input files found.', sub_id);
    return;
end

% Overwrite if requested
if ~isempty(check_file) && p.OVERWRITE == 1
    warning('FILES WILL BE OVERWRITTEN!!! If this was a mistake, abort now!');
    pause(5);
    
    for i_ses = 1:n_ses
        ses_str = num2str(i_ses,'%02i');
        delete(fullfile(base_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str], 'func', ['warsub*' filter '*']));
    end
    check_file = [];
end

% Run
if isempty(check_file)

    % structural image (bias field corrected)
    model{1}.spm.spatial.normalise.write.subj.def = deform_field;                 % deformation field
    model{1}.spm.spatial.normalise.write.subj.resample = reshape([files{:}],[],1);

    % writing options
    model{1}.spm.spatial.normalise.write.woptions.bb = [-78, -112, -70; 78, 76, 85];  % bounding box
    model{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];    % voxel size
    model{1}.spm.spatial.normalise.write.woptions.interp = 4;            % b-spline degree of interpolation
    model{1}.spm.spatial.normalise.write.woptions.prefix = 'w';          % filename prefix 
    
    fprintf('\nSubject %d - perform normalization of functional images.', sub_id)

    spm('defaults', 'FMRI'); 
    spm_jobman('run', model);
else
    warning('Subject %d - normalized functional images already exist, skip normalization.', sub_id)
end