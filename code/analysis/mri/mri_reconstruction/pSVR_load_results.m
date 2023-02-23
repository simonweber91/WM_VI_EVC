function all_results = pSVR_load_results(p, suffix)

% function all_results = pSVR_load_results(p)
%
% Load pSVR results of all participants.
%
% Input:
%   - p: Structure with analysis parameters.
%   - suffix: Suffix to append to the filename.
%
% Output:
%   - all_results: structure with result measures of all participants
%       (separated by index).
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Initialize subject counter and loop through subjects
for i_sub = 1:numel(p.subjects)

    % Get subject ID
    sub_id = p.subjects(i_sub);
    
    % Get filename of result file
    filename = get_filename(sub_id, p);
    filename = dir([filename, '_' suffix '_2*.mat']);
    
    if isempty(filename)
        warning('Subject %d - missing results file, cannot load results for all subejcts.', sub_id)
        all_results = [];
        return;
    end
    
    % Load 'results' and'predictions' variables from result file and append
    % to output variables
    if numel(filename) == 1
        filename = fullfile(filename.folder, filename.name);
        load(filename, 'results')

        all_results(i_sub) = results;
    end   
end