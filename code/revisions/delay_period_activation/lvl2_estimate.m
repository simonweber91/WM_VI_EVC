function model = lvl2_estimate(p)

% function model = lvl2_estimate(p)
%
% Performs a SPM second-level analysis.
%
% Input:
%   - p: Structure with analysis parameters.
%
% Output:
%   - model: Structure with all SPM settings used for this analysis
%       step (would be 'matlabbatch' in SPM).
%
% Simon Weber, sweber@bccn-berlin.de, 2023

% Exptract relevant variables from p
data_dir                = p.dirs.data;
title                   = p.lvl1.title;

% Initialize output variable
model = {};

% Checks if SPM file for this analysis arelady exists
out_dir = fullfile(data_dir, 'Nifti', 'all', 'lvl2', title);
if ~exist(fullfile(out_dir,'SPM.mat'), 'file')
    warning('No SPM file found, can''t perform 2nd level estimation.');
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

    fprintf('\n2nd level estimation.')

    %%% Run %%%
    spm('defaults', 'FMRI'); 
    spm_jobman('run', model);
    
else
    warning('2nd level estimation already performed, skip.')
end