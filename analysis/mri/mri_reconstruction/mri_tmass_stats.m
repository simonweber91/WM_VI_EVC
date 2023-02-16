function tmass_stats = mri_tmass_stats(p)

% Performs permutation-based cluster t-mass analysisto determine clusters
% of subsequent time points with above-chance reconstruction accuracy based
% on t-tests. First, permutation results are loaded for all subejcts.
% Chance-level is removed (to allow testing against 0) and a slight
% temporal smoothing is applied. Then, the cluster t-mass is computed (see
% cluster_t_mass.m).

%%% Load data and adjust format for 'cluster_t_mass.m' %%%

% Load results of grid-search pSVR analysis
grid_results = pSVR_load_results(p, 'grid');
% Run nested cross-validation across subjects to get bfca values of optimal
% parameters
[bfca_grid] = pSVR_nested_cv(grid_results, p);

% Load results of permutation pSVR analysis
perm_results = pSVR_load_results(p, 'permute');
for i_sub = 1:numel(p.subjects)
    bfca_perm(i_sub,:,:) = permute(perm_results(i_sub).bfca, [3 2 1]);
end

% Concatenate arrays, empirical results in (:,:,1)
bfca = cat(3, bfca_grid, bfca_perm);

% Remove chance-level and smooth
bfca = bfca - 50;
bfca = permute(moving_average(permute(bfca, [2 1 3]), 3), [2 1 3]);

tmass_stats = cluster_t_mass(bfca, 'right');

% Save stats
out_dir = fullfile(p.base_dir, 'Results', 'pSVR');
if ~exist(out_dir,'dir'), mkdir(out_dir); end
out_file = fullfile(out_dir, [p.psvr.event '_' p.psvr.label '_' p.psvr.roi '_stats']);
save(out_file, 'tmass_stats')