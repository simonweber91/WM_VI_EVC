function model = lvl2_contrasts(p)

% function model = lvl2_contrasts(p)
%
% Defines and calculates constrasts for a SPM second-level analysis.
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

contrasts               = p.lvl2.contrasts;
contrast_weights        = p.lvl2.constrast_weights;

% Initialize output variable
model = {};

% Get output directory
out_dir = fullfile(data_dir, 'Nifti', 'all', 'lvl2', title);

if ~exist(fullfile(out_dir,'SPM.mat'), 'file')
    warning('No SPM file found, can''t calculate constrasts.')
    return;
end

% Check if specified contrasts already exist, and if yes, their indeces
load(fullfile(out_dir, 'SPM.mat'));
if ~isfield(SPM,'xCon') || isempty(SPM.xCon)
    existing_contrasts = {}; existing_index = [];
else
    existing_contrasts = {SPM.xCon.name};
    existing_index = find(ismember(contrasts, existing_contrasts));
end

%%%% CAUTION: OVERWRITES CONTRAST FILE!!! %%%%
if p.OVERWRITE == 1
    warning('CONTRASTS WILL BE OVERWRITTEN!!! If this was a mistake, abort now!');
    pause(5);
    
    overwrite = 1;
else
    overwrite = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If contrasts already exist and overwrite is disabled, return
if numel(existing_contrasts) == numel(contrasts) && overwrite == 0
    warning('Subject %d - all specified contrasts already exist, skip.', sub_id);
    return;
end

% Define contrasts
model{1}.spm.stats.con.spmmat = { fullfile(out_dir, 'SPM.mat') }; 
for i_con = 1:numel(contrasts)
    model{1}.spm.stats.con.consess{i_con}.tcon.name = contrasts{i_con};
    model{1}.spm.stats.con.consess{i_con}.tcon.weights = contrast_weights{i_con};
    model{1}.spm.stats.con.consess{i_con}.tcon.sessrep = 'none';
end

% Clear indices of already existing contrasts
if overwrite == 0, model{1}.spm.stats.con.consess(existing_index) = []; end
model{1}.spm.stats.con.delete = overwrite;
 
%%% Run %%%
spm('defaults', 'FMRI'); 
spm_jobman('run', model); 
