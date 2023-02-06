function [analysis_complete, predictions, results, first_perm] = pSVR_check_progress_permute(sub_id, p)

% function [analysis_complete, predictions, results, first_perm, first_tr] = pSVR_check_progress_permute(sub_id, p)
%
% Checks whether a final result file or temporary result file for the
% current subject has already been created. If not, the analysis can start
% from the beginning. If a final result file exists, the current subject
% does not have to be analyzed again. If a temporary result file exists,
% this file is loaded and the analysis can be continued from where it
% stopped.
%
% Input:
%   - i_sub: ID of the current subject.
%   - p: Structure with analysis parameters.
%
% Output:
%   - analysis_complete: 1 if final result file exists, 0 otherwise.
%   - predictions: Temporary predictions structure which is loaded from a
%       temporary result file if it exists.
%   - predictions: Temporary results structure which is loaded from a
%       temporary result file if it exists.
%   - first_perm: Permutation with which to continue the analysis.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Initialize output variable
analysis_complete = 0;

% Get filename of final result file
filename = get_filename(sub_id, p);

% Check if final result file exists
result_file = dir([filename '_permute_2*.mat']);

% If it exists (and no overwrite is requested) set 'analysis_complete' to 1
% so that this subject is skipped.
if ~isempty(result_file)
    if p.OVERWRITE ~= 1
        analysis_complete = 1;
        predictions = []; results = []; first_perm = [];
        return
    end
end

% Check if temporary result file exists
temp_file = dir([filename '_permute_temp.mat']);

if isempty(temp_file)

    % If the current subject has not been anylsed yet, initialize result
    % structures
    predictions.sin_pred = cell(p.psvr.n_perm, p.psvr.n_tr);
    predictions.cos_pred = cell(p.psvr.n_perm, p.psvr.n_tr);
    predictions.ang_pred = cell(p.psvr.n_perm, p.psvr.n_tr);
    results.bfca = zeros(p.psvr.n_perm, p.psvr.n_tr);
    first_perm = 1;

else
    
    % If temporary result file exists, load that file and set analysis
    % parameters accordingly. Otherwise start analysis from the beginning.
    load([filename '_permute_temp.mat'], 'predictions', 'results');

    % Determine at which point the analysis was interrupted (i.e. first
    % empty element of 'results.bfca'
    sz = size(results.bfca);
    for first_perm = 1:sz(1)
        if results.bfca(first_perm, 1) == 0
            break;
        end
    end
   
end
