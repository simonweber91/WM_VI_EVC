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

threshold = 0.1;

roi_file = fullfile(p.base_dir, 'Rois', [roi_name '.nii']);

for i_sub = 1:numel(p.subjects)

    % Get subject ID
    sub_id = p.subjects(i_sub);
    
    sub_str = num2str(sub_id,'%02i');
    
    out_dir = fullfile(p.base_dir,'Nifti',['sub-' sub_str],'rois');
    if ~exist(out_dir,'dir'), mkdir(out_dir); end

    disp(['Processing subject ' sub_str]);
            
    warp{1}.spm.util.defs.comp{1}.def = {
        fullfile(p.base_dir,'Nifti',['sub-' sub_str],'ses-01','anat',['iy_rsub-' sub_str '_ses-01_T1w.nii']) };
    warp{1}.spm.util.defs.comp{2}.id.space = {
        fullfile(p.base_dir,'Nifti',['sub-' sub_str],'ses-01','func',['rsub-' sub_str '_ses-01_task-vwm_run-01_bold.nii']) };
    warp{1}.spm.util.defs.out{1}.pull.fnames = {roi_file};
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
