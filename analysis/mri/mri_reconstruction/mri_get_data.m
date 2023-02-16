function [data, mask, labels] = mri_get_data(sub_id, p)

% function [data, mask, labels] = mri_get_data(sub_id, p)
% 
% Load and process fMRI data for the pSVR analysis. Realigned functional
% images are laoded, temporally detrended and smoothed and separated into
% trials. Voxels are sorted with respect to their activation value based on
% a first-level target-vs.-baseline contrast.
% 
% Input:
%   - i_sub: ID of the current subject.
%   - p: Structure with analysis parameters.
%
% Output: 
%   - data: [n_trial, n_voxel ,n_run, n_tr] array with data, sorted by
%       activation.
%   - mask: Array of ROI voxel indices, with the same sorting applied as
%       the data array.
%   - labels: Matrix with orientation labels. Rows represent trials,
%       columns represent runs.
%
% Simon Weber, sweber@bccn-berlin.de, 2022


% Load log file and extrtact labels
[log, ~ ,experiment] = load_log(sub_id, p);
labels = extract_labels(log, experiment, p, 'sorted', 'includenans');

% Load realigned images
[data, mask] = load_raw_data_masked(p, sub_id);
% Temporal detrending based on cubic spline interpolation
data = detrend_spline(data, p.n_trials/2);
% Slight temporal smoothing
data = moving_average(data);
% Elongate last trial to avoid errors (the last trial ends earlier that 30
% TRs after the last delay onset)
for i = 1:30
    data(end+1,:,:) = mean(data(end-4:end,:,:));
end
% Extract trials
data = extract_relevant_data(data, log, experiment, p);

% Sort data according to activation value (in descending order, i.e.
% strongest activation first), based on a first-level target-vs.-baseline
% contrast
[data_sorted, sort_idx] = sort_data_by_activation(data, mask, sub_id, p);
mask = find(mask==1);
mask = mask(sort_idx);