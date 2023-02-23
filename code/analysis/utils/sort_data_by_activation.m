function [data_sorted, sort_idx, sort_idx_img] = sort_data_by_activation(data, mask, sub_id, p)

% function [roi_data, roi_idx, roi_idx_img] = extract_roi_index(data, mask, i_sub, p)
%
% Sorts data based on the t-value from a SPM t-image.
%
% Input:
%   - data: [n_trial, n_voxel,n_run, .n_tr] array with data.
%   - mask: binary ROI mask which was used to load the data.
%   - i_sub: ID of the current subject.
%   - p: Structure with analysis parameters.
%
% Output:
%   - data_sorted: [n_trial, n_roivox ,n_run, n_tr] array with ROI data.
%   - sort_idx: ROI voxel indeces.
%   - sort_idx_img: ROI voxel indeces in the original image space (for image
%       reconstruction).
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Get subject ID as string
sub_str = num2str(sub_id,'%02i');


% Load T-image of target-vs.-baseline contrast
t_vol = spm_vol(fullfile(p.dirs.data,'Nifti',['sub-' sub_str], 'lvl1','trial_events','spmT_0001.nii'));
t_img = spm_read_vols(t_vol);

% Mask with binary ROI mask
t_img(find(mask==0)) = 0;

% Find indices of most activated voxels in the original image space
[~, t_img_sorted] = sort(t_img(:),'descend');

% Load only ROI voxels of T-image
t_roi = spmReadVolsMasked(t_vol, mask);

% Find indices of most activated voxels in ROI space
[~, t_roi_sorted] = sort(t_roi,'descend');

% Get voxel indeces of interest in ROI and image space
sort_idx = t_roi_sorted;
sort_idx_img = t_img_sorted;

% Extract data corresponding to voxels of interest
data_sorted = data(:,sort_idx,:,:);