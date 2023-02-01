function data_averaged = moving_average(data, winsize)

% function data_av = moving_average(data, winsize)
%
% Computes moving average across TRs, which serves as temporal smoothing. 
%
% Input:
%   - data: [n_tr, n_voxel, n_run] array with data.
%   - winsize: Size of moving average window, i.e. number of subsequent TRs
%       to average (default: 3).
%
% Output:
%   - data_averaged: [n_tr, n_voxel, n_run] array with averaged data.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Initialize output variable
data_averaged = zeros(size(data));

% Get relevant data dimension, i.e. number of TRs
n_tr = size(data,1);


% Assign default winsize if variable is not specified
if ~exist('winsize','var') || isempty(winsize)
    winsize = 3;
end

%Print info text
fprintf('Running moving average of size %d across %d TRs ...\n', winsize, n_tr);

% Create 'step' to help define windows for averaging
step = floor(winsize/2);

% For each TR, create a window around it and average the data within that
% window.
for i_tr = 1:n_tr
    % Get window indices
    ind = i_tr-step:i_tr+step;
    % Deal with border cases
    ind(ind<1) = []; ind(ind>n_tr) = [];
    % Compute average and assign to output variable
    data_averaged(i_tr,:,:) = nanmean(data(ind,:,:),1);
end

