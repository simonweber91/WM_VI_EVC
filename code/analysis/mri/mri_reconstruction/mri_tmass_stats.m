function tmass_stats = mri_tmass_stats(p)

% Performs permutation-based cluster t-mass analysis to determine clusters
% of subsequent time points with above-chance reconstruction accuracy based
% on t-tests. First, permutation results are loaded for all subejcts.
% Chance-level is removed (to allow testing against 0) and a slight
% temporal smoothing is applied. Then, the cluster t-mass is computed (see
% cluster_t_mass.m).

%%% Load data and adjust format for 'cluster_t_mass.m' %%%

bfca = pSVR_load_bfca(p);
if isempty(bfca)
    warning('Permutation-based cluster t-mass analysis cannot be performed.')
    return;
end

% Remove chance-level and smooth
bfca = bfca - 50;
% bfca = permute(moving_average(permute(bfca, [2 1 3]), 3), [2 1 3]);

tmass_stats = cluster_t_mass(bfca, 'right');

% Save stats
out_dir = fullfile(p.dirs.data, 'analysis', 'all', 'results');
if ~exist(out_dir,'dir'), mkdir(out_dir); end
out_file = fullfile(out_dir, ['pSVR_' p.psvr.event '_' p.psvr.label '_' p.psvr.roi '_stats.mat']);
save(out_file, 'tmass_stats')