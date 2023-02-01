function [bfca_cv, voxel_cv, fwhm_cv] = pSVR_nested_cv(all_results, p)

% function [bfca_cv, voxel_cv, fwhm_cv] = pSVR_nested_cv(all_results, p)
%
% Perform nested cross-validation to determine the optimal voxel-number and
% feature-space smoothing FWHM value for each participant, based on the
% results of all other participants.
%
% Input:
%   - all_results: structure with result measures of all participants
%       (separated by index).
%   - p: Structure with analysis parameters.
%
% Output:
%   - bfca_cv: Structure with analysis parameters.
%   - voxel_cv: Array containing the index of the optimal voxel number (1st
%       row) and the actual voxel number (2nd row) for each participant
%       (columns).
%   - fwhm_cv: Array containing the index of the optimal FWHM value (1st
%       row) and the actual FWHM value (2nd row) for each participant
%       (columns).
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Set delay TRs
delay = p.psvr.delay;

vox_ind = 1:numel(p.psvr.voxel);
fwhm_ind = 1:numel(p.psvr.fwhm);

% Get number of subjects
n_sub = numel(p.subjects);

% Get results
result = [];
for i_sub = 1:n_sub
    result(:,:,:,i_sub) = all_results(i_sub).bfca;
end

% For each subject...
for i_sub = 1:n_sub
    
    % Get all other subjects
    cv_sub = 1:n_sub ~= i_sub;
    
    % Calculate average across all other subjects and extract delay TRs
    cv_mean = mean(result(:,delay,:,cv_sub),4);

    % Average across TRs
    cv_mean = mean(cv_mean,2);

    % Remove 2nd dimension (former TRs)
    cv_mean = permute(cv_mean, [1 3 2]);

    % Select voxel/fwhm values of interest
    cv_mean = cv_mean(vox_ind, fwhm_ind);
    
    % Find row and column indeces of highes reconstruction accuracy
    [max_row, max_col] = ind2sub(size(cv_mean),find(cv_mean==max(cv_mean,[],'all')));
    
    % Assign the data of the left-out subject that corresponds to these
    % indices to the output variable
    bfca_cv(i_sub,:) = result(max_row,:,max_col,i_sub);
   
    % Fill output variable with the subject specific values and indeces of
    % the optimal analysis run
    voxel_cv(1,i_sub) = max_row;
    voxel_cv(2,i_sub) = p.psvr.voxel(max_row);
    fwhm_cv(1,i_sub) = max_col;
    fwhm_cv(2,i_sub) = p.psvr.fwhm(max_col);
    
end
