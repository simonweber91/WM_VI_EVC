function model = pp_segment(sub_id, p)

% function model = pp_segment(sub_id, p)
%
% Runs SPM segmentation on a coregistered high-res anatomical image.
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
base_dir                = p.base_dir;
n_ses                   = p.n_session;

% Get subject ID as string
sub_str                 = num2str(sub_id,'%02i');

% initialize output variable
model = {};

% Get input image (coregistered T1)
if n_ses > 1
    % Check if output images already exist
    check_file = dir(fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'anat', ['c*rsub*']));
    files = cellstr(spm_select('FPList', fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'anat'), ['^rsub.*.nii']));
elseif n_ses == 1
    % Check if output images already exist
    check_file = dir(fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'anat', ['c*rsub*']));
    files = cellstr(spm_select('FPList', fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'anat'), ['^rsub.*.nii']));
end

% Check if input files are present
if isempty(files)
    warning('Subject %d - segmentation: no input files found.', sub_id);
    return;
end

% Overwrite if requested
if ~isempty(check_file) && p.OVERWRITE == 1
    warning('FILES WILL BE OVERWRITTEN!!! If this was a mistake, abort now!');
    pause(5);
    
    delete(fullfile(check_file(1).folder, ['c*rsub*']));
    delete(fullfile(check_file(1).folder, ['*y_rsub*']));
    delete(fullfile(check_file(1).folder, ['mrsub*']));
    check_file = [];
end

% Run
if isempty(check_file)

    model{1}.spm.spatial.preproc.channel.vols = files';
    model{1}.spm.spatial.preproc.channel.biasreg = 0.001;
    model{1}.spm.spatial.preproc.channel.biasfwhm = 60;
    model{1}.spm.spatial.preproc.channel.write = [0 1];

    model{1}.spm.spatial.preproc.tissue(1).tpm = {
        fullfile(spm('Dir'),'tpm','TPM.nii,1')};
    model{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    model{1}.spm.spatial.preproc.tissue(1).native = [1 0];
    model{1}.spm.spatial.preproc.tissue(1).warped = [0 0];

    model{1}.spm.spatial.preproc.tissue(2).tpm = {
        fullfile(spm('Dir'),'tpm','TPM.nii,2')};
    model{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    model{1}.spm.spatial.preproc.tissue(2).native = [1 0];
    model{1}.spm.spatial.preproc.tissue(2).warped = [0 0];

    model{1}.spm.spatial.preproc.tissue(3).tpm = {
        fullfile(spm('Dir'),'tpm','TPM.nii,3')};
    model{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    model{1}.spm.spatial.preproc.tissue(3).native = [1 0];
    model{1}.spm.spatial.preproc.tissue(3).warped = [0 0];

    model{1}.spm.spatial.preproc.tissue(4).tpm = {
        fullfile(spm('Dir'),'tpm','TPM.nii,4')};
    model{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    model{1}.spm.spatial.preproc.tissue(4).native = [1 0];
    model{1}.spm.spatial.preproc.tissue(4).warped = [0 0];

    model{1}.spm.spatial.preproc.tissue(5).tpm = {
        fullfile(spm('Dir'),'tpm','TPM.nii,5')};
    model{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    model{1}.spm.spatial.preproc.tissue(5).native = [1 0];
    model{1}.spm.spatial.preproc.tissue(5).warped = [0 0];

    model{1}.spm.spatial.preproc.tissue(6).tpm = {
        fullfile(spm('Dir'),'tpm','TPM.nii,6')};
    model{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    model{1}.spm.spatial.preproc.tissue(6).native = [0 0];
    model{1}.spm.spatial.preproc.tissue(6).warped = [0 0];

    model{1}.spm.spatial.preproc.warp.mrf = 1;
    model{1}.spm.spatial.preproc.warp.cleanup = 1;
    model{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    model{1}.spm.spatial.preproc.warp.affreg = 'mni';
    model{1}.spm.spatial.preproc.warp.fwhm = 0;
    model{1}.spm.spatial.preproc.warp.samp = 3;
    model{1}.spm.spatial.preproc.warp.write = [1 1];      % forward and reverse deformation fields
    
    fprintf('\nSubject %d - perform segmentation.', sub_id)

    spm('defaults', 'FMRI'); 
    spm_jobman('run', model);
else
    warning('Subject %d - segmented images already exist, skip segmentation.', sub_id)
end