function pp_save(sub_id, p, model)

% function pp_save(sub_id, p, model)
%
% Saves the 'model' structure that holds the parameters of all performed
% preprocessing steps.
%
% Input:
%   - i_sub: ID of the current subject.
%   - p: Structure with analysis parameters.
%   - model: Structure with all SPM settings used during preprocessing.
%
% Simon Weber, sweber@bccn-berlin.de, 2020

% Exptract relevant variables from p
data_dir                = p.dirs.data;

% Get subject ID as string
sub_str                 = num2str(sub_id,'%02i');

% Get filename
out_file = fullfile(data_dir, 'Nifti', ['sub-' sub_str], ['pp_log_' datestr(now,'yymmddHHMM') '.mat']);

% Only save if there are non-empty cells
if ~all(cellfun(@isempty, model))
    
    % Detect empty cells
    e = cellfun(@isempty, model);
    model(e) = [];

    save(out_file, 'model', 'p')
else
    warning('Subject %d - Model structure completely empty, no log saved.', sub_id)
end