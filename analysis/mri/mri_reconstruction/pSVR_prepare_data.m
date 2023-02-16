function [data, mask] = pSVR_prepare_data(data, mask, voxel_count, fwhm, labels)

% function [data, mask] = pSVR_prepare_data(data, mask, voxel_count, fwhm, labels)
% 
% Prepare data for pSVR reconstruction. Get the appropriate number of
% voxels, run feature-space smoothing, adjust the format for TDT and remove
% data corresponding to trials with missing responses.
%
% Input:
%   - data: [n_trial, n_voxel ,n_run, n_tr] array with data, sorted by
%       activation.
%   - mask: Array of ROI voxel indices, with the same sorting applied as
%       the data array.
%   - voxel_count: Number of voxels to run the analysis on.
%   - fwhm: FWHM value for feature-space smoothing.
%   - labels: Matrix with orientation labels. Rows represent trials,
%       columns represent runs.
%
% Output:
%   - data: [n_trial, n_voxel, n_tr] array with data. The first dimension
%       now holds the trials across all runs.
%   - mask: Array of ROI voxel indices corresponding to the voxels in
%       'data'.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Get the number of voxels defined by 'voxel_count'
data = data(:, 1:voxel_count, :, :);
mask = mask(1:voxel_count);

% Run feature-space smoothing
data = feature_space_smoothing(data, labels, fwhm);

% Adjust the format of the data for TDT
data = permute(data, [1, 3, 2, 4]);
data = reshape(data, size(data,1)*size(data,2), [], size(data,4));

% Remove data corresponding to trials with missing responses
nan_ind = find(isnan(labels));
data(nan_ind,:,:) = [];


