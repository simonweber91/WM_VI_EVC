function warp_rois_to_subject_space(p, roi_name)

% function warp_rois_to_subject_space(p, roi_name)
% 
% Warps ROI probability maps into subject space, thresholds at 0.1 and
% creates binary masks. Please note: the output files in subject space will
% be prefixed with 'w' according to SPM convention.
%
% Input: 
%   - p: Structure with analysis parameters, including base directory of
%       the project.
%   - roi_name: Name of the ROI to warp. Should be located in the 'Rois'
%       folder in the main project directory.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

roi_file = dir(fullfile(p.dirs.data, 'Nifti', 'all', 'rois', [roi_name '.nii']));

if isempty(roi_file)
    warning('No ROI file to warp.')
    return;
end

threshold = 0.1;

for i_sub = 1:numel(p.subjects)

    % Get subject ID
    sub_id = p.subjects(i_sub);
    
    sub_str = num2str(sub_id,'%02i');
    
    out_dir = fullfile(p.dirs.data, 'Nifti', ['sub-' sub_str], 'rois');
    if ~exist(out_dir,'dir'), mkdir(out_dir); end

    if exist(fullfile(out_dir, ['w' roi_file.name]), 'file') && ~p.OVERWRITE
        warning('Subject %d - ROI file already exists.', sub_id)
        continue;
    end

    disp(['Processing subject ' sub_str]);

    def_field = dir(fullfile(p.dirs.data, 'Nifti', ['sub-' sub_str], 'ses-01','anat', ['iy_rsub-' sub_str '*.nii']));
    sub_space = dir(fullfile(p.dirs.data, 'Nifti', ['sub-' sub_str], 'ses-01','func', ['rsub-' sub_str '*' p.img.filter '*run-01*.nii']));

    if isempty(def_field) || isempty(sub_space)
        warning('Subject %d - Missing files, ROI cannot be warped.', sub_id)
        continue;
    end
            
    warp{1}.spm.util.defs.comp{1}.def = {
        fullfile(def_field.folder, def_field.name) };
    warp{1}.spm.util.defs.comp{2}.id.space = {
        fullfile(sub_space.folder, sub_space.name) };
    warp{1}.spm.util.defs.out{1}.pull.fnames = {fullfile(roi_file.folder, roi_file.name)};
    warp{1}.spm.util.defs.out{1}.pull.savedir.saveusr = {out_dir};
    warp{1}.spm.util.defs.out{1}.pull.interp = 4;
    warp{1}.spm.util.defs.out{1}.pull.mask = 1;
    warp{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
    warp{1}.spm.util.defs.out{1}.pull.prefix = 'w';

    %%% Run %%%
    spm('defaults', 'FMRI'); 
    spm_jobman('run', warp);

    % threshold at 0.1 and create mask
    vol = spm_vol(fullfile(out_dir,['w' roi_name '.nii']));
    img = spm_read_vols(vol);
    img(img < threshold) = 0;
    img(img > 0) = 1;
    img(isnan(img)) = 0;
    vol.fname = fullfile(out_dir,['w' roi_name '.nii']);
    spm_write_vol(vol, img);
end


