function copy_brain_mask(sub_id, p)

% function copy_brain_mask(sub_id, p)
%
% Copies the 'mask.nii' image (containing a binary mask of brain voxels)
% that was created during SPM first-level analysis into a subject-specific
% 'rois' folder, so that it can be used in later analysis steps.
%
% Input:
%   - sub_id: ID of the current subject.
%   - p: Structure with analysis parameters.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Exptract relevant variables from p
data_dir                = p.dirs.data;
title                   = p.lvl1.title;

% Get subject ID as string
sub_str                 = num2str(sub_id,'%02i');

% Get directory of mask.nii
out_dir = fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'lvl1', title);

if ~exist(fullfile(out_dir ,'mask.nii'), 'file')
    warning('Subject %d - no SPM mask, can''t transfer to subjects ROI folder.', sub_id)
    return;
end

% Copy brain-mask into subject's 'rois' folder to be used in the main
% analysis
if ~exist(fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'rois' ,'mask.nii'),'file')
    if ~exist(fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'rois'),'dir'), mkdir(fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'rois')); end
    fprintf('\nSubject %d - copy mask.nii into subject''s ROI folder.', sub_id)
    copyfile(fullfile(out_dir ,'mask.nii'), fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'rois' ,'mask.nii'));
end
