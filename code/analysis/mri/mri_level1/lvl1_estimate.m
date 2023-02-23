function model = lvl1_estimate(sub_id, p)

% function model = lvl1_estimate(sub_id, p)
%
% Performs a SPM first-level analysis.
%
% Input:
%   - sub_id: ID of the current subject.
%   - p: Structure with analysis parameters.
%
% Output:
%   - model: Structure with all SPM settings used for this analysis
%       step (would be 'matlabbatch' in SPM).
%
% Simon Weber, sweber@bccn-berlin.de, 2020

% Exptract relevant variables from p
data_dir                = p.dirs.data;
title                   = p.lvl1.title;

% Get subject ID as string
sub_str                 = num2str(sub_id,'%02i');

% Initialize output variable
model = {};

% Checks if SPM file for this analysis arelady exists
out_dir = fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'lvl1', title);
if ~exist(fullfile(out_dir,'SPM.mat'), 'file')
    warning('Subject %d - no SPM file found, can''t perform 1st level estimation.', sub_id);
    return;
end

% Checks if beta files are already present
check_file = dir(fullfile(out_dir,'beta*'));

if isempty(check_file) || p.OVERWRITE == 1

    % Specify SPM file
    model{1}.spm.stats.fmri_est.spmmat = { fullfile(out_dir, 'SPM.mat') };  
    % Additional parameters
    model{1}.spm.stats.fmri_est.write_residuals = 0;                     % write residuals (0: no)
    model{1}.spm.stats.fmri_est.method.Classical = 1;

    fprintf('\nSubject %d - 1st level estimation.', sub_id)

    %%% Run %%%
    spm('defaults', 'FMRI'); 
    spm_jobman('run', model);
    
else
    warning('Subject %d - 1st level estimation already performed, skip.', sub_id)
end