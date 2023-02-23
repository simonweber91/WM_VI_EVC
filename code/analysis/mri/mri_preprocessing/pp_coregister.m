function model = pp_coregister(sub_id, p)

% function model = pp_coregister(sub_id, p)
%
% Runs SPM coregistration. Aligns a high-res anatomical image with a fMRI
% image (the 'meansub*' image from the realignment is used as reference).
%
% Input:
%   - sub_id: ID of the current subject.
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

% Get input images (high-res T1 as source and 'meansub*' as reference)
if n_ses > 1
    % Check if output images already exist
    check_file = dir(fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'anat', ['rsub*']));
    reference = cellstr(spm_select('FPList', fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'func'), '^meansub.*.nii'));
    source = cellstr(spm_select('FPList', fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'anat'), '^sub.*T1w.nii'));
elseif n_ses == 1
    % Check if output images already exist
    check_file = dir(fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'anat', ['rsub*']));
    reference = cellstr(spm_select('FPList', fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'func'), '^meansub.*.nii'));
    source = cellstr(spm_select('FPList', fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'anat'), '^sub.*T1w.nii'));
end

% Check if input files are present
if isempty(source{1})
    warning('Subject %d - coregistration: no input files found.', sub_id);
    return;
end

% Overwrite if requested
if ~isempty(check_file) && p.OVERWRITE == 1
    warning('FILES WILL BE OVERWRITTEN!!! If this was a mistake, abort now!');
    pause(5);
    
    delete(fullfile(check_file(1).folder, ['rsub*']));
    check_file = [];
end

% Run
if isempty(check_file)

    % Estimate
    model{1}.spm.spatial.coreg.estwrite.ref = reference;
    model{1}.spm.spatial.coreg.estwrite.source = source;
    model{1}.spm.spatial.coreg.estwrite.other = {''};
    model{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    model{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    model{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    model{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    % Reslice
    model{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
    model{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    model{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    model{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
    
    fprintf('\nSubject %d - perform coregistration.', sub_id)

    spm('defaults', 'FMRI'); 
    spm_jobman('run', model);
else
    warning('Subject %d - coregistered anatomical image already exists, skip coregistration.', sub_id)
end

