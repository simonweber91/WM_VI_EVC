function [labels_psvr, labels_rad, missing] = pSVR_prepare_labels(labels)

% function [labels_psvr, labels_rad, missing] = pSVR_prepare_labels(labels)
% 
% Prepare orientation labels for pSVR reconstruction. Labels are converted
% from degrees to radians and then converted into their sine- and cosine
% components which are used as labels by the pSVR.
%
% Input:
%   - labels: Matrix with orientation labels. Rows represent trials,
%       columns represent runs.
%
% Output:
%   - labels_psvr: Cell array with sine and cosine labels for pSVR.
%   - labels_psvr: Vector with labels in radians used for comparison with
%       pSVR predictions.
%   missing: Indices of trials with missing responses.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Find NaN labels and exclude missing trials
labels = labels(:);
missing = isnan(labels);
labels(missing) = [];

% Degree to randians conversion
labels_rad = deg2rad(labels)-pi;     % turn to rad and shift to range -pi:pi

% Extract sine and cosine components
labels_sin = sin(labels_rad);
labels_cos = cos(labels_rad);

% Turn to cell array for TDT multitarget regression
labels_psvr = mat2cell([labels_sin, labels_cos], ones(numel(labels_rad),1));