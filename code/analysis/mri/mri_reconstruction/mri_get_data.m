function [roi_data, roi_mask, labels] = mri_get_data(sub_id, p)

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
labels = load_labels(sub_id, p, 'sorted', 'includenans');

% Load fMRI data
[roi_data, roi_mask] = load_fmri(sub_id, p);

if isempty(roi_data)
    return;
end

% Temporal detrending based on cubic spline interpolation
roi_data = detrend_spline(roi_data, p.n_trials/2);
% Slight temporal smoothing
roi_data = moving_average(roi_data);
% Elongate last trial to avoid errors (the last trial ends earlier that 30
% TRs after the last delay onset)
for i = 1:30
    roi_data(end+1,:,:) = mean(roi_data(end-4:end,:,:));
end
% Extract trials
roi_data = extract_relevant_data(roi_data, sub_id, p);

% Sort data according to activation value (in descending order, i.e.
% strongest activation first), based on a first-level target-vs.-baseline
% contrast
[roi_data, sort_idx] = sort_data_by_activation(roi_data, roi_mask, sub_id, p);
roi_mask = find(roi_mask==1);
roi_mask = roi_mask(sort_idx);