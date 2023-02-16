function copy_brain_mask(i_sub, p)

% function copy_brain_mask(i_sub, p)
%
% Copies the 'mask.nii' image (containing a binary mask of brain voxels)
% that was created during SPM first-level analysis into a subject-specific
% 'rois' folder, so that it can be used in later analysis steps.
%
% Input:
%   - i_sub: ID of the current subject.
%   - p: Structure with analysis parameters.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Exptract relevant variables from p
base_dir                = p.base_dir;
title                   = p.lvl1.title;

% Get subject ID as string
sub_str                 = num2str(i_sub,'%02i');

% Get directory of mask.nii
out_dir = fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'lvl1', title);

% Copy brain-mask into subject's 'rois' folder to be used in the main
% analysis
if ~exist(fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'rois' ,'mask.nii'),'file')
    if ~exist(fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'rois'),'dir'), mkdir(fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'rois')); end
    fprintf('\nSubject %d - copy mask.nii into subject''s ROI folder.', i_sub)
    copyfile(fullfile(out_dir ,'mask.nii'), fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'rois' ,'mask.nii'));
end
