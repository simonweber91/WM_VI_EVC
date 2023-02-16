function pSVR_save_temp(sub_id, p, predictions, results, suffix)

% function pSVR_save_temp(sub_id, p, predictions, results, suffix)
%
% Save temporary result file during ongoing analysis. Variables include:
%   - sub_id: ID of the current subject.
%   - p: Structure with analysis parameters.
%   - predictions: Structure with predictions.
%   - results: Structure with reconstruction results.
%   - suffix: Suffix to append to the filename.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Get filename
filename = get_filename(sub_id, p);

% Append 'temp' to filename
out_file = [filename '_' suffix '_temp.mat'];

% Save temporary predictions and analysis parameters
save(out_file, 'p', 'predictions', 'results', '-v7.3');

